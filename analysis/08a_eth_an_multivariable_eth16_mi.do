/*==============================================================================
DO FILE NAME:			08a_eth_an_multivariable_eth16_mi
PROJECT:				NSAID in COVID-19 
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 07
						univariable regression using multiple imputation for ethnicity
						multivariable regression using multiple imputation for ethnicity
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2_eth16_mi, printed to analysis/$outdir
						
https://stats.idre.ucla.edu/stata/seminars/mi_in_stata_pt1_new/						
							
==============================================================================*/

* Open a log file
cap log close
macro drop hr
log using $logdir\08a_eth_an_multivariable_eth16_mi, replace 


cap file close tablecontent
file open tablecontent using $Tabfigdir/table2_eth16_mi.txt, write text replace
file write tablecontent ("Table 2: Association between ethnicity in 16 categories and COVID-19 outcomes - Imputed ethnicity") _n
file write tablecontent _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("+ co-morbidities") _tab _tab 	("+ household size)") _tab _tab _n
file write tablecontent _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n

foreach i of global outcomes {
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear


*mi set the data
mi set mlong

*mi register 
mi register imputed eth16

*mi impute the dataset
mi impute mlogit eth16, add(10) rseed(2232)

*mi stset
mi	stset stime_`i', fail(`i') 	id(patient_id) enter(indexdate) origin(indexdate)

 
/* Main Model=================================================================*/

/* Univariable model */ 

noi cap mi estimate, dots eform: stcox i.eth16 
estimates save "$Tempdir/mi_crude_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/mi_crude_`i'_eth16", replace) idstr("mi_crude_`i'_eth16") 
local hr "`hr' "$Tempdir/mi_crude_`i'_eth16" "

/* Multivariable models */ 

* Age and Gender 
* Age fit as spline 
noi cap mi estimate, dots eform: stcox i.eth16 i.male age1 age2 age3, strata(stp)
estimates save "$Tempdir/mi_model0_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/mi_model0_`i'_eth16", replace) idstr("mi_model0_`i'_eth16") 
local hr "`hr' "$Tempdir/mi_model0_`i'_eth16" "

* Age, Gender, IMD

noi cap mi estimate, dots eform: stcox i.eth16 i.male age1 age2 age3 i.imd, strata(stp)
if _rc==0{
estimates
estimates save "$Tempdir/mi_model1_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/mi_model1_`i'_eth16", replace) idstr("mi_model1_`i'_eth16") 
local hr "`hr' "$Tempdir/mi_model1_`i'_eth16" "
}
else di "WARNING MODEL1 DID NOT FIT (OUTCOME `i')"



* Age, Gender imd and Comorbidities  
noi cap mi estimate, dots saving("$Tempdir/model2_`i'", replace) eform: stcox i.eth16 i.male age1 age2 age3 	i.imd		bmi							///
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
										i.ckd						///
										i.esrf						///
										i.other_immuno		 		///
										i.ra_sle_psoriasis, strata(stp)				
										
if _rc==0{
estimates
estimates save "$Tempdir/mi_model2_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/mi_model2_`i'_eth16", replace) idstr("mi_model2_`i'_eth16") 
local hr "`hr' "$Tempdir/mi_model2_`i'_eth16" "
}
else di "WARNING MODEL2 DID NOT FIT (OUTCOME `i')"

noi cap mi estimate, dots saving("$Tempdir/model3_`i'", replace) eform: stcox i.eth16 i.male age1 age2 age3 i.imd i.hh_total_cat				///
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
										i.ckd						///
										i.esrf						///
										i.other_immuno		 		///
										i.ra_sle_psoriasis, strata(stp)				
										
if _rc==0{
estimates
estimates save "$Tempdir/mi_model3_`i'_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/mi_model3_`i'_eth16", replace) idstr("mi_model3_`i'_eth16") 
local hr "`hr' "$Tempdir/mi_model3_`i'_eth16" "
}
else di "WARNING MODEL3 DID NOT FIT (OUTCOME `i')"

/* Print table================================================================*/ 

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

/* Counts */
 
* First row, eth16 = 1 (White British) reference cat
	qui count if eth16 == 1 & `i' == 1
	local event = r(N)
    bysort eth16: egen total_follow_up = total(_t)
	qui su total_follow_up if eth16 == 1
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	
	file write tablecontent  ("`lab1'") _tab (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab
	file write tablecontent ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _n
	
* Subsequent ethnic groups
forvalues eth=2/11 {

	qui count if eth16 == `eth' & `i' == 1
	local event = r(N)
	qui su total_follow_up if eth16 == `eth'
	local person_week = r(mean)/7
	local rate = 1000*(`event'/`person_week')
	file write tablecontent  ("`lab`eth''") _tab   (`event') _tab %10.0f (`person_week') _tab %3.2f (`rate') _tab  
	cap estimates use "$Tempdir/crude_`i'" 
	cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model1_`i'" 
	cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model2_`i'" 
	cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model3_`i'" 
	cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n
}  //end ethnic group


} //end outcomes

file close tablecontent

************************************************create forestplot dataset
dsconcat `hr'
duplicates drop
split idstr, p(_)
ren idstr2 model
ren idstr3 outcome
drop idstr*
tab model

*keep ORs for ethnicity
keep if regexm(label, "Eth")
drop label

gen eth16=1 if regexm(parm, "1b")
forvalues i=2/11 {
	replace eth16=`i' if regexm(parm, "`i'.eth16")
}

drop parm  stderr dof t 
order outcome model eth16 

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

graph set window 
gen num=[_n]
sum num

gen adjusted="Crude" if model=="crude"
replace adjusted="Age-sex" if model=="model0"
replace adjusted="Age-sex-IMD" if model=="model1"
replace adjusted="+ co-morbidities" if model=="model2"
replace adjusted="+ household size" if model=="model3"

*save dataset for later
outsheet using "$Tabfigdir/FP_mi_eth16.txt", replace
save "$Tabfigdir/FP_mi_eth16.dta", replace


* Close log file 
log close







