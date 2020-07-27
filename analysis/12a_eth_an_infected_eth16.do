/*==============================================================================
DO FILE NAME:			12a_eth_an_infected_eth16
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
log using $logdir\12a_eth_an_infected_eth16, replace t 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table6_eth16.txt, write text replace
file write tablecontent ("Table 6: Ethnic differences secondary care outcomes amongst those with evidence of infection - Complete Case Analysis") _n
file write tablecontent _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("+ co-morbidities") _tab _tab 	("+ household size)") _tab _tab _n
file write tablecontent _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n



foreach i of global outcomes2 {
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'_infected.dta", clear

/* Sense check outcomes=======================================================*/ 

safetab eth16 `i', missing row


/* Main inf_model=================================================================*/

/* Univariable inf_model */ 

stcox i.eth16 
estimates save "$Tempdir/inf_crude_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/inf_crude_`i'_eth16", replace) idstr("inf_crude_`i'_eth16") 

/* Multivariable inf_models */ 
*Age and gender
stcox i.eth16 i.male age1 age2 age3
estimates save "$Tempdir/inf_model0_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/inf_model0_`i'_eth16", replace) idstr("inf_model0_`i'_eth16") 

* Age, Gender, IMD
* Age fit as spline

noi cap stcox i.eth16 i.male age1 age2 age3 i.imd, strata(stp)
if _rc==0{
estimates
estimates save "$Tempdir/inf_model1_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/inf_model1_`i'_eth16", replace) idstr("inf_model1_`i'_eth16") 
}
else di "WARNING inf_model1 DID NOT FIT (OUTCOME `outcome')"


* Age, Gender, IMD and Comorbidities  
noi cap stcox i.eth16 i.male age1 age2 age3 	i.imd							///
										bmi							///
										gp_consult_safecount			///
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
										i.perm_immunodef 			///
										i.temp_immunodef 			///
										i.other_immuno		 		///
										i.ra_sle_psoriasis, strata(stp)		
if _rc==0{
estimates
estimates save "$Tempdir/inf_model2_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/inf_model2_`i'_eth16", replace) idstr("inf_model2_`i'_eth16") 
}
else di "WARNING inf_model2 DID NOT FIT (OUTCOME `outcome')"

										
* Age, Gender, IMD and Comorbidities  and household size
noi cap stcox i.eth16 i.male age1 age2 age3 i.imd i.hh_total_cat					///
										bmi							///
										gp_consult_safecount			///
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
										i.perm_immunodef 			///
										i.temp_immunodef 			///
										i.other_immuno		 		///
										i.ra_sle_psoriasis, strata(stp)				
if _rc==0{
estimates
estimates save "$Tempdir/inf_model3_`i'_eth16", replace
parmest, label eform format(estimate p lb ub) saving("$Tempdir/inf_model3_`i'_eth16", replace) idstr("inf_model3_`i'_eth16") 
}
else di "WARNING inf_model3 DID NOT FIT (OUTCOME `outcome')"
										
/* Print table================================================================*/ 
*  Print the results for the main inf_model 


* Column headings 
file write tablecontent ("Outcome: `i'") _n

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
	safecount if eth16 == 1 & `i' == 1
	local event = r(N)
    bysort eth16: egen total_follow_up = total(_t)
	su total_follow_up if eth16 == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab1'") _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _n
	
* Subsequent ethnic groups
forvalues eth=2/11 {

	safecount if eth16 == `eth' & `i' == 1
	local event = r(N)
	su total_follow_up if eth16 == `eth'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`eth''") _tab   (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	cap estimates use "$Tempdir/inf_crude_`i'_eth16" 
	cap cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/inf_model0_`i'_eth16" 
	cap cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/inf_model1_`i'_eth16" 
	cap cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/inf_model2_`i'_eth16" 
	cap cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/inf_model3_`i'_eth16" 
	cap cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n
}  //end ethnic group


} //end outcomes

file close tablecontent

* Close log file 
log close

insheet using $Tabfigdir/table6_eth16.txt, clear

