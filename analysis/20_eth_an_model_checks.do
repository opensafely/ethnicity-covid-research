/*==============================================================================
DO FILE NAME:			20_eth_an_model_checks
PROJECT:				Ethnicity & COVID
DATE: 					11th Dec 2020
AUTHOR:					R. Mathur based on A Schultze 
VERSION: 				Stata 16.1									
DESCRIPTION OF FILE:	program 20 
						check the PH assumption, produce graphs 
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table4, printed to analysis/$outdir
						schoenplots1-x, printed to analysis?$outdir 
							
==============================================================================*/

* Open a log file

cap log close
log using "$Logdir/20_eth_an_model_checks", replace t

* Open Stata dataset
foreach i of global alloutcomes {
	di "`i'"
	
	use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear
	drop if carehome==1

/* Quietly run models, perform test and store results in local macro==========*/

qui stcox i.eth5 
estat phtest, detail
local univar_p = round(r(p),0.001)
di `univar_p'
 
estat phtest, plot(1.eth5) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, univariable", position(11) size(medsmall)) 

graph export "$Tabfigdir/schoenplot1_`i'.svg", as(svg) replace

* Close window 
graph close  
			  
stcox i.eth5 i.male age1 age2 age3 
estat phtest, detail
local multivar1_p = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.eth5) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, age and sex adjusted", position(11) size(medsmall)) 			  

graph export "$Tabfigdir/schoenplot2_`i'.svg", as(svg) replace

* Close window 
graph close
		  
stcox i.eth5 i.male age1 age2 age3  	i.imd						///
										i.bmicat_sa	i.hba1ccat			///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension i.bp_cat	 	///	
										i.asthma					///
										i.chronic_respiratory_disease ///
										i.chronic_cardiac_disease	///
										i.dm_type 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.egfr60					///
										i.esrf						///
										i.immunosuppressed	 		///
										i.ra_sle_psoriasis, strata(stp)	nolog
estat phtest, detail
local multivar2_p = round(r(phtest)[2,4],0.001)
 
estat phtest, plot(1.eth5) ///
			  graphregion(fcolor(white)) ///
			  ylabel(, nogrid labsize(small)) ///
			  xlabel(, labsize(small)) ///
			  xtitle("Time", size(small)) ///
			  ytitle("Scaled Shoenfeld Residuals", size(small)) ///
			  msize(small) ///
			  mcolor(gs6) ///
			  msymbol(circle_hollow) ///
			  scheme(s1mono) ///
			  title ("Schoenfeld residuals against time, fully adjusted", position(11) size(medsmall)) 		  
			  
graph export "$Tabfigdir/schoenplot3_`i'.svg", as(svg) replace

* Close window 
graph close
}
* Print table of results======================================================*/	


cap file close tablecontent
file open tablecontent using "$Tabfigdir/Table_phtest_eth16.txt", write text replace

* Column headings 
file write tablecontent ("Table 4: Testing the PH assumption for $tableoutcome- $population Population") _n
file write tablecontent _tab ("Univariable") _tab ("Age/Sex Adjusted") _tab ///
						("Age/Sex and Comorbidity Adjusted") _tab _n
						
file write tablecontent _tab ("p-value") _tab ("p-value") _tab ("p-value") _tab _n

* Row heading and content  
file write tablecontent ("Treatment eth5") _tab
file write tablecontent ("`univar_p'") _tab ("`multivar1_p'") _tab ("`multivar2_p'")

file write tablecontent _n
file close tablecontent

* Close log file 
log close
