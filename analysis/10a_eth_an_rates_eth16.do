/*==============================================================================
DO FILE NAME:			10a_eth_an_rates_eth16
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 10a 
						strate and graphs
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2, printed to analysis/$outdir
							
==============================================================================*/
* Open a log file

cap log close
log using $logdir\10a_eth_an_rates_eth16, replace text

*CALCULATE RATES



foreach i of global outcomes {
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear

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

*rates by ethnic group
strate eth16, per(10000) missing output($Tempdir/strate_`i'_eth16,replace) ///
	graph saving("$Tabfigdir/strate_`i'_eth16", replace) xlab(1"British" 2"`lab2'" 3"`lab3'" 4"`lab4'" 5"`lab5'" 6"`lab6'" 7"`lab7'" 8"`lab8'" 9"`lab9'" 10"`lab10'" 11"`lab11'", angle(45)) title("`i'")
	local graph "`graph' "$Tabfigdir/strate_`i'_eth16" "
} //end outcomes

grc1leg `graph', altshrink saving("$Tabfigdir/strate_eth16_combined", replace)
macro drop graph

*rates by ethnic group and agegroup
foreach i of global outcomes {
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear

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

forvalues j=1/7 {
	qui strate eth16 if agegroup==`j', per(10000) missing output($Tempdir/strate_`i'_eth16_agegroup`j', replace) ///
	graph saving("$Tabfigdir/strate_`i'_eth16_agegroup`j'", replace) xlab(1"British" 2"`lab2'" 3"`lab3'" 4"`lab4'" 5"`lab5'" 6"`lab6'" 7"`lab7'" 8"`lab8'" 9"`lab9'" 10"`lab10'" 11"`lab11'", angle(45)) title("`i' agegroup `j'")
	local grapha "`grapha' "$Tabfigdir/strate_`i'_eth16_agegroup`j'" "
} //end agegroup

grc1leg `grapha', altshrink saving("$Tabfigdir/strate_`i'_eth16_age_combined", replace)
graph export "$Tabfigdir/strate_`i'_eth16_age_combined", as(svg) replace
macro drop grapha

*rates by ethnic group, age, and sex
forvalues j=1/7 {	
	strate eth16 if agegroup==`j' & male==0, per(10000) missing output($Tempdir/strate_`i'_eth16_agegroup`j'_female, replace) ///
	graph saving("$Tabfigdir/strate_`i'_eth16_agegroup`j'_female", replace) xlab(1"British" 2"`lab2'" 3"`lab3'" 4"`lab4'" 5"`lab5'" 6"`lab6'" 7"`lab7'" 8"`lab8'" 9"`lab9'" 10"`lab10'" 11"`lab11'", angle(45)) title("`i' agegroup `j' female")
	local graphf "`graphf' "$Tabfigdir/strate_`i'_eth16_agegroup`j'_female" "
} //end agegroup

grc1leg `graphf', altshrink  saving("$Tabfigdir/strate_`i'_eth16_agef_combined", replace)
graph export "$Tabfigdir/strate_`i'_eth16_agef_combined", as(svg) replace
macro drop grapha

forvalues j=1/7 {	
	strate eth16 if agegroup==`j' & male==1, per(10000) missing output($Tempdir/strate_`i'_eth16_agegroup`j'_male, replace) ///
	graph saving("$Tabfigdir/strate_`i'_eth16_agegroup`j'_male", replace) xlab(1"British" 2"`lab2'" 3"`lab3'" 4"`lab4'" 5"`lab5'" 6"`lab6'" 7"`lab7'" 8"`lab8'" 9"`lab9'" 10"`lab10'" 11"`lab11'", angle(45)) title("`i' agegroup `j' male")
	local graphm "`graphm' "$Tabfigdir/strate_`i'_eth16_agegroup`j'_male" "
} //end agegroup

grc1leg `graphm', altshrink  saving("$Tabfigdir/strate_`i'_eth16_agem_combined", replace)
graph export "$Tabfigdir/strate_`i'_eth16_agem_combined", as(svg) replace
macro drop graphm



} //end outcomes

*************************************************CREATE TABLES
**append datasets
foreach i of global outcomes {
	use  $Tempdir/strate_`i'_eth16, clear
	gen agegroup=99
	gen male=99
		forvalues j=1/7 {
			append using $Tempdir/strate_`i'_eth16_agegroup`j'
			replace agegroup=`j' if agegroup==.
			replace male=99 if male==.
			append using $Tempdir/strate_`i'_eth16_agegroup`j'_female
			replace agegroup=`j' if agegroup==.
			replace male=0 if male==.
			append using $Tempdir/strate_`i'_eth16_agegroup`j'_male
			replace agegroup=`j' if agegroup==.
			replace male=1 if male==.
		} //end agegroup
	
gen `i'=1
order `i'
ren _D d_`i'
ren _Y y_`i'
ren _Rate rate_`i'
ren _Lower lb_`i'
ren _Upper ub_`i'
gen unique=_n
save $Tempdir/table4_`i'_eth16.dta, replace

} //end outcomes

*MERGE ALL TABLES INTO ONE DATASET
use $Tempdir/table4_tested_eth16.dta, clear
foreach i of global outcomes {
	merge 1:1 unique using  $Tempdir/table4_`i'_eth16.dta, nogen
}
save $Tabfigdir/table4_eth16, replace
outsheet using $Tabfigdir/table4_eth16.txt, replace



*delete graphs
foreach i of global outcomes {

forvalues j=1/7 {	
	noi erase "$Tabfigdir/strate_`i'_eth16_agegroup`j'.gph"
	noi erase "$Tabfigdir/strate_`i'_eth16_agegroup`j'_female.gph"
	noi erase "$Tabfigdir/strate_`i'_eth16_agegroup`j'_male.gph"
} //end agegroup

} //end outcomes





log close







log close
