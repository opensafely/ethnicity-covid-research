/*==============================================================================
DO FILE NAME:			09b_eth_an_ventilation_eth5
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 06 
						univariable regression
						multivariable regression 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table and foresplot, printed to analysis/$outdir
*dont cluster by STP becuase model does not converge							
==============================================================================*/

* Open a log file

cap log close
log using "$Logdir/09b_eth_an_ventilation_eth5", replace text

cap file close tablecontent
file open tablecontent using $Tabfigdir/table3_ventilated_eth5.txt, write text replace
file write tablecontent ("Table 3: Odds of receiving invasive mechanical ventilation - Complete Case Analysis") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("%") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities") _tab _tab 	("plus hh size/carehome")  _tab _tab  _n
file write tablecontent _tab _tab _tab _tab   ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _n



* Open Stata dataset
use "$Tempdir/analysis_dataset.dta", clear

gen ventilated=0
replace ventilated=1 if was_ventilated_flag==1

/* Restrict to those ever admitted to ICU=======================================================*/ 
keep if icu==1
count


/* Sense check outcomes=======================================================*/ 

safetab eth5 ventilated , missing row

/* Main Model=================================================================*/

/* Univariable model */ 

melogit ventilated i.eth5  i.stp, nolog
estimates save "$Tempdir/crude_ventilated_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_ventilated_eth5", replace) idstr("crude_ventilated_eth5") 

/* Multivariable models */ 
*Age Gender
logistic ventilated i.eth5 i.male age1 age2 age3 i.stp, nolog	
estimates save "$Tempdir/model0_ventilated_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_ventilated_eth5", replace) idstr("model0_ventilated_eth5") 

* Age, Gender, IMD
logistic ventilated i.eth5 i.male age1 age2 age3 i.imd i.stp, nolog	
estimates save "$Tempdir/model1_ventilated_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_ventilated_eth5", replace) idstr("model1_ventilated_eth5") 

* Age, Gender, IMD and Comorbidities  
cap  melogit ventilated i.eth5 i.male age1 age2 age3 	i.imd						///
										bmi	hba1c_pct				///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension bp_map		 	///	
										i.asthma					///
										i.chronic_respiratory_disease ///
										i.chronic_cardiac_disease	///
										i.dm_type 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.egfr60					///
										i.esrf						///
										i.immunosuppressed	 		///
										i.ra_sle_psoriasis  i.stp, nolog	
										
estimates save "$Tempdir/model2_ventilated_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_ventilated_eth5", replace) idstr("model2_ventilated_eth5") 


* Age, Gender, IMD and Comorbidities  and household size and carehome
logistic ventilated i.eth5 i.male age1 age2 age3 	i.imd						///
										bmi	hba1c_pct				///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension bp_map		 	///	
										i.asthma					///
										i.chronic_respiratory_disease ///
										i.chronic_cardiac_disease	///
										i.dm_type 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.egfr60					///
										i.esrf						///
										i.immunosuppressed	 		///
										i.ra_sle_psoriasis			///
										i.hh_total_cat i.carehome  i.stp, nolog	
										
estimates save "$Tempdir/model3_ventilated_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_ventilated_eth5", replace) idstr("model3_ventilated_eth5") 


/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("ventilated") _n

* Row headings 
local lab1: label eth5 1
local lab2: label eth5 2
local lab3: label eth5 3
local lab4: label eth5 4
local lab5: label eth5 5

/* Counts */
 
* First row, eth5 = 1 (White) reference cat
	 safecount if eth5==1
	local denominator = r(N)
	 safecount if eth5 == 1 & ventilated == 1
	local event = r(N)
	local pct =(`event'/`denominator')
	
	file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %3.2f (`pct') _tab
	file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _tab _tab ("1.00") _n
	
* Subsequent ethnic groups
forvalues eth=2/5 {
	di "ethnic group `eth'"
	safecount if eth5==`eth'
	local denominator = r(N)
	 safecount if eth5 == `eth' & ventilated == 1
	local event = r(N)
	local pct =(`event'/`denominator')
	file write tablecontent  ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %3.2f (`pct') _tab
	estimates use "$Tempdir/crude_ventilated_eth5" 
	estimates
	lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	estimates clear
	estimates use "$Tempdir/model0_ventilated_eth5" 
	estimates
	lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	estimates clear
	estimates use "$Tempdir/model1_ventilated_eth5" 
	lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	estimates clear
	estimates use "$Tempdir/model2_ventilated_eth5" 
	lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	estimates clear
	estimates use "$Tempdir/model3_ventilated_eth5"
	estimates
	lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _n
}  //end ethnic group

file close tablecontent


/* Foresplot================================================================*/ 

dsconcat "$Tempdir/crude_ventilated_eth5" "$Tempdir/model0_ventilated_eth5" "$Tempdir/model1_ventilated_eth5" "$Tempdir/model2_ventilated_eth5" "$Tempdir/model3_ventilated_eth5"
duplicates drop

split idstr, p(_)
drop idstr
ren idstr1 model
ren idstr2 outcome
drop idstr3 

*save dataset for later
outsheet using "$Tabfigdir/FP_ventilated_eth5.txt", replace

* Close log file 
log close

insheet using $Tabfigdir/table3_ventilated_eth5.txt, clear




