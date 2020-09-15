/*==============================================================================
DO FILE NAME:			08b_eth_cr_imputed_eth5
PROJECT:				NSAID in COVID-19 
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 07
						univariable regression using multiple imputation for ethnicity
						multivariable regression using multiple imputation for ethnicity
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2_eth5_mi, printed to analysis/$outdir
						
https://stats.idre.ucla.edu/stata/seminars/mi_in_stata_pt1_new/						
							
==============================================================================*/

* Open a log file
cap log close
macro drop hr
estimates clear
log using $logdir\08b_eth_cr_imputed_mi_eth5, replace text


foreach i of global outcomes {
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear

*mi set the data
mi set mlong

*mi register 
replace eth5=. if eth5==6 //set unknown to missing
mi register imputed eth5

*mi impute the dataset - remove variables with missing values - bmi	hba1c_pct bp_map 
noisily mi impute mlogit eth5 `i' i.stp i.male age1 age2 age3 	i.imd						///
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
										i.hh_total_cat i.carehome, ///
										add(10) rseed(70548) augment force // can maybe remove the force option in the server
										

*mi stset
mi	stset stime_`i', fail(`i') 	id(patient_id) enter(indexdate) origin(indexdate)
save "$Tempdir/analysis_dataset_STSET_`i'_eth5_mi.dta", replace
}
 

log close

