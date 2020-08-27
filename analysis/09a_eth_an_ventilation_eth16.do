/*==============================================================================
DO FILE NAME:			09a_eth_an_ventilation_eth16
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 06 
						univariable regression
						multivariable regression 
DATASETS USED:			data in memory ($tempdir/analysis_dataset)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table and foresplot, printed to analysis/$outdir
*dont cluster by STP becuase model does not converge							
==============================================================================*/

* Open a log file

cap log close
log using "$Logdir/09a_eth_an_ventilation_eth16", replace text

cap file close tablecontent
file open tablecontent using $Tabfigdir/table3_ventilated_eth16.txt, write text replace
file write tablecontent ("Table 3: Odds of receiving invasive mechanical ventilation - Complete Case Analysis") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("%") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities") _tab _tab 	("plus hh size/carehome")  _tab _tab  _n
file write tablecontent _tab _tab _tab _tab   ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _n



* Open Stata dataset
use "$Tempdir/analysis_dataset.dta", clear

*drop irish for icu due to small numbers
drop if eth16==2 


gen ventilated=0
replace ventilated=1 if was_ventilated_flag==1

/* Restrict to those ever admitted to ICU=======================================================*/ 
keep if icu==1
count


/* Sense check outcomes=======================================================*/ 

safetab eth16 ventilated , missing row

/* Main Model=================================================================*/

/* Univariable model */ 

logistic ventilated i.eth16 i.stp, nolog

estimates save "$Tempdir/crude_ventilated_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_ventilated_eth16", replace) idstr("crude_ventilated_eth16") 

/* Multivariable models */ 
*Age Gender
logistic ventilated i.eth16 i.male age1 age2 age3 i.stp, nolog
estimates save "$Tempdir/model0_ventilated_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_ventilated_eth16", replace) idstr("model0_ventilated_eth16") 

* Age, Gender, IMD
logistic ventilated i.eth16 i.male age1 age2 age3 i.imd i.stp, nolog
estimates save "$Tempdir/model1_ventilated_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_ventilated_eth16", replace) idstr("model1_ventilated_eth16") 


* Age, Gender, IMD and Comorbidities  
logistic ventilated i.eth16 i.male age1 age2 age3 	i.imd						///
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
										i.ra_sle_psoriasis i.stp, nolog		
										
estimates save "$Tempdir/model2_ventilated_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_ventilated_eth16", replace) idstr("model2_ventilated_eth16") 


* Age, Gender, IMD and Comorbidities  and household size and carehome
logistic ventilated i.eth16 i.male age1 age2 age3 	i.imd						///
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
										i.hh_total_cat i.carehome i.stp, nolog		
										
estimates save "$Tempdir/model3_ventilated_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_ventilated_eth16", replace) idstr("model3_ventilated_eth16") 

/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("ventilated") _n

* Row headings 
local lab1: label eth16 1
local lab2: label eth16 2
local lab3: label eth16 3
local lab4: label eth16 4
local lab5: label eth16 5
local lab6: label eth16 6
local lab7: label eth16 7
local lab8: label eth16 8
local lab9: label eth16 9
local lab10: label eth16 10
local lab11: label eth16 11
local lab12: label eth16 10
local lab13: label eth16 11
local lab14: label eth16 14

/* Counts */
 
* First row, eth16 = 1 (White) reference cat
	qui safecount if eth16==1
	local denominator = r(N)
	qui safecount if eth16 == 1 & ventilated == 1
	local event = r(N)
	local pct =(`event'/`denominator')
	
	file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %3.2f (`pct') _tab
	file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _tab _tab ("1.00") _n
	
* Subsequent ethnic groups
forvalues eth=3/11 {
	qui safecount if eth16==`eth'
	local denominator = r(N)
	qui safecount if eth16 == `eth' & ventilated == 1
	local event = r(N)
	local pct =(`event'/`denominator')
	file write tablecontent  ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %3.2f (`pct') _tab
	estimates use "$Tempdir/crude_ventilated_eth16" 
	lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model0_ventilated_eth16" 
	cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model1_ventilated_eth16" 
	cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model2_ventilated_eth16" 
	cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model3_ventilated_eth16" 
	cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _n
}  //end ethnic group

file close tablecontent


/* Foresplot================================================================*/ 

dsconcat "$Tempdir/crude_ventilated_eth16" "$Tempdir/model0_ventilated_eth16" "$Tempdir/model1_ventilated_eth16" "$Tempdir/model2_ventilated_eth16" "$Tempdir/model3_ventilated_eth16"
duplicates drop

split idstr, p(_)
drop idstr
ren idstr1 model
ren idstr2 outcome
drop idstr3 


*save dataset for later
outsheet using "$Tabfigdir/FP_ventilated_eth16.txt", replace

* Close log file 
log close

insheet using $Tabfigdir/table3_ventilated_eth16.txt, clear




