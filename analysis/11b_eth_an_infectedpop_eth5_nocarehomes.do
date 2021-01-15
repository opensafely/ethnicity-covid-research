/*=============================================================================
DO FILE NAME:			11a_eth_an_infectedpop_eth5
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
						
							
==============================================================================*/
global outcomes "hes icu onscoviddeath ons_noncoviddeath onsdeath"
sysdir set PLUS ./analysis/adofiles
adopath + ./analysis/adofiles
sysdir



* Open a log file

cap log close
log using ./logs/11a_eth_an_infectedpop_eth5.log, replace t

cap file close tablecontent
file open tablecontent using ./output/table4_infectedpop_eth5_nocarehomes.txt, write text replace
file write tablecontent ("Table 3: Odds of testing positive amongst those receiving a test - No care homes") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("%") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities") _tab _tab 	("plus hh size")  _n

file write tablecontent _tab _tab _tab _tab   ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("95% CI") _tab ("95% CI") _n


foreach i of global outcomes {
* Open Stata dataset
use ./output/analysis_dataset.dta, clear

safecount

*define population as anyone who has received a test
keep if positivetest==1
safecount

keep if carehome==0
safecount



/* Sense check outcomes=======================================================*/ 
safetab positivetest `i'

safetab eth5 `i', missing row


/* Main Model=================================================================*/

/* Univariable model */ 

logistic `i' i.eth5 i.stp, nolog 
estimates save ./output/crude_`i'_eth5, replace 
parmest, label eform format(estimate p lb ub) saving(./output/crude_`i'_eth5, replace) idstr("crude_`i'_eth5") 
eststo model1
local hr "`hr' ./output/crude_`i'_eth5 "


/* Multivariable models */ 
*Age Gender
logistic `i' i.eth5 i.male age1 age2 age3 i.stp, nolog 
estimates save ./output/model0_`i'_eth5, replace 
parmest, label eform format(estimate p lb ub) saving(./output/model0_`i'_eth5, replace) idstr("model0_`i'_eth5") 
eststo model2
local hr "`hr' ./output/model0_`i'_eth5 "

* Age, Gender, IMD
logistic `i' i.eth5 i.male age1 age2 age3 i.imd i.stp , nolog 
estimates save ./output/model1_`i'_eth5, replace 
parmest, label eform format(estimate p lb ub) saving(./output/model1_`i'_eth5, replace) idstr("model1_`i'_eth5") 
eststo model3
local hr "`hr' ./output/model1_`i'_eth5 "

* Age, Gender, IMD and Comorbidities  
cap logistic `i' i.eth5 i.male age1 age2 age3 	i.imd						///
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
										
cap estimates save ./output/model2_`i'_eth5, replace 
parmest, label eform format(estimate p lb ub) saving(./output/model2_`i'_eth5, replace) idstr("model2_`i'_eth5") 
eststo model4
local hr "`hr' ./output/model2_`i'_eth5 "

* Age, Gender, IMD and Comorbidities  and household size 
cap logistic `i' i.eth5 i.male age1 age2 age3 	i.imd						///
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
										
cap estimates save ./output/model3_`i'_eth5, replace 
parmest, label eform format(estimate p lb ub) saving(./output/model3_`i'_eth5, replace) idstr("model3_`i'_eth5") 
eststo model5
local hr "`hr' ./output/model3_`i'_eth5 "

/* Estout================================================================*/ 
esttab model1 model2 model3 model4 model5   using ./output/estout_table4_infectedpop_eth5_nocarehomes.txt, b(a2) ci(2) label wide compress eform ///
	title ("`i'") ///
	varlabels(`e(labels)') ///
	stats(N_sub) ///
	append 
eststo clear

/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("`i'") _n

* eth5 labelled columns

local lab1: label eth5 1
local lab2: label eth5 2
local lab3: label eth5 3
local lab4: label eth5 4
local lab5: label eth5 5
local lab6: label eth5 6

/* Counts */
 
* First row, eth5 = 1 (White) reference cat
	qui safecount if eth5==1
	local denominator = r(N)
	qui safecount if eth5 == 1 & `i' == 1
	local event = r(N)
	local pct =(`event'/`denominator')
	file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %3.2f (`pct') _tab
	file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _tab _tab ("1.00") _n
	
* Subsequent ethnic groups
forvalues eth=2/6 {
	qui safecount if eth5==`eth'
	local denominator = r(N)
	qui safecount if eth5 == `eth' & `i' == 1
	local event = r(N)
	local pct =(`event'/`denominator')
	file write tablecontent  ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %3.2f (`pct') _tab
	cap estimates use ./output/crude_`i'_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model0_`i'_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model1_`i'_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model2_`i'_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use ./output/model3_`i'_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _n
}  //end ethnic group

} //end outcomes
file close tablecontent

************************************************create forestplot dataset
dsconcat `hr'
duplicates drop
split idstr, p(_)
ren idstr1 model
ren idstr2 outcome
drop idstr idstr3
tab model

*save dataset for later
outsheet using ./output/FP_infectedpop_eth5.txt, replace

* Close log file 
log close








