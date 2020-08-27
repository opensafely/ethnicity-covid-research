/*==============================================================================
DO FILE NAME:			15b_eth_an_comorbidities_eth5
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
log using "$Logdir/15b_eth_an_comorbidities_eth5", replace t 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table9_comorb_eth5.txt, write text replace
file write tablecontent ("Table 9: Ethnicity and comorbidities composition - Complete Case Analysis") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted")  _tab _tab 	("IMD, RF, household") _tab _tab  _n
file write tablecontent _tab _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab _n



foreach i of global outcomes3 {
	forvalues eth=1/5 {
		
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear
keep if eth5==`eth'

/* Sense check outcomes=======================================================*/ 
safetab eth5
safetab comorbidity_cat `i', missing row
}
}

foreach i of global outcomes3 {
	forvalues eth=1/5 {
		
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear
keep if eth5==`eth'

/* Main comorb_model=================================================================*/

/* Univariable comorb_model */ 
stcox i.comorbidity_cat, strata(stp) nolog
estimates save "$Tempdir/comorb_crude_`i'_eth5_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_`i'_eth5_`eth'", replace) idstr("crude_`i'_eth5_`eth'") 
local hr "`hr' "$Tempdir/crude_`i'_eth5_`eth'" "


/* Multivariable models */ 
*Age and gender
stcox i.comorbidity_cat i.male age1 age2 age3, strata(stp) nolog
estimates save "$Tempdir/comorb_model0_`i'_eth5_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_`i'_eth5_`eth'", replace) idstr("model0_`i'_eth5_`eth'")
local hr "`hr' "$Tempdir/model0_`i'_eth5_`eth'" "
 


* Age, Gender, IMD, BMI, HbA1c, BP, carehome and household
stcox i.comorbidity_cat i.male age1 age2 age3 	i.imd	///
										bmi	hba1c_pct bp_map	///
										i. hh_total_cat ///
										i.carehome , strata(stp) nolog		
estimates save "$Tempdir/comorb_model2_`i'_eth5_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_`i'_eth5_`eth'", replace) idstr("model2_`i'_eth5_`eth'") 
local hr "`hr' "$Tempdir/model2_`i'_eth5_`eth'" "
										
									
/* Print table================================================================*/ 
*  Print the results for the main comorb_model 

local labeth: label eth5 `eth'

* Column headings 
file write tablecontent ("`labeth': `i'") _n

* Row headings
local lab0: label comorbidity_cat 0
local lab1: label comorbidity_cat 1
local lab2: label comorbidity_cat 2
local lab3: label comorbidity_cat 3
local lab4: label comorbidity_cat 4

/* counts */
 
* First row, comorbidity_cat =  0
	qui count if comorbidity_cat== 0
	local denominator = r(N)
	qui count if comorbidity_cat ==0 & `i' == 1
	local event = r(N)
    bysort comorbidity_cat: egen total_follow_up = total(_t)
	su total_follow_up if comorbidity_cat == 0
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab0'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab  _n
	
* Subsequent comorbidities categories

forvalues hh=1/4 {
	qui count if comorbidity_cat==`hh'
	local denominator = r(N)
	qui count if comorbidity_cat == `hh' & `i' == 1
	local event = r(N)
	su total_follow_up if comorbidity_cat == `hh'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`hh''") _tab (`denominator') _tab  (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	 estimates use "$Tempdir/comorb_crude_`i'_eth5_`eth'" 
	 lincom `hh'.comorbidity_cat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	 estimates clear
	 estimates use "$Tempdir/comorb_model0_`i'_eth5_`eth'" 
	 lincom `hh'.comorbidity_cat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	 estimates clear
	 estimates use "$Tempdir/comorb_model2_`i'_eth5_`eth'" 
	 lincom `hh'.comorbidity_cat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _n
	 estimates clear
}  //end comorbidities categories

}  //end eth5
} //end outcomes

file close tablecontent

************************************************create forestplot dataset
dsconcat `hr'
duplicates drop
split idstr, p(_)
ren idstr1 model
ren idstr2 outcome
ren idstr4 eth5
drop idstr3 idstr5 idstr
gen comorbidity_cat=substr(parm, 1,1) if regexm(parm, "comorb")

*save dataset for later
outsheet using "$Tabfigdir/FP_comorbidities_eth5.txt", replace


* Close log file 
log close

insheet using $Tabfigdir/table9_comorb_eth5.txt, clear
