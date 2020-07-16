/*==============================================================================
DO FILE NAME:			06a_an_models_nsaid
PROJECT:				NSAID in COVID-19 
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 06 
						univariable regression
						multivariable regression 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2, printed to analysis/$outdir
							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\06a_eth_an_multivariable_eth5, replace 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table2_eth5.txt, write text replace
file write tablecontent ("Table 2: Association between ethnicity in five categories and COVID-19 outcomes - Complete Case Analysis") _n
file write tablecontent _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("+ co-morbidities") _tab _tab 	("+ household size)") _tab _tab _n
file write tablecontent _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n



foreach i of global outcomes {
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear

/* Sense check outcomes=======================================================*/ 

tab eth5 `i', missing row


/* Main Model=================================================================*/

/* Univariable model */ 

stcox i.eth5 
estimates save "$Tempdir/crude_`i'", replace 

/* Multivariable models */ 

* Age and Gender 
* Age fit as spline in first instance, categorical below 

stcox i.eth5 i.male age1 age2 age3 i.imd, strata(stp)
estimates save "$Tempdir/model1_`i'", replace 

* Age, Gender and Comorbidities  
stcox i.eth5 i.male age1 age2 age3 	i.imd							///
										bmi							///
										gp_consult_count			///
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
										
estimates save "$Tempdir/model2_`i'", replace 

stcox i.eth5 i.male age1 age2 age3 i.imd hh_size					///
										bmi							///
										gp_consult_count			///
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
										
estimates save "$Tempdir/model3_`i'", replace

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

/* Counts */
 
* First row, eth5 = 1 (White) reference cat
	count if eth5 == 1 & `i' == 1
	local event = r(N)
    bysort eth5: egen total_follow_up = total(_t)
	su total_follow_up if eth5 == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab1'") _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _n
	
* Subsequent ethnic groups
forvalues eth=2/5 {

	count if eth5 == `eth' & `i' == 1
	local event = r(N)
	su total_follow_up if eth5 == `eth'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`eth''") _tab   (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	estimates use "$Tempdir/crude_`i'" 
	lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	estimates clear
	estimates use "$Tempdir/model1_`i'" 
	lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	estimates clear
	estimates use "$Tempdir/model2_`i'" 
	lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	estimates clear
	estimates use "$Tempdir/model3_`i'" 
	lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n
}  //end ethnic group


} //end outcomes

file close tablecontent

* Close log file 
log close

insheet using "$Tabfigdir/table2_eth5.txt", clear
save "$Tabfigdir/table2_eth5.dta", replace






