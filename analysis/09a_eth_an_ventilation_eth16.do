/*==============================================================================
DO FILE NAME:			09a_eth_an_ventilation_eth16
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
log using $logdir\09a_eth_an_ventilation_eth16, replace text

cap file close tablecontent
file open tablecontent using $Tabfigdir/table3_eth16.txt, write text replace
file write tablecontent ("Table 3: Association between ethnicity and Ventilation - Complete Case Analysis") _n

file write tablecontent _tab ("Number of events") _tab ("Univariable") _tab _tab ("Age/Sex/IMD Adjusted") _tab _tab 	("+ co-morbidities") _tab _tab 	("+ household size)") _tab _tab _n

file write tablecontent _tab _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _tab ("OR") _tab ("95% CI") _n



* Open Stata dataset
use "$Tempdir/analysis_dataset.dta", clear

gen ventilated=0
replace ventilated=1 if was_ventilated_flag==1

/* Restrict to those ever admitted to ICU=======================================================*/ 
keep if icu==1
count


/* Sense check outcomes=======================================================*/ 

tab eth16 ventilated , missing row

/* Main Model=================================================================*/

/* Univariable model */ 

clogit ventilated i.eth16, strata(stp) or
estimates save "$Tempdir/crude_ventilated_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/crude_ventilated_eth16", replace) idstr("crude_ventilated_eth16") 

/* Multivariable models */ 

* Age, Gender, IMD
* Age fit as spline in first instance, categorical below 

clogit ventilated i.eth16 i.male age1 age2 age3 i.imd, strata(stp) or
estimates save "$Tempdir/model1_ventilated_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model1_ventilated_eth16", replace) idstr("model1_ventilated_eth16") 

* Age, Gender, IMD and Comorbidities  
clogit ventilated  i.eth16 i.male age1 age2 age3 	i.imd			///
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
										i.ra_sle_psoriasis, strata(stp) or				
										
estimates save "$Tempdir/model2_ventilated_eth16", replace 
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model2_ventilated_eth16", replace) idstr("model2_ventilated_eth16") 

* Age, Gender, IMD and Comorbidities and household size

clogit ventilated i.eth16 i.male age1 age2 age3 i.imd hh_size					///
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
										i.ra_sle_psoriasis, strata(stp) or	iter(100)			
										
estimates save "$Tempdir/model3_ventilated_eth16", replace
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_ventilated_eth16", replace) idstr("model3_ventilated_eth16") 

/* Print table================================================================*/ 
*  Print the results for the main model 


* Column headings 
file write tablecontent ("Outcome: ventilated") _n

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
 
* First row, eth16 = 1 (White) reference cat
	count if eth16 == 1 & ventilated == 1
	local event = r(N)
	
	file write tablecontent  ("`lab1'") _tab (`event') _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)") _tab _tab ("1.00 (ref)")  _tab _tab ("1.00 (ref)") _n
	
* Subsequent ethnic groups
forvalues eth=2/11 {
	
	count if eth16 == `eth' & ventilated == 1
	local event = r(N)
	file write tablecontent  ("`lab`eth''") _tab   (`event') _tab
	estimates use "$Tempdir/crude_ventilated_eth16" 
	lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model1_ventilated_eth16" 
	cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model2_ventilated_eth16" 
	cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _tab 
	cap estimates clear
	cap estimates use "$Tempdir/model3_ventilated_eth16" 
	cap lincom `eth'.eth16, eform
	file write tablecontent  %4.2f (r(estimate)) _tab %4.2f (r(lb)) (" - ") %4.2f (r(ub)) _n
}  //end ethnic group

file close tablecontent


/* Foresplot================================================================*/ 

dsconcat  "$Tempdir/model1_ventilated_eth16" "$Tempdir/model2_ventilated_eth16" "$Tempdir/model3_ventilated_eth16"
duplicates drop

split idstr, p(_)
drop idstr
ren idstr1 model
ren idstr2 outcome
drop idstr3 


*keep ORs for ethnic group
keep if label=="Eth 16 collapsed"
drop label

gen eth16=1 if regexm(parm, "1b")
forvalues i=2/11 {
	replace eth16=`i' if regexm(parm, "`i'.eth16")
}

drop parm eq
order outcome model eth16

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


gen adjusted="Age-sex-IMD" if model=="model1"
replace adjusted="+ co-morbidities" if model=="model2"
replace adjusted="+ household size" if model=="model3"


*Create one graph 
metan estimate min95 max95  if eth16!=1 ///
 , random effect(Odds Ratio) null(1) lcols(eth16) dp(2) by(adjusted)  ///
	nowt nosubgroup nooverall nobox graphregion(color(white)) scheme(sj)  	///
	title("Ventilation", size(medsmall)) 	///
	t2title("complete case analysis", size(small)) 	///
	graphregion(margin(zero)) 
	graph export "$Tabfigdir\Forestplot_ventilated_eth16_cc.svg", replace  


* Close log file 
log close


insheet using "$Tabfigdir/table3_eth16.txt", clear





