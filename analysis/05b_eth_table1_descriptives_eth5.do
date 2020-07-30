/*==============================================================================
DO FILE NAME:			05b_eth_table1_descriptives_eth5
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
log using $Logdir/05b_eth_table1_descriptives_eth5, replace t

* Open Stata dataset
use $Tempdir/analysis_dataset, clear


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

	forvalues i=1/5{
	cou if eth5 == `i'
	local rowdenom = r(N)
	cou if eth5 == `i' & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent %9.0gc (r(N)) (" (") %3.1f (`pct') (")") _tab
	}
	
	cou if eth5 == .
	local rowdenom = r(N)
	cou if eth5 == . & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom')
	file write tablecontent %9.0gc (r(N)) (" (") %3.1f (`pct') (")") _n
	
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
	
	forvalues i=1/5{							
	qui summarize `variable' if eth5 == `i', d
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	}
	
	qui summarize `variable' if eth5 ==. , d
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _n
	
	qui summarize `variable', d
	file write tablecontent ("Median (IQR)") _tab 
	file write tablecontent %3.1f (r(p50)) (" (") %3.1f (r(p25)) ("-") %3.1f (r(p75)) (")") _tab
	
	forvalues i=1/5{
	qui summarize `variable' if eth5 == `i', d
	file write tablecontent %3.1f (r(p50)) (" (") %3.1f (r(p25)) ("-") %3.1f (r(p75)) (")") _tab
	}
	
	qui summarize `variable' if eth5 ==. , d
	file write tablecontent %3.1f (r(p50)) (" (") %3.1f (r(p25)) ("-") %3.1f (r(p75)) (")") _n

	
/*
	qui summarize `variable', d
	file write tablecontent ("Min, Max") _tab 
	file write tablecontent %3.1f (r(min)) (", ") %3.1f (r(max)) ("") _tab
	
	forvalues i=1/5{							
	qui summarize `variable' if eth5 == `i', d
	file write tablecontent %3.1f (r(min)) (", ") %3.1f (r(max)) ("") _tab
	
	qui summarize `variable' if eth5==. , d
	file write tablecontent ("Min, Max") _tab 
	file write tablecontent %3.1f (r(min)) (", ") %3.1f (r(max)) ("") _tab

	}
	
*/
end

/* INVOKE PROGRAMS FOR TABLE 1================================================*/ 

*Set up output file
cap file close tablecontent
file open tablecontent using $Tabfigdir/table1_eth5.txt, write text replace

file write tablecontent ("Table 1: Demographic and Clinical Characteristics") _n

* eth5 labelled columns

local lab1: label eth5 1
local lab2: label eth5 2
local lab3: label eth5 3
local lab4: label eth5 4
local lab5: label eth5 5
local lab6: label eth5 .u


file write tablecontent _tab ("Total")				  			  _tab ///
							 ("`lab1'")  						  _tab ///
							 ("`lab2'")  						  _tab ///
							 ("`lab3'")  						  _tab ///
							 ("`lab4'")  						  _tab ///
							 ("`lab5'")  						  _tab ///
							 ("`lab6'")  						  _n 

* DEMOGRAPHICS (more than one level, potentially missing) 

gen byte cons=1
tabulatevariable, variable(cons) min(1) max(1) 
file write tablecontent _n 

qui summarizevariable, variable(age) 
file write tablecontent _n

tabulatevariable, variable(agegroup) min(1) max(7) 
file write tablecontent _n 

tabulatevariable, variable(male) min(0) max(1) 
file write tablecontent _n 

tabulatevariable, variable(imd) min(1) max(5) missing
file write tablecontent _n 

tabulatevariable, variable(hh_total_cat) min(0) max(3) missing
file write tablecontent _n 

qui summarizevariable, variable(bmi)
file write tablecontent _n

tabulatevariable, variable(obese4cat_sa) min(1) max(4) missing
file write tablecontent _n 

tabulatevariable, variable(smoke) min(1) max(3) missing 
file write tablecontent _n 

tabulatevariable, variable(dm_type) min(0) max(3) missing 
file write tablecontent _n 

tabulatevariable, variable(dm_type_exeter_os) min(0) max(2) missing 
file write tablecontent _n 

tabulatevariable, variable(diabcat) min(1) max(6) missing 
file write tablecontent _n 

file write tablecontent _n _n


** COMORBIDITIES (categorical and continous)

* COMORBIDITIES (continous)
format hba1c_pct bmi egfr %9.2f

qui summarizevariable, variable(hba1c_pct)
file write tablecontent _n

** COMORBIDITIES (binary)

foreach comorb of varlist 		///
	hypertension 				///
	htdiag_or_highbp			///
	chronic_cardiac_disease		///
	stroke						///
	esrf						///
	cancer						///
	perm_immunodef				///
	temp_immunodef				///
	ra_sle_psoriasis			///
	other_immuno				///
	chronic_liver_disease		///
	dementia					///
	other_neuro					///
	chronic_respiratory_disease ///
	asthma						///
	{ 
	local comorb: subinstr local comorb "i." ""
	local lab: variable label `comorb'
	file write tablecontent ("`lab'") _n 
								
	*generaterow, variable(`comorb') condition("==0")
	generaterow, variable(`comorb') condition("==1")
	file write tablecontent _n
}



** OTHER TREATMENT VARIABLES (binary)
foreach treat of varlist ///
	combination_bp_meds ///
	statin 				///
	insulin				///
						{    		

local lab: variable label `treat'
file write tablecontent ("`lab'") _n 
	
*generaterow, variable(`treat') condition("==0")
generaterow, variable(`treat') condition("==1")

file write tablecontent _n
}

file close tablecontent

* Close log file 
log close

clear
insheet using $Tabfigdir/table1_eth5.txt
