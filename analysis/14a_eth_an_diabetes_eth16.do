/*==============================================================================
DO FILE NAME:			14a_eth_an_diabetes_eth16
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
**HBA1C NOT INCLUDED AS COVARIATE
* Open a log file

cap log close
macro drop hr
log using "$Logdir/14a_eth_an_diabetes_eth16", replace t 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table7_dm_eth16.txt, write text replace
file write tablecontent ("Table 6: Ethnicity and household composition - Complete Case Analysis") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities") _tab _tab  _n
file write tablecontent _tab _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n



foreach i of global outcomes3 {
	forvalues eth=1/11 {
		drop if  `eth'==2  & "`i'"=="icu"
		
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear
keep if eth16==`eth'

/* Sense check outcomes=======================================================*/ 
safetab eth16
safetab dm_type `i', missing row

foreach i of global outcomes3 {
	forvalues eth=1/11 {
		
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear
keep if eth16==`eth'
drop if  `eth'==2  & "`i'"=="icu"



/* Main dm_model=================================================================*/

/* Univariable dm_model */ 

stcox i.dm_type, strata(stp) nolog
estimates save "$Tempdir/dm_crude_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_`i'_eth16_`eth'", replace) idstr("crude_`i'_eth16_`eth'") 
local hr "`hr' "$Tempdir/crude_`i'_eth16_`eth'" "


/* Multivariable models */ 
*Age and gender
stcox i.dm_type i.male age1 age2 age3, strata(stp) nolog
estimates save "$Tempdir/dm_model0_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_`i'_eth16_`eth'", replace) idstr("model0_`i'_eth16_`eth'")
local hr "`hr' "$Tempdir/model0_`i'_eth16_`eth'" "
 

* Age, Gender, IMD

stcox i.dm_type i.male age1 age2 age3 i.imd, strata(stp) nolog
if _rc==0{
estimates
estimates save "$Tempdir/dm_model1_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_`i'_eth16_`eth'", replace) idstr("model1_`i'_eth16_`eth'") 
local hr "`hr' "$Tempdir/model1_`i'_eth16_`eth'" "
}
else di "WARNING MODEL1 DID NOT FIT (OUTCOME `i')"


* Age, Gender, IMD and Comorbidities 
stcox i.dm_type i.male age1 age2 age3 	i.imd						///
										bmi				///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension bp_map		 	///	
										i.asthma					///
										i.chronic_respiratory_disease ///
										i.chronic_cardiac_disease	///
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.egfr60					///
										i.esrf						///
										i.immunosuppressed	 		///
										i.ra_sle_psoriasis, strata(stp) nolog		
if _rc==0{
estimates
estimates save "$Tempdir/dm_model2_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_`i'_eth16_`eth'", replace) idstr("model2_`i'_eth16_`eth'") 
local hr "`hr' "$Tempdir/model2_`i'_eth16_`eth'" "
}
else di "WARNING MODEL2 DID NOT FIT (OUTCOME `i')"
										
* Age, Gender, IMD and Comorbidities plus care home and hh_cat
stcox i.dm_type i.male age1 age2 age3 	i.imd						///
										bmi				///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension bp_map		 	///	
										i.asthma					///
										i.chronic_respiratory_disease ///
										i.chronic_cardiac_disease	///
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.egfr60					///
										i.esrf						///
										i.immunosuppressed	 		///
										i.ra_sle_psoriasis			///
										i.hh_total_cat i.carehome, strata(stp) nolog		
if _rc==0{
estimates
estimates save "$Tempdir/dm_model3_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_`i'_eth16_`eth'", replace) idstr("model3_`i'_eth16_`eth'") 
local hr "`hr' "$Tempdir/model3_`i'_eth16_`eth'" "
}
else di "WARNING MODEL3 DID NOT FIT (OUTCOME `i')"
										
									
/* Print table================================================================*/ 
*  Print the results for the main dm_model 

local labeth: label eth16 `eth'

* Column headings 
file write tablecontent ("`labeth': `i'") _n

* Row headings
local lab0: label dm_type 0
local lab1: label dm_type 1
local lab2: label dm_type 2
local lab3: label dm_type 3

/* counts */
 
* First row, dm_type =  0 no diabetes
	safecount if dm_type==0
	local denominator = r(N)
	safecount if dm_type ==0 & `i' == 1
	local event = r(N)
    bysort dm_type: egen total_follow_up = total(_t)
	su total_follow_up if dm_type == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _n
	
* Subsequent diabetes categories

forvalues dm=1/3 {
	safecount if dm_type==`dm'
	local denominator = r(N)
	safecount if dm_type == `dm' & `i' == 1
	local event = r(N)
	su total_follow_up if dm_type == `dm'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`dm''") _tab (`denominator') _tab  (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	 estimates use "$Tempdir/dm_crude_`i'_eth16_`eth'" 
	 lincom `dm'.dm_type, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	 estimates clear
	 estimates use "$Tempdir/dm_model0_`i'_eth16_`eth'" 
	 lincom `dm'.dm_type, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	 estimates clear
	 estimates use "$Tempdir/dm_model1_`i'_eth16_`eth'" 
	 lincom `dm'.dm_type, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	 estimates clear
	 estimates use "$Tempdir/dm_model2_`i'_eth16_`eth'" 
	 lincom `dm'.dm_type, eform
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
gen dm_type=substr(parm, 1,1) if regexm(parm, "hh")

*save dataset for later
outsheet using "$Tabfigdir/FP_diabetes_eth16.txt", replace


* Close log file 
log close

insheet using $Tabfigdir/table7_dm_eth16.txt, clear
