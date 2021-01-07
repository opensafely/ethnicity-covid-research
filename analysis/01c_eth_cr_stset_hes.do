/*==============================================================================
DO FILE NAME:			01b_eth_cr_stset_hes_covid
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
log using ./logs/01b_eth_cr_stset_hes_covid, replace t

global outcomes "hes icu onscoviddeath"

****************************************************************
*  Create outcome specific datasets for the whole population  *
*****************************************************************


foreach i of global outcomes {
	use ./output/analysis_dataset.dta, clear
	drop if `i'_date <= indexdate 
	stset stime_`i', fail(`i') 				///	
	id(patient_id) enter(indexdate) origin(indexdate)
	save ./output/analysis_dataset_STSET_`i'.dta, replace
}	


	
* Close log file 
log close

