/*==============================================================================
DO FILE NAME:			16_eth_an_outcome_characteristics
PROJECT:				Ethnicity and COVID-19 
DATE: 					14 July 2020 
AUTHOR:					R Mathur
						adapted from A Schultze 	
DESCRIPTION OF FILE:	Produce a table of baseline characteristics, by ethnicity
						Generalised to produce same columns as levels of eth16
						Output to a textfile for further formatting
DATASETS USED:			$Tempdir\analysis_dataset.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Results in txt: $Tabfigdir\table5.txt 
						Log file: $Logdir\05_eth_table5_descriptives
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)	
  
 Notes:

 Table to compare
 1. Tested vs. untested in general pop
 2. Test positive vs. other in tested pop
 3. Secondary care and mortality  outcomes in infected pop
 4. ventilation in ICU pop
 ==============================================================================*/
 
 * Open a log file
capture log close
log using "$Logdir/16_eth_an_outcome_characteristics", replace t


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

	
	cou if outcome == 0
	local rowdenom = r(N)
	cou if outcome == 0 & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent %9.0gc (r(N)) (" (") %3.1f (`pct') (")") _tab
	
	cou if outcome == 1
	local rowdenom = r(N)
	cou if outcome == 1 & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom') 
	file write tablecontent %9.0gc (r(N)) (" (") %3.1f (`pct') (")") _tab

	file write tablecontent _n
end





/* Explanatory Notes 

defines a program (SAS macro/R function evalent), generate row
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
* Generic code to  summarize a continous variable 

cap prog drop summarizevariable 
prog define summarizevariable
syntax, variable(varname) 

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 


	 summarize `variable', d
	file write tablecontent ("Mean (SD)") _tab 
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	
	forvalues i=0/1{	
	 summarize `variable' if outcome == `i', d
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	}

file write tablecontent _n

	
	 summarize `variable', d
	file write tablecontent ("Median (IQR)") _tab 
	file write tablecontent %3.1f (r(p50)) (" (") %3.1f (r(p25)) ("-") %3.1f (r(p75)) (")") _tab
	
	forvalues i=0/1{
	 summarize `variable' if outcome == `i', d
	file write tablecontent %3.1f (r(p50)) (" (") %3.1f (r(p25)) ("-") %3.1f (r(p75)) (")") _tab
	}
	
file write tablecontent _n
	
end


/*OUTCOMES IN GENERAL POPULATION*/
foreach outcome of global outcomes {
* Open Stata dataset
use $Tempdir/analysis_dataset, clear

safetab `outcome'

gen outcome= `outcome'
tab outcome `outcome'


/* INVOKE PROGRAMS FOR TABLE 1================================================*/ 

*Set up output file
cap file close tablecontent
file open tablecontent using "$Tabfigdir/table5_`outcome'.txt", write text replace

file write tablecontent ("char") _tab

* tested labelled columns

file write tablecontent 	 ("General_Pop")				    _tab ///
							 ("`outcome'0")  				  _tab ///
							 ("`outcome'1")  				  _n
							 
							 


* DEMOGRAPHICS (more than one level, potentially missing) 

format hba1c_pct bmi egfr %9.2f


gen byte cons=1
tabulatevariable, variable(cons) min(1) max(1) 
file write tablecontent _n 

 summarizevariable, variable(age) 
file write tablecontent _n

tabulatevariable, variable(male) min(1) max(1) 
file write tablecontent _n 

tabulatevariable, variable(eth5) min(1) max(6) 
file write tablecontent _n 

tabulatevariable, variable(eth16) min(1) max(14) 
file write tablecontent _n 

 summarizevariable, variable(gp_consult_count) 
file write tablecontent _n 

tabulatevariable, variable(imd) min(1) max(5) 
file write tablecontent _n 

tabulatevariable, variable(hh_total_cat) min(1) max(5) missing
file write tablecontent _n 

tabulatevariable, variable(carehome) min(0) max(1) 
file write tablecontent _n 

 summarizevariable, variable(bmi)
file write tablecontent _n

 summarizevariable, variable(hba1c_pct)
file write tablecontent _n

 summarizevariable, variable(hba1c_mmol_per_mol)
file write tablecontent _n

 summarizevariable, variable(comorbidity_count)
file write tablecontent _n

tabulatevariable, variable(dm_type) min(0) max(3)  
file write tablecontent _n 

file close tablecontent

clear
} //end global outcomes 

/*OUTCOMES IN TESTED POPULATION*/

* Open Stata dataset
use $Tempdir/analysis_dataset, clear
keep if tested==1
safetab positivetest

gen outcome= positivetest
tab outcome positivetest

*Set up output file
cap file close tablecontent
file open tablecontent using "$Tabfigdir/table5_positivetest.txt", write text replace

file write tablecontent ("char")  _tab

* tested labelled columns

file write tablecontent 	 ("Tested_pop")				  		  	_tab ///
							 ("positive0")  				  		_tab ///
							 ("positive1")  				  	_n
							 
							 


* DEMOGRAPHICS (more than one level, potentially missing) 

format hba1c_pct bmi egfr %9.2f


gen byte cons=1
tabulatevariable, variable(cons) min(1) max(1) 
file write tablecontent _n 

 summarizevariable, variable(age) 
file write tablecontent _n

tabulatevariable, variable(male) min(1) max(1) 
file write tablecontent _n 

tabulatevariable, variable(eth5) min(1) max(6) 
file write tablecontent _n 

tabulatevariable, variable(eth16) min(1) max(14) 
file write tablecontent _n 

 summarizevariable, variable(gp_consult_count) 
file write tablecontent _n 

tabulatevariable, variable(imd) min(1) max(5) 
file write tablecontent _n 

tabulatevariable, variable(hh_total_cat) min(1) max(5) missing
file write tablecontent _n 

tabulatevariable, variable(carehome) min(0) max(1) 
file write tablecontent _n 

 summarizevariable, variable(bmi)
file write tablecontent _n

 summarizevariable, variable(hba1c_pct)
file write tablecontent _n

 summarizevariable, variable(hba1c_mmol_per_mol)
file write tablecontent _n

 summarizevariable, variable(comorbidity_count)
file write tablecontent _n

tabulatevariable, variable(dm_type) min(0) max(3)  
file write tablecontent _n 

file close tablecontent

clear


/*VENTILATED*/
* Open Stata dataset
use $Tempdir/analysis_dataset, clear
keep if icu==1

gen outcome=0
replace outcome=1 if was_ventilated_flag==1

safetab outcome was_ventilated_flag,m

*Set up output file
cap file close tablecontent
file open tablecontent using "$Tabfigdir/table5_ventilated.txt", write text replace

file write tablecontent ("char") _tab

* tested labelled columns

file write tablecontent 	 ("ICU_pop")				  		  _tab ///
							 ("ventilated0")  				  _tab ///
							 ("ventilated1")  				  _n
							 
							 


* DEMOGRAPHICS (more than one level, potentially missing) 

format hba1c_pct bmi egfr %9.2f


gen byte cons=1
tabulatevariable, variable(cons) min(1) max(1) 
file write tablecontent _n 

 summarizevariable, variable(age) 
file write tablecontent _n

tabulatevariable, variable(male) min(1) max(1) 
file write tablecontent _n 

tabulatevariable, variable(eth5) min(1) max(6) 
file write tablecontent _n 

tabulatevariable, variable(eth16) min(1) max(14) 
file write tablecontent _n 

 summarizevariable, variable(gp_consult_count) 
file write tablecontent _n 

tabulatevariable, variable(imd) min(1) max(5) 
file write tablecontent _n 

tabulatevariable, variable(hh_total_cat) min(1) max(5) missing
file write tablecontent _n 

tabulatevariable, variable(carehome) min(0) max(1) 
file write tablecontent _n 

 summarizevariable, variable(bmi)
file write tablecontent _n

 summarizevariable, variable(hba1c_pct)
file write tablecontent _n

 summarizevariable, variable(hba1c_mmol_per_mol)
file write tablecontent _n

 summarizevariable, variable(comorbidity_count)
file write tablecontent _n

tabulatevariable, variable(dm_type) min(0) max(3)  
file write tablecontent _n 

file close tablecontent

clear


* Close log file 
log close


*combine tables
foreach i of global outcomes {
insheet using "$Tabfigdir/table5_`i'.txt", clear names
gen order=[_n]
drop v5
save "$Tabfigdir/table5_`i'.dta", replace
}


insheet using "$Tabfigdir/table5_ventilated.txt", clear names 
gen order=[_n]
drop v5
save "$Tabfigdir/table5_ventilated.dta", replace

*merge tables of interest
use "$Tabfigdir/table5_tested.dta", clear
merge 1:1 order using "$Tabfigdir/table5_positivetest.dta", nogen
merge 1:1 order using "$Tabfigdir/table5_ae.dta", nogen
merge 1:1 order using "$Tabfigdir/table5_icu.dta", nogen
merge 1:1 order using "$Tabfigdir/table5_ventilated.dta", nogen
merge 1:1 order using "$Tabfigdir/table5_onscoviddeath.dta", nogen
merge 1:1 order using "$Tabfigdir/table5_ons_noncoviddeath.dta", nogen


drop order
outsheet using "$Tabfigdir/table5_outcomes.txt", replace

