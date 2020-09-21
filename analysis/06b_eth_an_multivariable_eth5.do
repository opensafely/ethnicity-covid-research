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
file open tablecontent using $Tabfigdir/table2_eth5.txt, write text replace
file write tablecontent ("Table 2: Association between ethnicity in 16 categories and COVID-19 outcomes - Complete Case Analysis") _n
file write tablecontent _tab ("Denominator") _tab ("Event") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("plus co-morbidities") _tab _tab 	("plus hh size/carehome") _tab _tab 	("no carehomes") _tab _tab 	("carehomes only")  _tab _tab  _n
file write tablecontent _tab _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab _tab _n



foreach i of global outcomes {
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear
safetab eth5 `i', missing row
} //end outcomes

foreach i of global outcomes {
	di "`i'"
	
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear

*drop irish for icu due to small numbers
*drop if eth5==2 & "`i'"=="icu"


/* Main Model=================================================================*/

/* Univariable model */ 

stcox i.eth5, strata(stp) nolog
estimates save "$Tempdir/crude_`i'_eth5", replace 
eststo model1
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_`i'_eth5", replace) idstr("crude_`i'_eth5") 
local hr "`hr' "$Tempdir/crude_`i'_eth5" "


/* Multivariable models */ 
*Age and gender
stcox i.eth5 i.male age1 age2 age3, strata(stp) nolog
estimates save "$Tempdir/model0_`i'_eth5", replace 
eststo model2

parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_`i'_eth5", replace) idstr("model0_`i'_eth5")
local hr "`hr' "$Tempdir/model0_`i'_eth5" "
 

* Age, Gender, IMD

stcox i.eth5 i.male age1 age2 age3 i.imd, strata(stp) nolog
if _rc==0{
estimates
estimates save "$Tempdir/model1_`i'_eth5", replace 
eststo model3

parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_`i'_eth5", replace) idstr("model1_`i'_eth5") 
local hr "`hr' "$Tempdir/model1_`i'_eth5" "
}
else di "WARNING MODEL1 DID NOT FIT (OUTCOME `i')"

* Age, Gender, IMD and Comorbidities 
stcox i.eth5 i.male age1 age2 age3 	i.imd						///
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
										i.ra_sle_psoriasis, strata(stp) nolog		
if _rc==0{
estimates
estimates save "$Tempdir/model2_`i'_eth5", replace 
eststo model4

parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_`i'_eth5", replace) idstr("model2_`i'_eth5") 
local hr "`hr' "$Tempdir/model2_`i'_eth5" "
}
else di "WARNING MODEL2 DID NOT FIT (OUTCOME `i')"

										
* Age, Gender, IMD and Comorbidities  and household size and carehome
stcox i.eth5 i.male age1 age2 age3 	i.imd						///
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
										i.hh_total_cat, strata(stp) nolog		
estimates save "$Tempdir/model3_`i'_eth5", replace
eststo model5

parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_`i'_eth5", replace) idstr("model3_`i'_eth5") 
local hr "`hr' "$Tempdir/model3_`i'_eth5" "

* Age, Gender, IMD and Comorbidities  and household size no carehome
stcox i.eth5 i.male age1 age2 age3 	i.imd						///
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
										i.hh_total_cat if carehome==0, strata(stp) nolog		
estimates save "$Tempdir/model4_`i'_eth5", replace
eststo model6

parmest, label eform format(estimate p lb ub) saving("$Tempdir/model4_`i'_eth5", replace) idstr("model4_`i'_eth5") 
local hr "`hr' "$Tempdir/model4_`i'_eth5" "

* Age, Gender, IMD and Comorbidities carehomes only
stcox i.eth5 i.male age1 age2 age3 	i.imd						///
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
										if carehome==1, strata(stp) nolog		
estimates save "$Tempdir/model5_`i'_eth5", replace
eststo model7

parmest, label eform format(estimate p lb ub) saving("$Tempdir/model5_`i'_eth5", replace) idstr("model5_`i'_eth5") 
local hr "`hr' "$Tempdir/model5_`i'_eth5" "


/* Estout================================================================*/ 
esttab model1 model2 model3 model4 model5 model6 model7 using "$Tabfigdir/estout_table2_eth5.txt", b(a2) ci(2) label wide compress eform ///
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
local lab7: label eth5 7
local lab8: label eth5 8
local lab9: label eth5 9
local lab10: label eth5 10
local lab11: label eth5 11
local lab12: label eth5 12
local lab13: label eth5 13
local lab14: label eth5 14
local lab15: label eth5 15
local lab16: label eth5 16
local lab17: label eth5 17

/* counts */
 
* First row, eth5 = 1 (White British) reference cat
	qui safecount if eth5==1
	local denominator = r(N)
	qui safecount if eth5 == 1 & `i' == 1
	local event = r(N)
    bysort eth5: egen total_follow_up = total(_t)
	qui su total_follow_up if eth5 == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab1'") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _tab _tab ("1.00") _n
	
* Subsequent ethnic groups
forvalues eth=2/17 {
	qui safecount if eth5==`eth'
	local denominator = r(N)
	qui safecount if eth5 == `eth' & `i' == 1
	local event = r(N)
	qui su total_follow_up if eth5 == `eth'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`eth''") _tab (`denominator') _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	cap estimates use "$Tempdir/crude_`i'_eth5" 
	 cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model0_`i'_eth5" 
	 cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model1_`i'_eth5" 
	 cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model2_`i'_eth5" 
	 cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model3_`i'_eth5" 
	 cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model4_`i'_eth5" 
	 cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab
	cap estimates clear
	cap estimates use "$Tempdir/model5_`i'_eth5" 
	 cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") 	_n
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

insheet using $Tabfigdir/table2_eth5.txt, clear
insheet using $Tabfigdir/estout_table2_eth5.txt, clear

