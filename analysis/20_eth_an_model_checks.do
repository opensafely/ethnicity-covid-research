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
global outcomes "tested positivetest icu hes onscoviddeath ons_noncoviddeath onsdeath"

* Open a log file

cap log close
log using ./logs/20_eth_an_model_checks.log, replace t

cap file close tablecontent
file open tablecontent using ./output/Table_phtest_eth5.txt, write text replace

* Column headings 
file write tablecontent ("Testing the PH assumption for $tableoutcome- $population Population") _n
file write tablecontent _tab ("Univariable") _tab ("Age/Sex Adjusted") _tab ///
						("Fully Adjusted") _tab _n
						
file write tablecontent _tab ("p-value") _tab ("p-value") _tab ("p-value") _tab _n


* Open Stata dataset
foreach i of global outcomes {
	di "`i'"
	
	use ./output/analysis_dataset_STSET_`i'.dta, clear
	drop if carehome==1

/* Quietly run models, perform test and store results in local macro==========*/

stcox i.eth5 
estat phtest, detail
local univar_p = round(r(p),0.001)
di `univar_p'

stphplot, by(eth5) title("`i'") legend(size(tiny) cols(3)) graphregion(color(white))	
graph save ./output/stphplot_crude_`i'.gph, replace

sts graph, by(eth5) 						///
			failure yscale(range(0, 0.012)) 				///
			ylabel(0 (0.0025) 0.01, angle(0) format(%5.4f))	///
			noorigin llegend(size(tiny) cols(3))  			///
			xscale(range(30, 84)) title("`i'") 							///
			xlabel(30 (10) 80)	graphregion(color(white)) 					

graph save ./output/kmplot_crude_`i'.gph, replace

stcox i.eth5 i.male age1 age2 age3										
estat phtest, detail
local multivar2_p = round(r(phtest)[2,4],0.001)
di `multivar2_p'

stphplot, by(eth5) title("age-sex")	legend(size(tiny) cols(3)) graphregion(color(white))	
graph save ./output/stphplot_agesex_`i'.gph, replace
			  		  
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
local multivar3_p = round(r(phtest)[2,4],0.001)
di `multivar3_p'

stphplot, by(eth5) title("fully adjusted") legend(size(tiny) cols(3)) 	graphregion(color(white)) 
graph save ./output/stphplot_full_`i'.gph, replace


* Print table of results======================================================*/	


file write tablecontent ("`i'") _tab  ("`univar_p'") _tab ("`multivar2_p'") _tab ("`multivar3_p'") _n
} //end outcomes

file close tablecontent

*output kmplots
grc1leg ./output/kmplot_crude_tested.gph ///
				./output/kmplot_crude_positivetest.gph ///
				./output/kmplot_crude_hes.gph ///
				./output/kmplot_crude_icu.gph ///
				./output/kmplot_crude_onscoviddeath.gph ///
				./output/kmplot_crude_ons_noncoviddeath.gph, graphregion(color(white)) cols(2) altshrink
graph export ./output/kmplots_combined.svg, as(svg) replace

*combine stph plots
grc1leg ./output/stphplot_crude_tested.gph ///
				./output/stphplot_crude_positivetest.gph ///
				./output/stphplot_crude_hes.gph ///
				./output/stphplot_crude_icu.gph ///
				./output/stphplot_crude_onscoviddeath.gph ///
				./output/stphplot_crude_ons_noncoviddeath.gph,  ///
				graphregion(color(white)) cols(2) xsize(4) ysize(7) 
				
graph export ./output/stphplots_combined.svg, as(svg) replace

* Close log file 
log close

insheet using ./output/Table_phtest_eth5.txt, clear
