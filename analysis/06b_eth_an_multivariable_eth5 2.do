/*==============================================================================
DO FILE NAME:			06b_eth_an_multivariable_eth5
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 06 
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
log using "$Logdir/06b_eth_an_multivariable_eth5", replace t 

cap file close tablecontent
file open tablecontent using "$Tabfigdir/table2_eth5.txt", write text replace
file write tablecontent ("Table 2: Association between ethnicity in 16 categories and COVID-19 outcomes - Complete Case Analysis") _n
file write tablecontent _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities") _tab _tab 	("plus household size") _tab _tab _n
file write tablecontent _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n



foreach i of global outcomes {
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear

/* Sense check outcomes=======================================================*/ 

*safetab eth5 `i', missing row


/* Main Model=================================================================*/

/* Univariable model */ 

noi cap stcox i.eth5 
estimates save "$Tempdir/crude_`i'_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_`i'_eth5", replace) idstr("crude_`i'_eth5") 
local hr "`hr' "$Tempdir/crude_`i'_eth5" "


/* Multivariable models */ 
*Age and gender
noi cap stcox i.eth5 i.male age1 age2 age3, strata(stp)
estimates save "$Tempdir/model0_`i'_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_`i'_eth5", replace) idstr("model0_`i'_eth5")
local hr "`hr' "$Tempdir/model0_`i'_eth5" "
 

* Age, Gender, IMD
noi cap stcox i.eth5 i.male age1 age2 age3 i.imd, strata(stp)
if _rc==0{
estimates
estimates save "$Tempdir/model1_`i'_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_`i'_eth5", replace) idstr("model1_`i'_eth5") 
local hr "`hr' "$Tempdir/model1_`i'_eth5" "
}
else di "WARNING MODEL1 DID NOT FIT (OUTCOME `i')"


* Age, Gender, IMD and Comorbidities  
noi cap stcox i.eth5 i.male age1 age2 age3 	i.imd							///
										bmi							///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.htdiag_or_highbp		 	///	
										i.asthma					///
										i.chronic_cardiac_disease	///
										i.diabcat 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.ckd						///
										i.esrf						///
										i.other_immuno		 		///
										i.ra_sle_psoriasis, strata(stp)		
if _rc==0{
estimates
estimates save "$Tempdir/model2_`i'_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_`i'_eth5", replace) idstr("model2_`i'_eth5") 
local hr "`hr' "$Tempdir/model2_`i'_eth5" "
}
else di "WARNING MODEL2 DID NOT FIT (OUTCOME `i')"

										
* Age, Gender, IMD and Comorbidities  and household size
noi cap stcox i.eth5 i.male age1 age2 age3 i.imd i.hh_total_cat					///
										bmi							///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.htdiag_or_highbp		 	///	
										i.asthma					///
										i.chronic_cardiac_disease	///
										i.diabcat 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.ckd						///
										i.esrf						///
										i.other_immuno		 		///
										i.ra_sle_psoriasis, strata(stp)				
if _rc==0{
estimates
estimates save "$Tempdir/model3_`i'_eth5", replace
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_`i'_eth5", replace) idstr("model3_`i'_eth5") 
local hr "`hr' "$Tempdir/model3_`i'_eth5" "
}
else di "WARNING MODEL3 DID NOT FIT (OUTCOME `i')"
										
/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("Outcome: `i'") _n

* Row headings 
local lab1: label eth5 1
local lab2: label eth5 2
local lab3: label eth5 3
local lab4: label eth5 4
local lab5: label eth5 5

/* counts */
 
* First row, eth5 = 1 (White British) reference cat
	safecount if eth5 == 1 & `i' == 1
	local event = r(N)
    bysort eth5: egen total_follow_up = total(_t)
	qui su total_follow_up if eth5 == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab1'") _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _n
	
* Subsequent ethnic groups
forvalues eth=2/5 {

	safecount if eth5 == `eth' & `i' == 1
	local event = r(N)
	qui su total_follow_up if eth5 == `eth'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`eth''") _tab   (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	cap estimates use "$Tempdir/crude_`i'_eth5" 
	cap cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model0_`i'_eth5" 
	cap cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model1_`i'_eth5" 
	cap cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model2_`i'_eth5" 
	cap cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model3_`i'_eth5" 
	cap cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n
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
outsheet using "$Tabfigdir/FP_multivariable_eth5.txt", replace


* Close log file 
log close

