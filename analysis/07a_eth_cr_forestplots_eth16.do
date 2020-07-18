/*==============================================================================
DO FILE NAME:			08_eth_cr_forestplots_eth16
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur 
DATE: 					18 July 2020					
DESCRIPTION OF FILE:	program 08 
						create forest plots for complete case analysis eth16

DATASETS CREATED: 		parmest output from 06a_eth_an_multivariable_eth16
OTHER OUTPUT: 			forestplot for eth16 complete case analysis
==============================================================================*/
clear

foreach i of global outcomes {
local hr "`hr' "$Tempdir/model1_`i'_eth16.dta" "
local hr "`hr' "$Tempdir/model2_`i'_eth16.dta" "
local hr "`hr' "$Tempdir/model3_`i'_eth16.dta" "
}


cap dsconcat `hr'
duplicates drop

split idstr, p(_)
drop idstr
ren idstr1 model
ren idstr2 outcome
drop idstr3 


*keep HRs for ethnic group
keep if label=="Eth 16 collapsed"
drop label

gen eth16=1 if regexm(parm, "1b")
forvalues i=2/11 {
	replace eth16=`i' if regexm(parm, "`i'.eth16")
}

drop parm
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
tab eth16,m

graph set window 
gen num=[_n]
sum num
l
save "$Tempdir/HR_forestplot_eth16_cc.dta", replace

replace model="" if eth16!=1

*Create one graph per outcome
foreach i of global outcomes {
cap metan estimate min95 max95 if outcome=="`i'" ///
 , effect(HR) null(1) lcols(model eth16) by(outcome) dp(2) ///
	nowt nosubgroup  nooverall nobox graphregion(color(white)) scheme(sj)  	///
	title("`i'", size(medsmall)) ///
	t2title("complete case analysis", size(small)) ///
	graphregion(margin(zero)) ///
	saving("$Tabfigdir\Forestplot_`i'_eth16_cc.gph", replace)
	graph export "$Tabfigdir\Forestplot_`i'_eth16_cc.svg", replace  
} //end outcomes

*Create one graph for all fully adjusted outcomes
cap metan estimate min95 max95 if model=="model3" ///
 , effect(HR) null(1) lcols(outcome eth16) dp(2) ///
	nowt  nooverall nobox graphregion(color(white)) scheme(sj)  	///
	title("fully adjusted eth16'", size(medsmall)) ///
	t2title("complete case analysis", size(small)) ///
	graphregion(margin(zero)) ///
	saving("$Tabfigdir\Forestplot_alloutcomes_eth16_cc.gph", replace)
	graph export "$Tabfigdir\Forestplot_alloutcomes_eth16_cc.svg", replace  
	
