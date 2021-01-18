/*=============================================================================
DO FILE NAME:			12a_eth_an_infectedpop_eth16
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	Risk of test positive in people receiving a test 
						univariable regression
						multivariable regression 
DATASETS USED:			data in memory ($output/analysis_dataset)
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logs
						table2, printed to analysis/$outdir
						
	332990						
==============================================================================*/
global outcomes "hes icu onscoviddeath ons_noncoviddeath onsdeath"
sysdir set PLUS ./analysis/adofiles
adopath + ./analysis/adofiles
sysdir



* Open a log file

cap log close
log using ./logs/12a_eth_an_infectedpop_eth16.log, replace t

cap file close tablecontent
file open tablecontent using ./output/table4_infectedpop_eth16_nocarehomes.txt, write text replace
file write tablecontent ("Table 3: Odds of testing positive amongst those receiving a test - No care homes") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("%") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities") _tab _tab 	("plus hh size")  _n

file write tablecontent _tab _tab _tab _tab   ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("95% CI") _tab ("95% CI") _n


foreach i of global outcomes {
* Open Stata dataset
use ./output/analysis_dataset.dta, clear

*define population as anyone who has received a test
keep if positivetest==1
safecount

keep if carehome==0 
safecount

/* keep those with at least 30 days f-up prior to censoring date for each outcome =======================================================*/ 
gen fup=stime_`i'-positivetest_date
sum fup
drop if fup<30
sum fup

/* Create outcomes to be within 30 days of positivetest =======================================================*/ 

gen `i'_30=0
replace `i'_30=1 if (`i'_date - positivetest_date) <=30  & `i'_date <= stime_`i'
tab `i' `i'_30

/* Sense check outcomes=======================================================*/ 
safetab positivetest `i'_30

safetab ethnicity_16 `i'_30, missing row


/* Main Model=================================================================*/

/* Univariable model */ 

cap logistic `i'_30 i.ethnicity_16 i.stp, nolog 
cap estimates save ./output/crude_`i'_eth16, replace 
cap parmest, label eform format(estimate p lb ub) saving(./output/crude_`i'_eth16, replace) idstr("crude_`i'_eth16") 
cap eststo model1
local hr "`hr' ./output/crude_`i'_eth16 "


/* Multivariable models */ 
*Age Gender
cap logistic `i'_30 i.ethnicity_16 i.male age1 age2 age3 i.stp, nolog 
cap estimates save ./output/model0_`i'_eth16, replace 
cap parmest, label eform format(estimate p lb ub) saving(./output/model0_`i'_eth16, replace) idstr("model0_`i'_eth16") 
cap eststo model2
local hr "`hr' ./output/model0_`i'_eth16 "

* Age, Gender, IMD
cap logistic `i'_30 i.ethnicity_16 i.male age1 age2 age3 i.imd i.stp , nolog 
cap estimates save ./output/model1_`i'_eth16, replace 
cap parmest, label eform format(estimate p lb ub) saving(./output/model1_`i'_eth16, replace) idstr("model1_`i'_eth16") 
cap eststo model3
local hr "`hr' ./output/model1_`i'_eth16 "

* Age, Gender, IMD and Comorbidities  
cap logistic `i'_30 i.ethnicity_16 i.male age1 age2 age3 	i.imd						///
										i.bmicat_sa	i.hba1ccat			///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension i.bp_cat	 	///	
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
										i.ra_sle_psoriasis	i. stp, nolog 		
										
cap estimates save ./output/model2_`i'_eth16, replace 
cap parmest, label eform format(estimate p lb ub) saving(./output/model2_`i'_eth16, replace) idstr("model2_`i'_eth16") 
cap eststo model4
local hr "`hr' ./output/model2_`i'_eth16 "

* Age, Gender, IMD and Comorbidities  and household size 
cap logistic `i'_30 i.ethnicity_16 i.male age1 age2 age3 	i.imd						///
										i.bmicat_sa	i.hba1ccat			///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension i.bp_cat	 	///	
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
										i.hh_total_cat i.stp, nolog 		
										
cap estimates save ./output/model3_`i'_eth16, replace 
cap parmest, label eform format(estimate p lb ub) saving(./output/model3_`i'_eth16, replace) idstr("model3_`i'_eth16") 
cap eststo model5
local hr "`hr' ./output/model3_`i'_eth16 "

/* Estout================================================================*/ 
cap esttab model1 model2 model3 model4 model5  using ./output/estout_table4_infectedpop_eth16_nocarehomes.txt, b(a2) ci(2) label wide compress eform ///
	title ("`i'") ///
	varlabels(`e(labels)') ///
	stats(N_sub) ///
	append 
eststo clear



/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("`i'") _n

* eth16 labelled columns

local lab1: label ethnicity_16 1
local lab2: label ethnicity_16 2
local lab3: label ethnicity_16 3
local lab4: label ethnicity_16 4
local lab5: label ethnicity_16 5
local lab6: label ethnicity_16 6
local lab7: label ethnicity_16 7
local lab8: label ethnicity_16 8
local lab9: label ethnicity_16 9
local lab10: label ethnicity_16 10
local lab11: label ethnicity_16 11
local lab12: label ethnicity_16 12
local lab13: label ethnicity_16 13
local lab14: label ethnicity_16 14
local lab15: label ethnicity_16 15
local lab16: label ethnicity_16 16
local lab17: label ethnicity_16 17

/* Counts */
 
* First row, eth16 = 1 (White) reference cat
	qui safecount if ethnicity_16==1
	local denominator = r(N)
	qui safecount if ethnicity_16 == 1 & `i' == 1
	local event = r(N)
	local pct =(`event'/`denominator')
	file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %3.2f (`pct') _tab
	file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _tab _tab ("1.00") _n
	
* Subsequent ethnic groups
forvalues eth=2/17 {
	qui safecount if ethnicity_16==`eth'
	local denominator = r(N)
	qui safecount if ethnicity_16 == `eth' & `i' == 1
	local event = r(N)
	local pct =(`event'/`denominator')
	file write tablecontent  ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %3.2f (`pct') _tab
	cap estimates use ./output/crude_`i'_eth16" 
	cap lincom `eth'.ethnicity_16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model0_`i'_eth16" 
	cap lincom `eth'.ethnicity_16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model1_`i'_eth16" 
	cap lincom `eth'.ethnicity_16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model2_`i'_eth16" 
	cap lincom `eth'.ethnicity_16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model3_`i'_eth16" 
	cap lincom `eth'.ethnicity_16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _n
}  //end ethnic group

} //end outcomes
file close tablecontent

************************************************create forestplot dataset
cap dsconcat `hr'
cap duplicates drop
cap split idstr, p(_)
cap ren idstr1 model
cap ren idstr2 outcome
cap drop idstr idstr3
cap tab model

*save dataset for later
outsheet using ./output/FP_infectedpop_eth16.txt, replace

* Close log file 
log close







