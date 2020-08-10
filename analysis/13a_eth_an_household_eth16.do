/*==============================================================================
DO FILE NAME:			13a_eth_an_household_eth16
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 13 
						univariable regression
						multivariable regression 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2, printed to $Tabfigdir
						complete case analysis	
==============================================================================*/

* Open a log file

cap log close
macro drop hr
log using "$Logdir/13a_eth_an_household_eth16", replace t 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table7_hh_eth16.txt, write text replace
file write tablecontent ("Table 6: Ethnicity and household composition - Complete Case Analysis") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities") _tab _tab  _n
file write tablecontent _tab _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n



foreach i of global outcomes {
	forvalues eth=1/11 {
		drop if  `eth'==2  & "`i'"=="icu"
		
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear
keep if eth16==`eth'

/* Sense check outcomes=======================================================*/ 
safetab eth16
safetab hh_total_cat `i', missing row

*household category should exclude people living in a care home but double check
safetab hh_total_cat carehome
drop if carehome==1
safetab hh_total_cat `i', missing row

/* Main hh_model=================================================================*/

/* Univariable hh_model */ 

stcox i.hh_total_cat, nolog
estimates save "$Tempdir/hh_crude_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_`i'_eth16_`eth'", replace) idstr("crude_`i'_eth16_`eth'") 
local hr "`hr' "$Tempdir/crude_`i'_eth16_`eth'" "


/* Multivariable models */ 
*Age and gender
stcox i.hh_total_cat i.male age1 age2 age3, strata(stp) nolog
estimates save "$Tempdir/hh_model0_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_`i'_eth16_`eth'", replace) idstr("model0_`i'_eth16_`eth'")
local hr "`hr' "$Tempdir/model0_`i'_eth16_`eth'" "
 

* Age, Gender, IMD

stcox i.hh_total_cat i.male age1 age2 age3 i.imd, strata(stp) nolog
if _rc==0{
estimates
estimates save "$Tempdir/hh_model1_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_`i'_eth16_`eth'", replace) idstr("model1_`i'_eth16_`eth'") 
local hr "`hr' "$Tempdir/model1_`i'_eth16_`eth'" "
}
else di "WARNING MODEL1 DID NOT FIT (OUTCOME `i')"


* Age, Gender, IMD and Comorbidities 
stcox i.hh_total_cat i.male age1 age2 age3 	i.imd			///
										bmi							///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.htdiag_or_highbp		 	///	
										i.asthma					///
										chronic_respiratory_disease ///
										i.chronic_cardiac_disease	///
										i.diabcat 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.egfr60						///
										i.esrf						///
										i.other_immuno		 		///
										i.ra_sle_psoriasis, strata(stp) nolog		
if _rc==0{
estimates
estimates save "$Tempdir/hh_model2_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_`i'_eth16_`eth'", replace) idstr("model2_`i'_eth16_`eth'") 
local hr "`hr' "$Tempdir/model2_`i'_eth16_`eth'" "
}
else di "WARNING MODEL2 DID NOT FIT (OUTCOME `i')"
										
									
/* Print table================================================================*/ 
*  Print the results for the main hh_model 

local labeth: label eth16 `eth'

* Column headings 
file write tablecontent ("`labeth': `i'") _n

* Row headings
local lab1: label hh_total_cat 1
local lab2: label hh_total_cat 2
local lab3: label hh_total_cat 3

/* counts */
 
* First row, hh_cat =  1 (1-2 ppl) reference cat
	safecount if hh_total_cat==1
	local denominator = r(N)
	safecount if hh_total_cat ==1 & `i' == 1
	local event = r(N)
    bysort hh_total_cat: egen total_follow_up = total(_t)
	su total_follow_up if hh_total_cat == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _n
	
* Subsequent household categories

forvalues hh=2/3 {
	safecount if hh_total_cat==`hh'
	local denominator = r(N)
	safecount if hh_total_cat == `hh' & `i' == 1
	local event = r(N)
	su total_follow_up if hh_total_cat == `hh'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`hh''") _tab (`denominator') _tab  (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	 estimates use "$Tempdir/hh_crude_`i'_eth16_`eth'" 
	 lincom `hh'.hh_total_cat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	 estimates clear
	 estimates use "$Tempdir/hh_model0_`i'_eth16_`eth'" 
	 lincom `hh'.hh_total_cat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	 estimates clear
	 estimates use "$Tempdir/hh_model1_`i'_eth16_`eth'" 
	 lincom `hh'.hh_total_cat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	 estimates clear
	 estimates use "$Tempdir/hh_model2_`i'_eth16_`eth'" 
	 lincom `hh'.hh_total_cat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _n
	 estimates clear
}  //end household categories

}  //end eth16
} //end outcomes

file close tablecontent

************************************************create forestplot dataset
dsconcat `hr'
duplicates drop

split idstr, p(_)
ren idstr1 model
ren idstr2 outcome
ren idstr3 eth16
drop idstr4
gen hh_total_cat=substr(parm, 1,1) if regexm(parm, "hh")

*save dataset for later
outsheet using "$Tabfigdir/FP_household_eth16.txt", replace


* Close log file 
log close

insheet using $Tabfigdir/table7_hh_eth16.txt, clear
