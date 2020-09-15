/*==============================================================================
DO FILE NAME:			08e_eth_an_mi_forestplots
PROJECT:				Ethnicity and COVID
AUTHOR:					R Mathur (modified from A wong and A Schultze)
DATE: 					15 July 2020					
DESCRIPTION OF FILE:	program 08
						multivariable regression with multiple imputation
DATASETS USED:			data in memory ($tempdir/analysis_dataset_STSET_outcome_eth5_mi)
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir
						estimates output to dataset							
==============================================================================*/

cap log close
log using "$Logdir/08e_eth_an_mi_forestplots", replace t 

************************************************create forestplot dataset

*Combine eth5 MI model results
dsconcat ///
	"$Tempdir/demog_tested_eth5_mi"  ///
	"$Tempdir/demog_positivetest_eth5_mi"  ///
	"$Tempdir/demog_ae_eth5_mi"  ///
	"$Tempdir/demog_icu_eth5_mi"  ///
	"$Tempdir/demog_onscoviddeath_eth5_mi"  ///
	"$Tempdir/demog_ons_noncoviddeath_eth5_mi"  ///
	"$Tempdir/model3_tested_eth5_mi"  ///
	"$Tempdir/model3_positivetest_eth5_mi"  ///
	"$Tempdir/model3_ae_eth5_mi"  ///
	"$Tempdir/model3_icu_eth5_mi"  ///
	"$Tempdir/model3_onscoviddeath_eth5_mi"  ///
	"$Tempdir/model3ons_noncoviddeath_eth5_mi"  
duplicates drop
*save dataset for later
outsheet using "$Tabfigdir/FP_mi_eth5.txt", replace

*Combine eth16 MI model results

dsconcat ///
	"$Tempdir/demog_tested_eth16_mi"  ///
	"$Tempdir/demog_positivetest_eth16_mi"  ///
	"$Tempdir/demog_ae_eth16_mi"  ///
	"$Tempdir/demog_icu_eth16_mi"  ///
	"$Tempdir/demog_onscoviddeath_eth16_mi"  ///
	"$Tempdir/demog_ons_noncoviddeath_eth16_mi"  ///
	"$Tempdir/model3_tested_eth16_mi"  ///
	"$Tempdir/model3_positivetest_eth16_mi"  ///
	"$Tempdir/model3_ae_eth16_mi"  ///
	"$Tempdir/model3_icu_eth16_mi"  ///
	"$Tempdir/model3_onscoviddeath_eth16_mi"  ///
	"$Tempdir/model3ons_noncoviddeath_eth16_mi"  
duplicates drop
*save dataset for later
outsheet using "$Tabfigdir/FP_mi_eth5.txt", replace


log close
