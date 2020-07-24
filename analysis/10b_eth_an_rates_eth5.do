/*==============================================================================
DO FILE NAME:			10b_eth_an_rates_eth5
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 10b 
						strate and graphs
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2, printed to analysis/$outdir
							
==============================================================================*/
* Open a log file

cap log close
log using $logdir\10b_eth_an_rates_eth5, replace text

*CALCULATE RATES



foreach i of global outcomes {
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear

* labels 
local lab1: label eth5 1
local lab2: label eth5 2
local lab3: label eth5 3
local lab4: label eth5 4
local lab5: label eth5 5

*rates by ethnic group
strate eth5, per(10000) missing output($Tempdir/strate_`i'_eth5,replace) ///
	graph saving("$Tabfigdir/strate_`i'_eth5", replace) xlab(1"`lab1'" 2"`lab2'" 3"`lab3'" 4"`lab4'" 5"`lab5'") title("`i'")
	local graph "`graph' "$Tabfigdir/strate_`i'_eth5" "
} //end outcomes

grc1leg `graph', altshrink saving("$Tabfigdir/strate_eth5_combined", replace)

foreach i of global outcomes {
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear

* labels 
local lab1: label eth5 1
local lab2: label eth5 2
local lab3: label eth5 3
local lab4: label eth5 4
local lab5: label eth5 5

*rates by ethnic group and agegroup
forvalues j=1/7 {
	di "`j'"
	qui strate eth5 if agegroup==`j', per(10000) missing output($Tempdir/strate_`i'_eth5_agegroup`j', replace) ///
	graph saving("$Tabfigdir/strate_`i'_eth5_agegroup`j'", replace) xlab(1"lab1" 2"lab2" 3"lab3" 4"lab4" 5"lab5") title("`i' agegroup `j'")
	local grapha "`grapha' "$Tabfigdir/strate_`i'_eth5_agegroup`j'" "
} //end agegroup

grc1leg `grapha', altshrink saving("$Tabfigdir/strate_`i'_eth5_age_combined", replace)
graph export "$Tabfigdir/strate_`i'_eth5_age_combined", as(svg) replace

*rates by ethnic group, age, and sex
forvalues j=1/7 {	
	strate eth5 if agegroup==`j' & male==0, per(10000) missing output($Tempdir/strate_`i'_eth5_agegroup`j'_female, replace) ///
	graph saving("$Tabfigdir/strate_`i'_eth5_agegroup`j'_female", replace) xlab(1"lab1" 2"lab2" 3"lab3" 4"lab4" 5"lab5") title("`i' agegroup `j' female")
	local graphf "`graphf' "$Tabfigdir/strate_`i'_eth5_agegroup`j'_female" "
} //end agegroup

grc1leg `graphf', altshrink  saving("$Tabfigdir/strate_`i'_eth5_agef_combined", replace)
graph export "$Tabfigdir/strate_`i'_eth5_agef_combined", as(svg) replace

forvalues j=1/7 {	
	strate eth5 if agegroup==`j' & male==1, per(10000) missing output($Tempdir/strate_`i'_eth5_agegroup`j'_male, replace) ///
	graph saving("$Tabfigdir/strate_`i'_eth5_agegroup`j'_male", replace) xlab(1"lab1" 2"lab2" 3"lab3" 4"lab4" 5"lab5") title("`i' agegroup `j' male")
	local graphm "`graphm' "$Tabfigdir/strate_`i'_eth5_agegroup`j'_male" "
} //end agegroup

grc1leg `graphm', altshrink  saving("$Tabfigdir/strate_`i'_eth5_agem_combined", replace)
graph export "$Tabfigdir/strate_`i'_eth5_agem_combined", as(svg) replace




} //end outcomes

*************************************************CREATE TABLES
**append datasets
foreach i of global outcomes {
	use  $Tempdir/strate_`i'_eth5, clear
	gen agegroup=99
	gen male=99
		forvalues j=1/7 {
			append using $Tempdir/strate_`i'_eth5_agegroup`j'
			replace agegroup=`j' if agegroup==.
			replace male=99 if male==.
			append using $Tempdir/strate_`i'_eth5_agegroup`j'_female
			replace agegroup=`j' if agegroup==.
			replace male=0 if male==.
			append using $Tempdir/strate_`i'_eth5_agegroup`j'_male
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
save $Tempdir/table4_`i'_eth5.dta, replace

} //end outcomes

*MERGE ALL TABLES INTO ONE DATASET
use $Tempdir/table4_tested_eth5.dta, clear
foreach i of global outcomes {
	merge 1:1 unique using  $Tempdir/table4_`i'_eth5.dta, nogen
}
save $Tabfigdir/table4_eth5, replace
outsheet using $Tabfigdir/table4_eth5.txt, replace



*delete graphs
foreach i of global outcomes {

forvalues j=1/7 {	
	noi erase "$Tabfigdir/strate_`i'_eth5_agegroup`j'.gph"
	noi erase "$Tabfigdir/strate_`i'_eth5_agegroup`j'_female.gph"
	noi erase "$Tabfigdir/strate_`i'_eth5_agegroup`j'_male.gph"
} //end agegroup

} //end outcomes

log close

