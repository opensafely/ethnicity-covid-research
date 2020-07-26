/*==============================================================================
DO FILE NAME:			07_eth_cr_forestplots_eth16
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur 
DATE: 					18 July 2020					
DESCRIPTION OF FILE:	program 08 
						create forest plots for complete case analysis eth16
DATASETS CREATED: 		parmest output from 06a_eth_an_multivariable_eth16
OTHER OUTPUT: 			forestplot for eth16 complete case analysis
==============================================================================*/
* Open a log file
cap log close
log using $logdir\07_eth_cr_forestplots, replace t

insheet using "$Tabfigdir/FP_multivariable_eth16.txt"


*Create one graph per outcome
replace model="" if eth16!=1
foreach i of global outcomes {
metan log_estimate log_min95 log_max95 if outcome=="`i'" ///
 , eform random effect(Hazard Ratio) null(1) lcols(model eth16) by(outcome) dp(2) xlab(.25,.5,1,2,4) ///
	nowt nosubgroup  nooverall nobox graphregion(color(white)) scheme(sj) texts(100) astext(65)  	///
	title("`i'", size(medsmall)) ///
	t2title("complete case analysis", size(small)) ///
	graphregion(margin(zero)) ///
	*Export graph
graph export "$Tabfigdir\Forestplot_`i'_eth16_cc.svg", replace  
} //end outcomes
}


insheet using "$Tabfigdir/FP_multivariable_eth5.txt"

*Create one graph per outcome
replace model="" if eth5!=1
foreach i of global outcomes {
metan log_estimate log_min95 log_max95 if outcome=="`i'" ///
 , eform random effect(Hazard Ratio) null(1) lcols(model eth5) by(outcome) dp(2) xlab(.25,.5,1,2,4) ///
	nowt nosubgroup  nooverall nobox graphregion(color(white)) scheme(sj) texts(100) astext(65)  	///
	title("`i'", size(medsmall)) ///
	t2title("complete case analysis", size(small)) ///
	graphregion(margin(zero)) ///
	*Export graph
graph export "$Tabfigdir\Forestplot_`i'_eth5_cc.svg", replace  
} //end outcomes
}
	
log close

