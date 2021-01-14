*compare characteristics of people with each outcome
*************************************************************************
*Purpose: Create content that is ready to paste into a pre-formatted Word 
* shell "Table 1" (main cohort descriptives) for the Risk Factors paper
*
*Requires: final analysis dataset (cr_analysis_dataset.dta)
*
*Coding: Krishnan Bhaskaran
*
*Date drafted: 17/4/2020
*************************************************************************
global outcomes "tested positivetest icu hes onscoviddeath ons_noncoviddeath onsdeath"

*******************************************************************************
*Generic code to output one row of table
cap prog drop generaterow
program define generaterow
syntax, variable(varname) condition(string) outcome(string)
	
	*put the varname and condition to left so that alignment can be checked vs shell
	file write tablecontent ("`variable'") _tab ("`condition'") _tab
	
	cou
	local overalldenom=r(N)
	
	cou if `variable' `condition'
	local rowdenom = r(N)
	local colpct = 100*(r(N)/`overalldenom')
	file write tablecontent (`rowdenom')  (" (") %3.1f (`colpct') (")") _tab

	cou if `outcome'==1 & `variable' `condition'
	local pct = 100*(r(N)/`rowdenom')
	file write tablecontent (r(N)) (" (") %4.2f  (`pct') (")") _n

	
end

*******************************************************************************
*Generic code to output one section (varible) within table (calls above)
cap prog drop tabulatevariable
prog define tabulatevariable
syntax, variable(varname) start(real) end(real) [missing] outcome(string)

	foreach varlevel of numlist `start'/`end'{ 
		generaterow, variable(`variable') condition("==`varlevel'") outcome(`outcome')
	}
	if "`missing'"!="" generaterow, variable(`variable') condition(">=.") outcome(`outcome')

end

*******************************************************************************

********************************************************************************
* Generic code to qui summarize a continous variable 

cap prog drop summarizevariable 
prog define summarizevariable
syntax, variable(varname) 

	local lab: variable label `variable'
	file write tablecontent ("`lab'") _n 

	di "`outcome'"
	summarize `variable', d
	file write tablecontent ("Mean (SD)") _tab 
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	
	summarize `variable' if `outcome'== 1, d
	file write tablecontent  %3.1f (r(mean)) (" (") %3.1f (r(sd)) (")") _tab
	

file write tablecontent _n	
end


foreach outcome of global outcomes {
use ./output/analysis_dataset.dta, clear

*Set up output file
cap file close tablecontent
file open tablecontent using ./output/Table1_`outcome'.txt, write text replace

file write tablecontent ("`outcome' characteristics") _n

*  labelled columns

local lab1: label `outcome' 0
local lab2: label `outcome' 1



file write tablecontent _tab ("Total")				  			  _tab ///
							 ("`lab1'")  						  _tab ///
							 ("`lab2'")  						  _n							 


gen byte cons=1
tabulatevariable, variable(cons) start(1) end(1) outcome(`outcome')
file write tablecontent _n 

summarizevariable, variable(age) 
file write tablecontent _n

tabulatevariable, variable(male) start(0) end(1) outcome(`outcome')
file write tablecontent _n 

tabulatevariable, variable(eth5) start(1) end(5) missing outcome(`outcome')
file write tablecontent _n 

tabulatevariable, variable(imd) start(1) end(5) outcome(`outcome')
file write tablecontent _n 

encode region, gen(region2)
tabulatevariable, variable(region2) start(1) end(8) outcome(`outcome')
file write tablecontent _n 

file close tablecontent
di "`outcome'"
}

insheet using ./output/Table1_tested.txt, clear
