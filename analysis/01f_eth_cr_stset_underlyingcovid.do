/*==============================================================================
DO FILE NAME:			01e_eth_cr_stset_onsunderlyingdeath
PROJECT:				Ethnicity 
DATE: 					6th Jan 2020
AUTHOR:					Rohini Mathur 								
DESCRIPTION OF FILE:	program 01, data management for project  
						reformat variables 
						categorise variables
						label variables 
						apply exclusion criteria
DATASETS USED:			data in memory (from analysis/input.csv)
DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder analysis/$logdir


							
==============================================================================*/

* Open a log file
cap log close
log using ./logs/01e_eth_cr_stset_onsunderlyingdeath.log, replace t


****************************************************************
*  Create outcome specific datasets for the whole population  *
*****************************************************************
	use ./output/analysis_dataset.dta, clear
	drop if onsunderlyingdeath_date <= indexdate 
	stset stime_onsunderlyingdeath, fail(onsunderlyingdeath) 				///	
	id(patient_id) enter(indexdate) origin(indexdate)
	save ./output/analysis_dataset_STSET_onsunderlyingdeath.dta, replace

	
* Close log file 
log close

