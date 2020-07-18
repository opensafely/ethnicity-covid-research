/*==============================================================================
DO FILE NAME:			07a_eth_an_multivariable_eth16_mi
PROJECT:				NSAID in COVID-19 
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 07
						univariable regression using multiple imputation for ethnicity
						multivariable regression using multiple imputation for ethnicity
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						table2_eth16_mi, printed to analysis/$outdir
						
https://stats.idre.ucla.edu/stata/seminars/mi_in_stata_pt1_new/						
							
==============================================================================*/

local i `1' 


* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear


*mi set the data
mi set mlong

*mi register 
mi register imputed eth16

*mi impute the dataset
mi impute mlogit eth16, add(10) rseed(2232)

*mi stset
mi	stset stime_`i', fail(`i') 	id(patient_id) enter(enter_date) origin(enter_date)

 
/* Main Model=================================================================*/

/* Univariable model */ 

cap mi estimate, dots saving("$Tempdir/crude_`i'_eth16", replace) eform: stcox i.eth16 

/* Multivariable models */ 

* Age and Gender 
* Age fit as spline 
cap mi estimate, dots saving("$Tempdir/model1_`i'_eth16", replace) eform: stcox i.eth16 i.male age1 age2 age3 i.imd, strata(stp)

* Age, Gender and Comorbidities  
cap mi estimate, dots saving("$Tempdir/model2_`i'_eth16", replace) eform: stcox i.eth16 i.male age1 age2 age3 	i.imd							///
										bmi							///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.htdiag_or_highbp		 	///	
										i.asthma					///
										i.chronic_cardiac_disease	///
										i.dm_type 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.ckd						///
										i.esrf						///
										i.perm_immunodef 			///
										i.temp_immunodef 			///
										i.other_immuno		 		///
										i.ra_sle_psoriasis, strata(stp)				
										

cap mi estimate, dots saving("$Tempdir/model3_`i'_eth16", replace) eform: stcox i.eth16 i.male age1 age2 age3 i.imd hh_size					///
										bmi							///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.htdiag_or_highbp		 	///	
										i.asthma					///
										i.chronic_cardiac_disease	///
										i.dm_type 					///	
										i.cancer                    ///
										i.chronic_liver_disease		///
										i.stroke					///
										i.dementia					///
										i.other_neuro				///
										i.ckd						///
										i.esrf						///
										i.perm_immunodef 			///
										i.temp_immunodef 			///
										i.other_immuno		 		///
										i.ra_sle_psoriasis, strata(stp)				
										

