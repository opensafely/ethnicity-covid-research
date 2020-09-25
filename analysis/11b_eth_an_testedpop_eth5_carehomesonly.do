/*==============================================================================
DO FILE NAME:			11b_eth_an_testedpop_eth5
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	Risk of test positive in people receiving a test 
						univariable regression
						multivariable regression 
DATASETS USED:			data in memory ($tempdir/analysis_dataset)
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2, printed to analysis/$outdir
						
							
==============================================================================*/

* Open a log file

cap log close
log using "$Logdir/11b_eth_an_testedpop_eth5", replace t

cap file close tablecontent
file open tablecontent using $Tabfigdir/table4_testedpop_eth5_carehomesonly.txt, write text replace
file write tablecontent ("Table 4: Odds of testing positive amongst those receiving a test - carehomes only") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("%") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities")   _n

file write tablecontent _tab _tab _tab _tab   ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _n



* Open Stata dataset
use "$Tempdir/analysis_dataset.dta", clear

safecount

*define population as anyone who has received a test
keep if tested==1
safecount

keep if carehome==1
safecount




/* Sense check outcomes=======================================================*/ 
safetab positivetest

safetab eth5 positivetest, missing row


/* Main Model=================================================================*/

/* Univariable model */ 

logistic positivetest i.eth5 i.stp, nolog 
estimates save "$Tempdir/crude_positivetest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_positivetest_eth5", replace) idstr("crude_positivetest_eth5") 
eststo model1


/* Multivariable models */ 
*Age Gender
logistic positivetest i.eth5 i.male age1 age2 age3 i.stp, nolog 
estimates save "$Tempdir/model0_positivetest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_positivetest_eth5", replace) idstr("model0_positivetest_eth5") 
eststo model2

* Age, Gender, IMD
logistic positivetest i.eth5 i.male age1 age2 age3 i.imd i.stp , nolog 
estimates save "$Tempdir/model1_positivetest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_positivetest_eth5", replace) idstr("model1_positivetest_eth5") 
eststo model3

* Age, Gender, IMD and Comorbidities  
cap logistic positivetest i.eth5 i.male age1 age2 age3 	i.imd						///
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
										
cap estimates save "$Tempdir/model2_positivetest_eth5", replace 
cap parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_positivetest_eth5", replace) idstr("model2_positivetest_eth5") 
cap eststo model4


/* Estout================================================================*/ 
cap esttab model1 model2 model3 model4   using "$Tabfigdir/estout_table4_testedpop_eth5_carehomesonly.txt", b(a2) ci(2) label wide compress eform ///
	title ("`i'") ///
	varlabels(`e(labels)') ///
	stats(N_sub) ///
	append 
eststo clear



/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("Positive Test") _n

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
	qui safecount if eth5 == 1 & positivetest == 1
	local event = r(N)
	local pct =(`event'/`denominator')
	file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %3.2f (`pct') _tab
	file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _tab _tab ("1.00") _n
	
* Subsequent ethnic groups
forvalues eth=2/6 {
	qui safecount if eth5==`eth'
	local denominator = r(N)
	qui safecount if eth5 == `eth' & positivetest == 1
	local event = r(N)
	local pct =(`event'/`denominator')
	file write tablecontent  ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %3.2f (`pct') _tab
	cap estimates use "$Tempdir/crude_positivetest_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model0_positivetest_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model1_positivetest_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model2_positivetest_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _n
}  //end ethnic group


file close tablecontent

/* Foresplot================================================================*/ 

dsconcat "$Tempdir/model0_positivetest_eth5"  "$Tempdir/model1_positivetest_eth5" "$Tempdir/model2_positivetest_eth5" 

split idstr, p(_)
drop idstr
ren idstr1 model
drop idstr2 idstr3 eq

*save dataset for later
outsheet using "$Tabfigdir/FP_testedpop_eth5_carehomesonly.txt", replace


* Close log file 
log close
insheet using "$Tabfigdir/table4_testedpop_eth5_carehomesonly.txt", clear
cap insheet using "$Tabfigdir/estout_table4_testedpop_eth5_carehomesonly.txt", clear









