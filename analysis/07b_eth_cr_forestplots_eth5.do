/*==============================================================================
DO FILE NAME:			08_eth_cr_forestplots_eth5
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur 
DATE: 					18 July 2020					
DESCRIPTION OF FILE:	program 08 
						create forest plots for complete case analysis eth5

DATASETS CREATED: 		parmest output from 06a_eth_an_multivariable_eth5
OTHER OUTPUT: 			forestplot for eth5 complete case analysis
==============================================================================*/
clear

* Open a log file
cap log close
log using $logdir\08b_eth_cr_forestplots_eth5, replace 

foreach i of global outcomes {
local hr "`hr' "$Tempdir/model1_`i'_eth5.dta" "
local hr "`hr' "$Tempdir/model2_`i'_eth5.dta" "
local hr "`hr' "$Tempdir/model3_`i'_eth5.dta" "
}


cap append using `hr'
duplicates drop

split idstr, p(_)
drop idstr
ren idstr1 model
ren idstr2 outcome
drop idstr3 idstr4

replace outcome="ONS non-COVID death" if outcome=="ons"


*keep HRs for ethnic group
keep if label=="Eth 5 categories"
drop label

gen eth5=1 if regexm(parm, "1b")
forvalues i=2/5 {
	replace eth5=`i' if regexm(parm, "`i'.eth5")
}

drop parm
order outcome model eth5

 label define eth5	 	1 "White"  					///
						2 "South Asian"				///						
						3 "Black"  					///
						4 "Mixed"	///
						5 "Other"					///
					

label values eth5 eth5
tab eth5, m

graph set window 
gen num=[_n]
sum num
l
sort num
replace model="" if eth5!=1
save "$Tempdir/HR_forestplot_eth5_cc.dta", replace

*Create one graph per outcome
foreach i of global outcomes {
metan estimate min95 max95 if outcome=="`i'" ///
 , effect(HR) null(1) lcols(model eth5) by(outcome) dp(2) ///
	nowt nosubgroup  nooverall nobox graphregion(color(white)) scheme(sj)  	///
	title("`i'", size(medsmall)) ///
	t2title("complete case analysis", size(small)) ///
	graphregion(margin(zero)) ///
	saving("$Tabfigdir\Forestplot_`i'_eth5_cc.gph", replace)
	graph export "$Tabfigdir\Forestplot_`i'_eth5_cc.svg", replace  
} //end outcomes

*Create one graph for all fully adjusted outcomes
metan estimate min95 max95 if model=="model3" ///
 , effect(HR) null(1) lcols(outcome eth5) dp(2) ///
	nowt  nooverall nobox graphregion(color(white)) scheme(sj)  	///
	title("fully adjusted eth5'", size(medsmall)) ///
	t2title("complete case analysis", size(small)) ///
	graphregion(margin(zero)) ///
	saving("$Tabfigdir\Forestplot_alloutcomes_eth5_cc.gph", replace)
	graph export "$Tabfigdir\Forestplot_alloutcomes_eth5_cc.svg", replace  

*close log file
log close
