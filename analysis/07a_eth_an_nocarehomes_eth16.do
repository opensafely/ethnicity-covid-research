/*==============================================================================
DO FILE NAME:			07a_eth_an_nocarehomes_eth16
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 06 
						univariable regression
						nocarehomes regression 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2, printed to $Tabfigdir
						complete case analysis	
==============================================================================*/

* Open a log file

cap log close
macro drop hr
log using "$Logdir/07a_eth_an_nocarehomes_eth16", replace t 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table2_nocarehomes_eth16.txt, write text replace
file write tablecontent ("Table 2: Risk COVID-19 outcomes excluding care home residents- Complete Case Analysis") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities") _tab _tab 	("plus hh size/carehome")  _tab _tab  _n
file write tablecontent _tab _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n



foreach i of global outcomes {
	di "`i'"
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear

*drop those in care homes
safetab carehome, m
drop if carehome==1
/* Sense check outcomes=======================================================*/ 
safetab eth16 `i', missing row
}

foreach i of global outcomes {
	di "`i'"
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear

*drop those in care homes
drop if carehome==1

*drop irish for icu due to small numbers
drop if eth16==2 & "`i'"=="icu"

/* Main Model=================================================================*/

/* Univariable model */ 

stcox i.eth16, nolog
estimates save "$Tempdir/crude_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_`i'_eth16", replace) idstr("crude_`i'_eth16") 
local hr "`hr' "$Tempdir/crude_`i'_eth16" "


/* nocarehomes models */ 
*Age and gender
stcox i.eth16 i.male age1 age2 age3, strata(stp) nolog
estimates save "$Tempdir/model0_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_`i'_eth16", replace) idstr("model0_`i'_eth16")
local hr "`hr' "$Tempdir/model0_`i'_eth16" "
 

* Age, Gender, IMD

stcox i.eth16 i.male age1 age2 age3 i.imd, strata(stp) nolog
if _rc==0{
estimates
estimates save "$Tempdir/model1_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_`i'_eth16", replace) idstr("model1_`i'_eth16") 
local hr "`hr' "$Tempdir/model1_`i'_eth16" "
}
else di "WARNING MODEL1 DID NOT FIT (OUTCOME `i')"


* Age, Gender, IMD and Comorbidities 
stcox i.eth16 i.male age1 age2 age3 	i.imd			///
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
estimates save "$Tempdir/model2_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_`i'_eth16", replace) idstr("model2_`i'_eth16") 
local hr "`hr' "$Tempdir/model2_`i'_eth16" "
}
else di "WARNING MODEL2 DID NOT FIT (OUTCOME `i')"

										
* Age, Gender, IMD and Comorbidities  and household size and carehome
stcox i.eth16 i.male age1 age2 age3 i.imd i.hh_total_cat i.carehome	///
										bmi							///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.htdiag_or_highbp		 	///	
										i.asthma					///
										i.chronic_respiratory_disease ///
										i.chronic_cardiac_disease	///
										i.diabcat 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.egfr60					///
										i.esrf						///
										i.other_immuno		 		///
										i.ra_sle_psoriasis, strata(stp) nolog				
if _rc==0{
estimates
estimates save "$Tempdir/model3_`i'_eth16", replace
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_`i'_eth16", replace) idstr("model3_`i'_eth16") 
local hr "`hr' "$Tempdir/model3_`i'_eth16" "
}
else di "WARNING MODEL3 DID NOT FIT (OUTCOME `i')"

										
/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("`i'") _n

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

/* counts */
 
* First row, eth16 = 1 (White British) reference cat
	qui safecount if eth16==1
	local denominator = r(N)
	qui safecount if eth16 == 1 & `i' == 1
	local event = r(N)
    bysort eth16: egen total_follow_up = total(_t)
	qui su total_follow_up if eth16 == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _tab _tab ("1.00") _n
	
* Subsequent ethnic groups
forvalues eth=2/11 {
	qui safecount if eth16==`eth'
	local denominator = r(N)
	qui safecount if eth16 == `eth' & `i' == 1
	local event = r(N)
	qui su total_follow_up if eth16 == `eth'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	cap estimates use "$Tempdir/crude_`i'_eth16" 
	cap cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model0_`i'_eth16" 
	cap cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model1_`i'_eth16" 
	cap cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model2_`i'_eth16" 
	cap cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model3_`i'_eth16" 
	cap cap lincom `eth'.eth16, eform
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
outsheet using "$Tabfigdir/FP_nocarehomes_eth16.txt", replace

* Close log file 
log close

insheet using $Tabfigdir/table2_nocarehomes_eth16.txt, clear

