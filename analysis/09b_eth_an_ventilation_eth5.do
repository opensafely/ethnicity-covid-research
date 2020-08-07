/*==============================================================================
DO FILE NAME:			09a_eth_an_ventilation_eth5
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 06 
						univariable regression
						multivariable regression 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table and foresplot, printed to analysis/$outdir
*dont cluster by STP becuase model does not converge							
==============================================================================*/

* Open a log file

cap log close
log using $logdir\09a_eth_an_ventilation_eth5, replace text

cap file close tablecontent
file open tablecontent using $Tabfigdir/table3_ventilated_eth5.txt, write text replace
file write tablecontent ("Table 3: Association between ethnicity and Ventilation - Complete Case Analysis") _n

file write tablecontent _tab ("Number of events") _tab ("Univariable") _tab _tab ("Age/SexAdjusted") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("+ co-morbidities") _tab _tab 	("+ household size)") _tab _tab _n

file write tablecontent _tab _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _n



* Open Stata dataset
use "$Tempdir/analysis_dataset.dta", clear

gen ventilated=0
replace ventilated=1 if was_ventilated_flag==1

/* Restrict to those ever admitted to ICU=======================================================*/ 
keep if icu==1
count


/* Sense check outcomes=======================================================*/ 

safetab eth5 ventilated , missing row

/* Main Model=================================================================*/

/* Univariable model */ 

logistic ventilated i.eth5, nolog
estimates save "$Tempdir/crude_ventilated_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_ventilated_eth5", replace) idstr("crude_ventilated_eth5") 

/* Multivariable models */ 
*Age Gender
clogit ventilated i.eth5 i.male age1 age2 age3, strata(stp) or nolog
if _rc==0{
estimates
estimates save "$Tempdir/model0_ventilated_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_ventilated_eth5", replace) idstr("model0_ventilated_eth5") 
}
else di "WARNING MODEL0 DID NOT FIT (OUTCOME `outcome')"

* Age, Gender, IMD
clogit ventilated i.eth5 i.male age1 age2 age3 i.imd, strata(stp) or nolog
if _rc==0{
estimates
estimates save "$Tempdir/model1_ventilated_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_ventilated_eth5", replace) idstr("model1_ventilated_eth5") 
}
else di "WARNING MODEL1 DID NOT FIT (OUTCOME `outcome')"


* Age, Gender, IMD and Comorbidities  
clogit ventilated  i.eth5 i.male age1 age2 age3 i.imd 							///
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
estimates save "$Tempdir/model2_ventilated_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_ventilated_eth5", replace) idstr("model2_ventilated_eth5") 
}
else di "WARNING MODEL2 DID NOT FIT (OUTCOME `outcome')"

* Age, Gender, IMD and Comorbidities and household size

* Age, Gender, IMD and Comorbidities  and household size and carehome
clogit ventilated  i.eth5 i.male age1 age2 age3 i.imd i.hh_total_cat i.carehome	///
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
estimates save "$Tempdir/model3_ventilated_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_ventilated_eth5", replace) idstr("model3_ventilated_eth5") 
}
else di "WARNING MODEL3 DID NOT FIT (OUTCOME `outcome')"

/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("Outcome: ventilated") _n

* Row headings 
local lab1: label eth5 1
local lab2: label eth5 2
local lab3: label eth5 3
local lab4: label eth5 4
local lab5: label eth5 5

/* Counts */
 
* First row, eth5 = 1 (White) reference cat
	count if eth5 == 1 & ventilated == 1
	local event = r(N)
	
	file write tablecontent  ("`lab1'") _tab (`event') _tab ("1.00") _tab _tab ("1.00") _tab _tab ("1.00") _tab _tab ("1.00")  _tab _tab ("1.00") _n
	
* Subsequent ethnic groups
forvalues eth=2/5 {
	
	count if eth5 == `eth' & ventilated == 1
	local event = r(N)
	file write tablecontent  ("`lab`eth''") _tab   (`event') _tab
	estimates use "$Tempdir/crude_ventilated_eth5" 
	lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model0_ventilated_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model1_ventilated_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model2_ventilated_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model3_ventilated_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab ("(") %4.2f (r(lb)) (" - ") %4.2f (r(ub)) (")") _n
}  //end ethnic group

file close tablecontent


/* Foresplot================================================================*/ 

dsconcat "$Tempdir/crude_ventilated_eth5" "$Tempdir/model0_ventilated_eth5" "$Tempdir/model1_ventilated_eth5" "$Tempdir/model2_ventilated_eth5" "$Tempdir/model3_ventilated_eth5"
duplicates drop

split idstr, p(_)
drop idstr
ren idstr1 model
ren idstr2 outcome
drop idstr3 


*keep ORs for ethnic group
keep if label=="Eth 16 collapsed"
drop label

gen eth5=1 if regexm(parm, "1b")
forvalues i=2/5 {
	replace eth5=`i' if regexm(parm, "`i'.eth5")
}

drop parm eq
order outcome model eth5

label define eth5 	///
						1 "White" ///
						2 "South Asian" ///
						3 "Black" ///
						4 "Mixed" ///
						5 "Other" 
label values eth5 eth5

graph set window 
gen num=[_n]
sum num


gen adjusted="Age-sex" if model=="model0"
replace adjusted="Age-sex-IMD" if model=="model1"
replace adjusted="+ co-morbidities" if model=="model2"
replace adjusted="+ hh-size/carehome" if model=="model3"
replace adjusted="Crude" if model=="crude"

*save dataset for later
outsheet using "$Tabfigdir/FP_ventilated_eth5.txt", replace

* Close log file 
log close

insheet using $Tabfigdir/table3_ventilated_eth5.txt, clear




