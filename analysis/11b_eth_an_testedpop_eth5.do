/*==============================================================================
DO FILE NAME:			11b_eth_an_testedpop_eth5
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	Risk of test positive in people receiving a test 
						univariable regression
						multivariable regression 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2, printed to analysis/$outdir
						
							
==============================================================================*/

* Open a log file

cap log close
log using "$Logdir/11b_eth_an_testedpop_eth5", replace t

cap file close tablecontent
file open tablecontent using $Tabfigdir/table5_testedpop_eth5.txt, write text replace
file write tablecontent ("Table 2: Odds of testing positive amongst those receiving a test - Complete Case Analysis") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("%") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities") _tab _tab 	("plus hh size/carehome")  _tab _tab  _n
file write tablecontent _tab _tab _tab _tab   ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _n



* Open Stata dataset
use "$Tempdir/analysis_dataset.dta", clear

safecount

*define population as anyone who has received a test
keep if tested==1
safecount




/* Sense check outcomes=======================================================*/ 
safetab positivetest

safetab eth5 positivetest, missing row


/* Main Model=================================================================*/

/* Univariable model */ 

logistic positivetest i.eth5, nolog
estimates save "$Tempdir/crude_positivetest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_positivetest_eth5", replace) idstr("crude_positivetest_eth5") 

/* Multivariable models */ 
*Age Gender
melogit positivetest i.eth5 i.male age1 age2 age3 || stp: , nolog
if _rc==0{
estimates
estimates save "$Tempdir/model0_positivetest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_positivetest_eth5", replace) idstr("model0_positivetest_eth5") 
}
else di "WARNING MODEL0 DID NOT FIT (OUTCOME `outcome')"

* Age, Gender, IMD
melogit positivetest i.eth5 i.male age1 age2 age3 i.imd || stp: , nolog
if _rc==0{
estimates
estimates save "$Tempdir/model1_positivetest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_positivetest_eth5", replace) idstr("model1_positivetest_eth5") 
}
else di "WARNING MODEL1 DID NOT FIT (OUTCOME `outcome')"


* Age, Gender, IMD and Comorbidities  
cap melogit positivetest i.eth5 i.male age1 age2 age3 	i.imd						///
										bmi	hba1c_pct				///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension bp_map		 	///	
										i.asthma					///
										chronic_respiratory_disease ///
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
										i.ra_sle_psoriasis || stp:, nolog		
										
if _rc==0{
estimates
estimates save "$Tempdir/model2_positivetest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_positivetest_eth5", replace) idstr("model2_positivetest_eth5") 
}
else di "WARNING MODEL2 DID NOT FIT (OUTCOME `outcome')"

* Age, Gender, IMD and Comorbidities  and household size and carehome
cap melogit positivetest i.eth5 i.male age1 age2 age3 	i.imd						///
										bmi	hba1c_pct				///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension bp_map		 	///	
										i.asthma					///
										chronic_respiratory_disease ///
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
										i.hh_total_cat i.carehome || stp:, nolog		
										
if _rc==0{
estimates
estimates save "$Tempdir/model3_positivetest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_positivetest_eth5", replace) idstr("model3_positivetest_eth5") 
}
else di "WARNING MODEL3 DID NOT FIT (OUTCOME `outcome')"

/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("Positive Test") _n

* Row headings 
local lab1: label eth5 1
local lab2: label eth5 2
local lab3: label eth5 3
local lab4: label eth5 4
local lab5: label eth5 5

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
forvalues eth=2/5 {
	qui safecount if eth5==`eth'
	local denominator = r(N)
	qui safecount if eth5 == `eth' & positivetest == 1
	local event = r(N)
	local pct =(`event'/`denominator')
	file write tablecontent  ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %3.2f (`pct') _tab
	estimates use "$Tempdir/crude_positivetest_eth5" 
	lincom `eth'.eth5, eform
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
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model3_positivetest_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _n
}  //end ethnic group

file close tablecontent



/* Foresplot================================================================*/ 

dsconcat "$Tempdir/model0_positivetest_eth5"  "$Tempdir/model1_positivetest_eth5" "$Tempdir/model2_positivetest_eth5" "$Tempdir/model3_positivetest_eth5"
duplicates drop

split idstr, p(_)
drop idstr
ren idstr1 model
drop idstr2 idstr3 eq


*keep ORs for ethnic group
keep if label=="Eth 16 collapsed"
drop label

gen eth5=1 if regexm(parm, "1b")
forvalues i=2/5 {
	replace eth5=`i' if regexm(parm, "`i'.eth5")
}

drop parm 
order  model eth5
label define eth5 	///
						1 "White" ///
						2 "South Asian" ///
						3 "Black" ///
						4 "Mixed" ///
						5 "Other" 
label values eth5 eth5
tab eth5,m

graph set window 
gen num=[_n]
sum num

gen adjusted="Age-sex" if model=="model0"
replace adjusted="+ IMD" if model=="model1"
replace adjusted="+ co-morbidities" if model=="model2"
replace adjusted="+ household size" if model=="model3"

*save dataset for later
outsheet using "$Tabfigdir/FP_testedpop_eth5.txt", replace


* Close log file 
log close


insheet using "$Tabfigdir/table5_testedpop_eth5.txt", clear









