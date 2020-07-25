/********************************************************************************
*
*	Do-file:		04_eth_an_descriptive_plots.do
*
*	Project:		Ethnicity and covid
*
*	Programmed by:	RM based on E Williamson
*
*	Data used:		analysis_dataset_STSET_`j'.dta",
*
*	Data created:	None
*
*	Other output:	Kaplan-Meier plots by outcome
*					
*
********************************************************************************
*
*	Purpose:		This do-file creates Kaplan-Meier plots by ethnic group, age, and sex 
*  
********************************************************************************
*	
*	Stata routines needed:	graph combine	
*
********************************************************************************/

*************************************
*  KM plot by ethnic group 
*************************************

foreach j of global outcomes {
use "$Tempdir/analysis_dataset_STSET_`j'.dta", clear

*KM plot by high level ethnic groups
   sts graph, 				///
	title("`j' eth5") 								///
	failure by(eth5) 						///
	xtitle("Days since 1 Feb 2020", size(small))						///
	yscale(range(0, 0.008)) 						///
	ylabel(0 (0.002) 0.008, angle(0) format(%4.3f))	///
	xscale(range(30, 100)) 							///
	xlabel(0 "1 Feb 20" 29 "1 Mar 20" 				///
	60 "1 Apr 20" 91 "1 May 20" 122 "1 Jun 20"		///
	152 "1 Jul 20")	saving("$Tabfigdir/kmplot_eth5_`j'", replace)
	local graph5 "`graph5' "$Tabfigdir/kmplot_eth5_`j'.gph" "
} //end outcomes

grc1leg `graph5', altshrink saving("$Tabfigdir/kmplot_eth5_combined", replace) ///
	imargin(0 0 0 0)
graph export "$Tabfigdir/kmplot_eth5", as(svg) replace

*erase eth5 graphs
cap erase "$Tabfigdir/kmplot_eth5_combined.gph"
foreach j of global outcomes {
	cap erase "$Tabfigdir/kmplot_eth5_`j'.gph" 
}

foreach j of global outcomes {
use "$Tempdir/analysis_dataset_STSET_`j'.dta", clear

* KM plot by 16  ethnic groups
sts graph, 				///
	title("`j' eth16") 								///
	failure by(eth16) 						///
	xtitle("Days since 1 Feb 2020", size(small))						///
	yscale(range(0, 0.008)) 						///
	ylabel(0 (0.002) 0.008, angle(0) format(%4.3f))	///
	xscale(range(30, 100)) 							///
	xlabel(0 "1 Feb 20" 29 "1 Mar 20" 				///
	60 "1 Apr 20" 91 "1 May 20" 122 "1 Jun 20"		///
	152 "1 Jul 20") saving("$Tabfigdir/kmplot_eth16_`j'", replace)		
	local graph16 "`graph16' "$Tabfigdir/kmplot_eth16_`j'" "
} //end outcomes
 
grc1leg `graph16', altshrink saving("$Tabfigdir/kmplot_eth16_combined",replace) ///
	imargin(0 0 0 0)
graph export "$Tabfigdir/kmplot_eth16", as(svg) replace

*erase eth16 graphs
cap erase "$Tabfigdir/kmplot_eth16_combined.gph"
foreach j of global outcomes {
	cap erase "$Tabfigdir/kmplot_eth16_`j'.gph" 
}

*************************************
*  KM plot by ethnic group and age/sex
*************************************


foreach j of global outcomes {
use "$Tempdir/analysis_dataset_STSET_`j'.dta", clear
 
* KM plot by 16 level ethnic group and age
forvalues i=1/11 {		
 sts graph if eth16==`i', title("eth `i'") 			///
	failure by(agegroup) 							///
	xtitle("Days since 1 Feb 2020", size(small))	///
	yscale(range(0, 0.008)) 						///
	ylabel(0 (0.002) 0.008, angle(0) format(%4.3f))	///
	xscale(range(30, 100)) 							///
	xlabel(0 "1 Feb 20" 29 "1 Mar 20" 				///
	60 "1 Apr 20" 91 "1 May 20" 122 "1 Jun 20"		///
	152 "1 Jul 20")									///
	legend(order(1 2 3 4 5 6)						///
	subtitle("Age group", size(small)) 				///
	label(1 "18-<40") label(2 "40-<50") 			///
	label(3 "50-<60") label(4 "60-<70")				///
	label(5 "70-<80") label(6 "80+")				///
	col(3) colfirst size(small))	noorigin		///
	saving($Tabfigdir/kmplot_eth`i'_age, replace)
}


* KM plot by ethnicity and age
 graph combine "$Tabfigdir/kmplot_eth1_age"				///
		"$Tabfigdir/kmplot_eth2_age"				///
		"$Tabfigdir/kmplot_eth3_age"				///
		"$Tabfigdir/kmplot_eth4_age"				///
		"$Tabfigdir/kmplot_eth5_age"				///
		"$Tabfigdir/kmplot_eth6_age"				///
		"$Tabfigdir/kmplot_eth7_age"				///
		"$Tabfigdir/kmplot_eth8_age"				///
		"$Tabfigdir/kmplot_eth9_age"				///
		"$Tabfigdir/kmplot_eth10_age"				///
		"$Tabfigdir/kmplot_eth11_age",				///
		t1(" ") l1title("Cumulative probability of `j' by ethnic group and age ", size(medsmall))
 graph export "$Tabfigdir/km_`j'_eth16_age.svg", as(svg) replace


* KM plot by 16 level ethnic group and sex
forvalues i=1/11 {		
	 sts graph if eth16==`i', title("eth`i'") 				///
	failure by(male)										///
	xtitle("Days since 1 Feb 2020", size(small))						///
	yscale(range(0, 0.008)) 						///
	ylabel(0 (0.002) 0.008, angle(0) format(%4.3f))	///
	xscale(range(30, 100)) 							///
	xlabel(0 "1 Feb 20" 29 "1 Mar 20" 				///
	60 "1 Apr 20" 91 "1 May 20" 122 "1 Jun 20"		///
	152 "1 Jul 20")									///
	legend(order(1 2)						///
	subtitle("Sex", size(small)) 				///
	label(1 "Female") label(2 "Male") 			///
	col(3) colfirst size(small))	noorigin		///
	saving($Tabfigdir/kmplot_eth`i'_sex, replace)
}


* KM plot by ethnicity and sex
 graph combine "$Tabfigdir/kmplot_eth1_sex"				///
		"$Tabfigdir/kmplot_eth2_sex"				///
		"$Tabfigdir/kmplot_eth3_sex"				///
		"$Tabfigdir/kmplot_eth4_sex"				///
		"$Tabfigdir/kmplot_eth5_sex"				///
		"$Tabfigdir/kmplot_eth6_sex"				///
		"$Tabfigdir/kmplot_eth7_sex"				///
		"$Tabfigdir/kmplot_eth8_sex"				///
		"$Tabfigdir/kmplot_eth9_sex"				///
		"$Tabfigdir/kmplot_eth10_sex"				///
		"$Tabfigdir/kmplot_eth11_sex",				///
		t1(" ") l1title("Cumulative probability of `j' by ethnic group and sex", size(medsmall))
 graph export "$Tabfigdir/km_`j'_eth16_sex.svg", as(svg) replace

* Delete unneeded graphs
forvalues i=1/11 {		
		cap erase "$Tabfigdir/kmplot_eth`i'_age.gph"
		cap erase "$Tabfigdir/kmplot_eth`i'_sex.gph"
} //end outcomes

 
} //end outcomes



	
