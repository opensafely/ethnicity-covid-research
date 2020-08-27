/*==============================================================================
DO FILE NAME:			03b_outcomes_checks_eth5
PROJECT:				Ethnicity and COVID-19 
DATE: 					14 July 2020 
AUTHOR:					R Mathur
						adapted from A Schultze 	
DESCRIPTION OF FILE:	Produce a table of baseline characteristics, by ethnicity
						Generalised to produce same columns as levels of eth5
						Output to a textfile for further formatting
DATASETS USED:			$Tempdir\analysis_dataset.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in txt: $Tabfigdir\table1.txt 
						Log file: $Logdir\05_eth_table1_descriptives
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)	
  
 Notes:
 Table 1 population is people who are alive on indexdate
 It does not exclude anyone who experienced any outcome prior to indexdate
 change the analysis_dataset to exlucde people with any of the following as of Feb 1st 2020:
 COVID identified in primary care
 COVID test result via  SGSS
 A&E admission for COVID-19
 ICU admission for COVID-19
 

 ==============================================================================*/

* Open a log file
capture log close
log using "$Logdir/03b_outcomes_checks_eth5", replace t


 /* PROGRAMS TO AUTOMATE TABULATIONS===========================================*/ 

********************************************************************************
* All below code from K Baskharan 
* Generic code to output one row of table

cap prog drop generaterow
program define generaterow
syntax, variable(varname) condition(string) 
	
	cou
	local overalldenom=r(N)
	
	sum `variable' if `variable' `condition'
	file write tablecontent (r(max)) _tab
	
	cou if `variable' `condition'
	local rowdenom = r(N)
	local colpct = 100*(r(N)/`overalldenom')
	file write tablecontent %9.0gc (`rowdenom')  (" (") %3.1f (`colpct') (")") _tab

	forvalues i=1/6{
	cou if eth5 == `i'
	local rowdenom = r(N)
	cou if eth5 == `i' & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent %9.0gc (r(N)) (" (") %3.1f (`pct') (")") _tab
	}
	
	file write tablecontent _n
end


* Output one row of table for co-morbidities and meds

cap prog drop generaterow2
program define generaterow2
syntax, variable(varname) condition(string) 
	
	cou
	local overalldenom=r(N)
	
	cou if `variable' `condition'
	local rowdenom = r(N)
	local colpct = 100*(r(N)/`overalldenom')
	file write tablecontent %9.0gc (`rowdenom')  (" (") %3.1f (`colpct') (")") _tab

	forvalues i=1/6{
	cou if eth5 == `i'
	local rowdenom = r(N)
	cou if eth5 == `i' & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent %9.0gc (r(N)) (" (") %3.1f (`pct') (")") _tab
	}
	
	file write tablecontent _n
end



/* Explanatory Notes 

defines a program (SAS macro/R function equivalent), generate row
the syntax row specifies two inputs for the program: 

	a VARNAME which is your variable 
	a CONDITION which is a string of some condition you impose 
	
the program counts if variable and condition and returns the counts
column percentages are then automatically generated
this is then written to the text file 'tablecontent' 
the number followed by space, brackets, formatted pct, end bracket and then tab

the format %3.1f specifies length of 3, followed by 1 dp. 

*/ 

********************************************************************************
* Generic code to output one section (varible) within table (calls above)

cap prog drop tabulatevariable
prog define tabulatevariable
syntax, variable(varname) min(real) max(real) [missing]

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 

	forvalues varlevel = `min'/`max'{ 
		generaterow, variable(`variable') condition("==`varlevel'")
	}
	
	if "`missing'"!="" generaterow, variable(`variable') condition("== 12")
	


end

********************************************************************************

/* Explanatory Notes 

defines program tabulate variable 
syntax is : 

	- a VARNAME which you stick in variable 
	- a numeric minimum 
	- a numeric maximum 
	- optional missing option, default value is . 

forvalues lowest to highest of the variable, manually set for each var
run the generate row program for the level of the variable 
if there is a missing specified, then run the generate row for missing vals

*/ 

********************************************************************************
* Generic code to qui summarize a continous variable 

cap prog drop summarizevariable 
prog define summarizevariable
syntax, variable(varname) 

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 


	qui summarize `variable', d
	file write tablecontent ("Mean (SD)") _tab 
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	
	forvalues i=1/6{							
	qui summarize `variable' if eth5 == `i', d
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	}

file write tablecontent _n

	
	qui summarize `variable', d
	file write tablecontent ("Median (IQR)") _tab 
	file write tablecontent %3.1f (r(p50)) (" (") %3.1f (r(p25)) ("-") %3.1f (r(p75)) (")") _tab
	
	forvalues i=1/6{
	qui summarize `variable' if eth5 == `i', d
	file write tablecontent %3.1f (r(p50)) (" (") %3.1f (r(p25)) ("-") %3.1f (r(p75)) (")") _tab
	}
	
file write tablecontent _n
	
end

*******************************************************************Open Raw Data

import delimited `c(pwd)'/output/input.csv, clear

di "STARTING safecount FROM IMPORT:"
safecount

*Generate outcomes

*Start dates
gen index 			= "01/02/2020"

* Date of cohort entry, 1 Feb 2020
gen indexdate = date(index, "DMY")
format indexdate %d

 *re-order ethnicity
 safetab ethnicity,m
 
 gen eth5=1 if ethnicity==1
 replace eth5=2 if ethnicity==3
 replace eth5=3 if ethnicity==4
 replace eth5=4 if ethnicity==2
 replace eth5=5 if ethnicity==5
 replace eth5=6 if ethnicity==.

 label define eth5	 	1 "White"  					///
						2 "South Asian"		  ///						
						3 "Black"  					///
						4 "Mixed"					///
						5 "Other"					///
						6 "Unknown"
					

label values eth5 eth5
safetab eth5, m


/* OUTCOME AND SURVIVAL TIME==================================================*/

	
/****   Outcome definitions   ****/
ren primary_care_suspect_case	suspected_date
ren primary_care_case			confirmed_date
ren first_tested_for_covid		tested_date
ren first_positive_test_date	positivetest_date
ren a_e_consult_date 			ae_date
ren icu_date_admitted			icu_date
ren died_date_cpns				cpnsdeath_date
ren died_date_ons				onsdeath_date

* Date of Covid death in ONS
gen onscoviddeath_date = onsdeath_date if died_ons_covid_flag_any == 1
gen onsconfirmeddeath_date = onsdeath_date if died_ons_confirmedcovid_flag_any ==1
gen onssuspecteddeath_date = onsdeath_date if died_ons_suspectedcovid_flag_any ==1

* Date of non-COVID death in ONS 
* If missing date of death resulting died_date will also be missing
gen ons_noncoviddeath_date = onsdeath_date if died_ons_covid_flag_any != 1



/* CONVERT STRINGS TO DATE FOR OUTCOME VARIABLES =============================*/
* Recode to dates from the strings 
*gen dummy date for severe and replace later on
*gen severe_date=ae_date

foreach var of global outcomes {
	confirm string variable `var'_date
	rename `var'_date `var'_dstr
	gen `var'_date = date(`var'_dstr, "YMD")
	drop `var'_dstr
	format `var'_date %td 

}

*If outcome occurs on the first day of follow-up add one day
foreach i of global outcomes {
	di "`i'"
	count if `i'_date==indexdate
	replace `i'_date=`i'_date+1 if `i'_date==indexdate
}

* Binary indicators for outcomes
foreach i of global outcomes {
		gen `i'=0
		replace  `i'=1 if `i'_date < .
		safetab `i'
}



/* INVOKE PROGRAMS FOR TABLE 1================================================*/ 

*Set up output file
cap file close tablecontent
file open tablecontent using $Tabfigdir/table0_outcomes_eth5.txt, write text replace

file write tablecontent ("Table 0: Outcome counts by ethnic group") _n

* eth5 labelled columns

local lab1: label eth5 1
local lab2: label eth5 2
local lab3: label eth5 3
local lab4: label eth5 4
local lab5: label eth5 5
local lab6: label eth5 6



file write tablecontent _tab ("Total")				  			  _tab ///
							 ("`lab1'")  						  _tab ///
							 ("`lab2'")  						  _tab ///
							 ("`lab3'")  						  _tab ///
							 ("`lab4'")  						  _tab ///
							 ("`lab5'")  						  _tab ///
							 ("`lab6'")  						  _n 							 

/*STEP 1: WHOLE POPULATION WITHOUT EXCLUSIONS*/
							 
*Denominator
file write tablecontent ("Whole study population- no exclusions") _n
gen byte cons=1
file write tablecontent ("N") _tab

generaterow2, variable(cons) condition("==1")
file write tablecontent _n 


*Outcomes 
foreach var of global outcomes {

file write tablecontent ("`var'") _tab
generaterow2, variable(`var') condition("==1")
}

/* STEP 2: KEEP THOSE AGED 18-105 */
drop if age<18
drop if age>105

*Denominator
file write tablecontent ("Adults aged 18-105") _n
file write tablecontent ("N") _tab

generaterow2, variable(cons) condition("==1")
file write tablecontent _n 


*Outcomes 
foreach var of global outcomes {

file write tablecontent ("`var'") _tab
generaterow2, variable(`var') condition("==1")
}

* Sex: Exclude categories other than M and F
drop if inlist(sex, "I", "U")

*Denominator
file write tablecontent ("Adults with valid sex recorded") _n
file write tablecontent ("N") _tab

generaterow2, variable(cons) condition("==1")
file write tablecontent _n 


*Outcomes 
foreach var of global outcomes {

file write tablecontent ("`var'") _tab
generaterow2, variable(`var') condition("==1")
}

file close tablecontent


* Close log file 
log close

clear
insheet using "$Tabfigdir/table0_outcomes_eth5.txt", clear
