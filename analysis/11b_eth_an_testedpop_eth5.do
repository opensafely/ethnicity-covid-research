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
log using $logdir\11b_eth_an_testedpop_eth5, replace t

cap file close tablecontent
file open tablecontent using $Tabfigdir/table5_eth5.txt, write text replace
file write tablecontent ("Table 2: Risk of testing positive amongst those receiving a test - Complete Case Analysis") _n
file write tablecontent _tab ("Number of events") _tab ("Total person-weeks") _tab ("Rate per 1,000") _tab ("Crude") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("+ co-morbidities") _tab _tab 	("+ household size)") _tab _tab _n
file write tablecontent _tab _tab _tab _tab   ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _tab ("HR") _tab ("95% CI") _n



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

logistic positivetest i.eth5 
estimates save "$Tempdir/crude_postest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_postest_eth5", replace) idstr("crude_postest_eth5") 

/* Multivariable models */ 
*Age gender
clogit positivetest i.eth5 i.male age1 age2 age3, strata(stp) or
if _rc==0{
estimates
estimates save "$Tempdir/model0_postest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_postest_eth5", replace) idstr("model0_postest_eth5") 
}
else di "WARNING MODEL1 DID NOT FIT (OUTCOME `outcome')"

* Age, Gender, IMD
* Age fit as spline in first instance, categorical below 

clogit positivetest i.eth5 i.male age1 age2 age3 i.imd, strata(stp) or
if _rc==0{
estimates
estimates save "$Tempdir/model1_postest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_postest_eth5", replace) idstr("model1_postest_eth5") 
}
else di "WARNING MODEL1 DID NOT FIT (OUTCOME `outcome')"

* Age, Gender, IMD and Comorbidities  
clogit positivetest i.eth5 i.male age1 age2 age3 	i.imd							///
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
estimates save "$Tempdir/model2_postest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_postest_eth5", replace) idstr("model2_postest_eth5") 
}
else di "WARNING MODEL2 DID NOT FIT (OUTCOME `outcome')"

* Age, Gender, IMD and Comorbidities and household size

clogit positivetest i.eth5 i.male age1 age2 age3 i.imd hh_size					///
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
estimates save "$Tempdir/model3_postest_eth5", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_postest_eth5", replace) idstr("model3_postest_eth5") 
}
else di "WARNING MODEL3 DID NOT FIT (OUTCOME `outcome')"

/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("Outcome: Positive Test") _n

* Row headings 
local lab1: label eth5 1
local lab2: label eth5 2
local lab3: label eth5 3
local lab4: label eth5 4
local lab5: label eth5 5

/* Counts */
 
* First row, eth5 = 1 (White) reference cat
	count if eth5 == 1 & positivetest == 1
	local event = r(N)
	file write tablecontent  ("`lab1'") _tab (`event') _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _n
	
* Subsequent ethnic groups
forvalues eth=2/5 {
	
	count if eth5 == `eth' & positivetest == 1
	local event = r(N)
	file write tablecontent  ("`lab`eth''") _tab   (`event') _tab
	cap estimates use "$Tempdir/crude_postest_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model1_postest_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model2_postest_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model3_postest_eth5" 
	cap lincom `eth'.eth5, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n
}  //end ethnic group


file close tablecontent

/* Foresplot================================================================*/ 

dsconcat  "$Tempdir/model1_postest_eth5" "$Tempdir/model2_postest_eth5" "$Tempdir/model3_postest_eth5"
duplicates drop

split idstr, p(_)
drop idstr
ren idstr1 model
drop idstr2 idstr3 eq


*keep ORs for ethnic group
keep if label=="Eth 5 categories"
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

graph set window 
gen num=[_n]
sum num

gen adjusted="Age-sex" if model=="model0"
replace adjusted="Age-sex-IMD" if model=="model1"
replace adjusted="+ co-morbidities" if model=="model2"
replace adjusted="+ household size" if model=="model3"

*Create one graph 
metan estimate min95 max95  if eth5!=1 ///
 , effect(Odds Ratio) null(1) lcols(eth5) dp(2) by(adjusted)  ///
	random nowt nosubgroup nooverall nobox graphregion(color(white)) scheme(sj)  	///
	title("Positive test amongst those tested", size(medsmall)) 	///
	t2title("complete case analysis", size(small)) 	///
	graphregion(margin(zero)) 
	graph export "$Tabfigdir\Forestplot_postest_eth5_tested.svg", replace  


* Close log file 
log close


insheet using "$Tabfigdir/table5_eth5.txt", clear









