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
log using $logdir\13a_eth_an_household_eth16, replace t 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table7_eth16.txt, write text replace
file write tablecontent ("Table 6: Ethnicity and household composition - Complete Case Analysis") _n
file write tablecontent _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("+ co-morbidities") _tab _tab _n
file write tablecontent _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n



foreach i of global outcomes {
	forvalues eth=1/11 {
		
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear
keep if eth16==`eth'

/* Sense check outcomes=======================================================*/ 
safetab eth16
safetab hh_total_cat `i', missing row


/* Main hh_model=================================================================*/

/* Univariable hh_model */ 

stcox i.hh_total_cat 
estimates save "$Tempdir/hh_crude_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/hh_crude_`i'_eth16_`eth'", replace) idstr("hh_crude_`i'_eth16_`eth'") 
local hr "`hr' "$Tempdir/hh_crude_`i'_eth16_`eth'" "

/* Multivariable hh_models */ 
*Age and gender
stcox i.hh_total_cat i.male age1 age2 age3
estimates save "$Tempdir/hh_model0_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/hh_model0_`i'_eth16_`eth'", replace) idstr("hh_model0_`i'_eth16_`eth'")
local hr "`hr' "$Tempdir/hh_crude_`i'_eth16_`eth'" " 

* Age, Gender, IMD
* Age fit as spline

noi cap stcox i.hh_total_cat i.male age1 age2 age3 i.imd, strata(stp)
if _rc==0{
estimates
estimates save "$Tempdir/hh_model1_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/hh_model1_`i'_eth16_`eth'", replace) idstr("hh_model1_`i'_eth16_`eth'")
local hr "`hr' "$Tempdir/hh_crude_`i'_eth16_`eth'" " 
}
else di "WARNING hh_model1 DID NOT FIT (OUTCOME `outcome')"


* Age, Gender, IMD and Comorbidities  
noi cap stcox i.hh_total_cat i.male age1 age2 age3 	i.imd							///
										bmi							///
										gp_consult_safecount			///
										i.smoke_nomiss				///
										i.htdiag_or_highbp		 	///	
										i.asthma					///
										i.chronic_cardiac_disease	///
										i.dm_type 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.ckd						///
										i.esrf						///
										i.perm_immunodef 			///
										i.temp_immunodef 			///
										i.other_immuno		 		///
										i.ra_sle_psoriasis, strata(stp)		
if _rc==0{
estimates
estimates save "$Tempdir/hh_model2_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/hh_model2_`i'_eth16_`eth'", replace) idstr("hh_model2_`i'_eth16_`eth'") 
local hr "`hr' "$Tempdir/hh_crude_`i'_eth16_`eth'" "
}
else di "WARNING hh_model2 DID NOT FIT (OUTCOME `outcome')"

										
									
/* Print table================================================================*/ 
*  Print the results for the main hh_model 

local labeth: label eth16 `eth'

* Column headings 
file write tablecontent ("Ethnic group: `labeth', Outcome: `i'") _n

* Row headings
local lab0: label hh_total_cat 0 
local lab1: label hh_total_cat 1
local lab2: label hh_total_cat 2
local lab3: label hh_total_cat 3

/* counts */
 
* First row, hh_cat =  0 (1-2 ppl) reference cat
	safecount if hh_total_cat ==0 & `i' == 1
	local event = r(N)
    bysort hh_total_cat: egen total_follow_up = total(_t)
	su total_follow_up if hh_total_cat == 0
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab0'") _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _n
	
* Subsequent household categories
forvalues hh=1/3 {
	safecount if hh_total_cat == `hh' & `i' == 1
	local event = r(N)
	su total_follow_up if hh_total_cat == `hh'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`hh''") _tab   (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	cap estimates use "$Tempdir/hh_crude_`i'_eth16_`eth'" 
	cap cap lincom `hh'.hh_total_cat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/hh_model0_`i'_eth16_`eth'" 
	cap cap lincom `hh'.hh_total_cat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/hh_model1_`i'_eth16_`eth'" 
	cap cap lincom `hh'.hh_total_cat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/hh_model2_`i'_eth16_`eth'" 
	cap cap lincom `hh'.hh_total_cat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n
	cap estimates clear
}  //end household categories

}  //end eth16
} //end outcomes

file close tablecontent

************************************************create forestplot dataset
dsconcat `hr'
duplicates drop

split idstr, p(_)
ren idstr2 model
ren idstr3 outcome
ren idstr5 eth16
drop idstr idstr1 idstr4


*keep ORs for household
keep if regexm(label, "household")
drop label

gen hh_cat=0 if regexm(parm, "0b")
forvalues i=1/3 {
	replace hh_cat=`i' if regexm(parm, "`i'.hh_total_cat")
}

drop parm  stderr z 
order outcome model eth16 hh_cat

drop if eth=="eth16"
destring eth16, replace
label define eth16 	///
						1 "British or Mixed British" ///
						2 "Irish" ///
						3 "Other White" ///
						4 "Indian" ///
						5 "Pakistani" ///
						6 "Bangladeshi" ///					
						7 "Caribbean" ///
						8 "African" ///
						9 "Chinese" ///
						10 "All mixed" ///
						11 "All Other" 
label values eth16 eth16

label define hh_cat	0 "1-2" ///
						1 "3-5" ///
						2 "6-9"	///						
						3 "10+" 
label values hh_cat hh_cat

graph set window 
gen num=[_n]
sum num

gen adjusted="Crude" if model=="crude"
replace adjusted="Age-sex" if model=="model0"
replace adjusted="Age-sex-IMD" if model=="model1"
replace adjusted="+ co-morbidities" if model=="model2"

*save dataset for later
outsheet using "$Tabfigdir/FP_household_eth16.txt", replace


* Close log file 
log close

insheet using $Tabfigdir/table7_eth16.txt, clear
insheet using "$Tabfigdir/FP_household_eth16.txt", clear
