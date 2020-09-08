*set filepaths
global Projectdir `c(pwd)'
global Dodir "$Projectdir/analysis" 
di "$Dodir"
global Outdir "$Projectdir/output" 
di "$Outdir"
global Logdir "$Outdir/log"
di "$Logdir"
global Tempdir "$Outdir/tempdata" 
di "$Tempdir"
global Tabfigdir "$Outdir/tabfig" 
di "$Tabfigdir"

cd  "`c(pwd)'/analysis"

adopath + "$Dodir/adofiles"
sysdir
sysdir set PLUS "$Dodir/adofiles"

cd  "$Projectdir"

***********************HOUSE-KEEPING*******************************************
* Create directories required 

capture mkdir "$Outdir/log"
capture mkdir "$Outdir/tempdata"
capture mkdir "$Outdir/tabfig"

* Set globals that will print in programs and direct output
global outdir  	  "$Outdir" 
global logdir     "$Logdir"
global tempdir    "$Tempdir"


* Set globals for  outcomes
global outcomes "tested positivetest ae icu onscoviddeath ons_noncoviddeath onsdeath cpnsdeath"

/* Main Model=================================================================*/
foreach i of global outcomes {
* Open Stata dataset

use "$Tempdir/analysis_dataset_STSET_`i'_eth16_mi.dta", clear

/* Multivariable models */ 

if "`1'"=="demog"{
*Age and gender
mi estimate, dots eform: stcox i.ethnicity_16 i.male age1 age2 age3, strata(stp) nolog
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_`i'_eth16", replace) idstr("model0_`i'_eth16")
local hr "`hr' "$Tempdir/model0_`i'_eth16" "
estimates save "./output/an_imputed_demog_eth16", replace						
}


if "`1'"=="full"{
						
* Age, Gender, IMD and Comorbidities  and household size and carehome
  mi estimate, dots eform: stcox i.ethnicity_16 i.male age1 age2 age3 	i.imd						///
										bmi	hba1c_pct				///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension bp_map		 	///	
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
										i.ra_sle_psoriasis			///
										i.hh_total_cat i.carehome, strata(stp) nolog		
	
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_`i'_eth16", replace) idstr("model3_`i'_eth16") 
local hr "`hr' "$Tempdir/model3_`i'_eth16" "
estimates save "./output/an_imputed_full_eth16", replace						
}

} //end outcomes

************************************************create forestplot dataset
dsconcat `hr'
duplicates drop
*save dataset for later
outsheet using "$Tabfigdir/FP_mi_eth16.txt", replace

* Close log file 
log close
insheet using "$Tabfigdir/FP_mi_eth16.txt", clear


