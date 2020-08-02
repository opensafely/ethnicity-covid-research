/*==============================================================================
DO FILE NAME:			14a_eth_an_diabetes_eth16
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 13 
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
log using $logdir\14a_eth_an_diabetes_eth16, replace t 

cap file close tablecontent
file open tablecontent using $Tabfigdir/table8_eth16.txt, write text replace
file write tablecontent ("Table 8: Ethnicity and diabetes type - Complete Case Analysis") _n
file write tablecontent _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex Adjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("+ co-morbidities") _tab _tab _n
file write tablecontent _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n



foreach i of global outcomes {
	forvalues eth=1/11 {
		if  eth==2, continue
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear
keep if eth16==`eth'

/* Sense check outcomes=======================================================*/ 
safetab eth16
safetab diabcat `i', missing row


/* Main dm_model=================================================================*/

/* Univariable dm_model */ 

stcox i.diabcat 
estimates save "$Tempdir/dm_crude_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/dm_crude_`i'_eth16_`eth'", replace) idstr("dm_crude_`i'_eth16_`eth'") 
local hr "`hr' "$Tempdir/dm_crude_`i'_eth16_`eth'" "

/* Multivariable dm_models */ 
*Age and gender
stcox i.diabcat i.male age1 age2 age3, strata(stp)
if _rc==0{
estimates
estimates save "$Tempdir/dm_model0_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/dm_model0_`i'_eth16_`eth'", replace) idstr("dm_model0_`i'_eth16_`eth'")
local hr "`hr' "$Tempdir/dm_model0_`i'_eth16_`eth'" " 
}
else di "WARNING dm_model1 DID NOT FIT (OUTCOME `outcome')"


* Age, Gender, IMD
* Age fit as spline
noi cap stcox i.diabcat i.male age1 age2 age3 i.imd, strata(stp)
if _rc==0{
estimates
estimates save "$Tempdir/dm_model1_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/dm_model1_`i'_eth16_`eth'", replace) idstr("dm_model1_`i'_eth16_`eth'")
local hr "`hr' "$Tempdir/dm_model1_`i'_eth16_`eth'" " 
}
else di "WARNING dm_model1 DID NOT FIT (OUTCOME `outcome')"


* Age, Gender, IMD and Comorbidities  
noi cap stcox i.diabcat i.male age1 age2 age3 	i.imd							///
										bmi							///
										gp_consult_safecount			///
										i.smoke_nomiss				///
										i.htdiag_or_highbp		 	///	
										i.asthma					///
										i.chronic_respiratory_disease ///
										i.chronic_cardiac_disease	///
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
estimates save "$Tempdir/dm_model2_`i'_eth16_`eth'", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/dm_model2_`i'_eth16_`eth'", replace) idstr("dm_model2_`i'_eth16_`eth'") 
local hr "`hr' "$Tempdir/dm_model2_`i'_eth16_`eth'" "
}
else di "WARNING dm_model2 DID NOT FIT (OUTCOME `outcome')"

										
									
/* Print table================================================================*/ 
*  Print the results for the main dm_model 

local labeth: label eth16 `eth'

* Column headings 
file write tablecontent ("Ethnic group: `labeth', Outcome: `i'") _n

* Row headings
local lab0: label diabcat 0 
local lab1: label diabcat 1
local lab2: label diabcat 2
local lab3: label diabcat 3

/* counts */
 
* First row, dm_cat =  0 (1-2 ppl) reference cat
	safecount if diabcat ==0 & `i' == 1
	local event = r(N)
    bysort diabcat: egen total_follow_up = total(_t)
	su total_follow_up if diabcat == 0
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab0'") _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _n
	
* Subsequent diabetes categories
forvalues hh=1/3 {
	safecount if diabcat == `hh' & `i' == 1
	local event = r(N)
	su total_follow_up if diabcat == `hh'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`hh''") _tab   (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	cap estimates use "$Tempdir/dm_crude_`i'_eth16_`eth'" 
	cap cap lincom `hh'.diabcat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/dm_model0_`i'_eth16_`eth'" 
	cap cap lincom `hh'.diabcat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/dm_model1_`i'_eth16_`eth'" 
	cap cap lincom `hh'.diabcat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/dm_model2_`i'_eth16_`eth'" 
	cap cap lincom `hh'.diabcat, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n
	cap estimates clear
}  //end diabetes categories

}  //end eth16
} //end outcomes

file close tablecontent

************************************************create forestplot dataset
dsconcat `hr'
duplicates drop

split idstr, p(_)
ren idstr2 model
ren idstr3 outcome
ren idstr5 eth16
drop idstr idstr1 idstr4


*keep ORs for diabetes
keep if regexm(label, "diabetes")
drop label

gen dm_cat=0 if regexm(parm, "0b")
forvalues i=1/3 {
	replace dm_cat=`i' if regexm(parm, "`i'.diabcat")
}

drop parm  stderr z 
order outcome model eth16 dm_cat

drop if eth=="eth16"
destring eth16, replace
label define eth16 	///
						1 "British or Mixed British" ///
						2 "Irish" ///
						3 "Other White" ///
						4 "Indian" ///
						5 "Pakistani" ///
						6 "Bangladeshi" ///					
						7 "Caribbean" ///
						8 "African" ///
						9 "Chinese" ///
						10 "All mixed" ///
						11 "All Other" 
label values eth16 eth16

label define dm_cat 	1 "No diabetes" 			///
						2 "T1DM, controlled"		///
						3 "T1DM, uncontrolled" 		///
						4 "T2DM, controlled"		///
						5 "T2DM, uncontrolled"		///
						6 "Diabetes, no HbA1c"
label values dm_cat dm_cat

graph set window 
gen num=[_n]
sum num

gen adjusted="Crude" if model=="crude"
replace adjusted="Age-sex" if model=="model0"
replace adjusted="Age-sex-IMD" if model=="model1"
replace adjusted="+ co-morbidities" if model=="model2"

*save dataset for later
outsheet using "$Tabfigdir/FP_diabetes_eth16.txt", replace


* Close log file 
log close

insheet using $Tabfigdir/table8_eth16.txt, clear
insheet using "$Tabfigdir/FP_diabetes_eth16.txt", clear
