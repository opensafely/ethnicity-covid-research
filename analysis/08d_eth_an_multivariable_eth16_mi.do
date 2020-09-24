/*==============================================================================
DO FILE NAME:			08d_eth_an_multivariable_eth16
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 08
						multivariable regression with multiple imputation
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome_eth16_mi)
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						estimates output to dataset							
==============================================================================*/

cap log close
macro drop hr
log using "$Logdir/08d_eth_an_mi_eth16", replace t 

/* Main Model=================================================================*/
foreach i of global outcomes {
* Open Stata dataset

use "$Tempdir/analysis_dataset_STSET_`i'_eth16_mi.dta", clear

/* Multivariable models */ 
					
* Age, Gender, IMD and Comorbidities  and household size and carehome
mi estimate, dots eform: stcox i.ethnicity_16 i.male age1 age2 age3 	i.imd						///
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
										i.ra_sle_psoriasis			///
										i.hh_total_cat i.carehome, strata(stp) nolog		
	
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_`i'_eth16_mi", replace) idstr("model3_`i'_eth16") 
local hr "`hr' "$Tempdir/model3_`i'_eth16_mi" "

* Age, Gender, IMD and Comorbidities  and household size no carehome
mi estimate, dots eform: stcox i.ethnicity_16 i.male age1 age2 age3 	i.imd						///
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
										i.ra_sle_psoriasis			///
										i.hh_total_cat if carehome==0, strata(stp) nolog		
estimates save "$Tempdir/model4_`i'_eth16_mi", replace
eststo model6

parmest, label eform format(estimate p lb ub) saving("$Tempdir/model4_`i'_eth16_mi", replace) idstr("model4_`i'_eth16_mi") 
local hr "`hr' "$Tempdir/model4_`i'_eth16_mi" "

* Age, Gender, IMD and Comorbidities carehomes only
mi estimate, dots eform: stcox i.ethnicity_16  i.male age1 age2 age3 	i.imd						///
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
										i.ra_sle_psoriasis			///
										if carehome==1, strata(stp) nolog		
estimates save "$Tempdir/model5_`i'_eth16_mi", replace
eststo model7

parmest, label eform format(estimate p lb ub) saving("$Tempdir/model5_`i'_eth16_mi", replace) idstr("model5_`i'_eth16_mi") 
local hr "`hr' "$Tempdir/model5_`i'_eth16_mi" "



} //end outcomes

************************************************create forestplot dataset
dsconcat `hr'
duplicates drop
split idstr, p(_)
ren idstr1 model
ren idstr2 outcome
drop idstr idstr3
tab model

*save dataset for later
outsheet using "$Tabfigdir/FP_mi_eth16.txt", replace

* Close log file 
log close

insheet using "$Tabfigdir/FP_mi_eth16.txt", clear

