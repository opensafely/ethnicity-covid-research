********************************************************************************
*
*	Do-file:		03_eth_an_descriptive_safetables.do
*
*	Project:		Ethnicity and  COVID
*	Programmed by:	R Mathur based on E Williamson
*
*	Data used:		analysis_dataset.dta
*
*	Data created:	None
*
*	Other output:	Log file: output/log/03_eth_an_descriptive_safetables.log
*
********************************************************************************
*
*	Purpose:		This do-file runs some basic safetabulations on the analysis
*					dataset.
*  
********************************************************************************



* Open a log file
capture log close
log using $logdir/03_eth_an_descriptive_tables, replace text

* Open Stata dataset
use $tempdir/analysis_dataset, clear


**********************************
*  Distribution in whole cohort  *
**********************************


* Demographics
safetab ethnicity
safetab ethnicity, m
safetab ethnicity_16
safetab ethnicity_16, m

safetab ethnicity ethnicity_16, m

summ age
safetab agegroup
safetab male
safetab bmicat
safetab bmicat, m
safetab bmicat_sa
safetab bmicat_sa, m
safetab obese4cat
safetab obese4cat, m
safetab obese4cat_sa, m
safetab smoke
safetab smoke, m
safetab bpcat
safetab bpcat, m
safetab htdiag_or_highbp


* Comorbidities
safetab chronic_respiratory_disease
safetab asthma
safetab chronic_cardiac_disease
safetab cancer
safetab chronic_liver_disease
safetab dm_type
safetab perm_immunodef
safetab temp_immunodef
safetab other_neuro
safetab dementia
safetab stroke
safetab esrf
safetab hypertension
safetab reduced_kidney_function_cat
safetab ra_sle_psoriasis

safetab imd 
safetab imd, m


safetab stp
safetab region
safetab rural_urban


* Outcomes
foreach i of global outcomes {
	safetab  `i'
}


**********************************
*  Number (%) with each outcome  *
**********************************

foreach outvar of global outcomes {
							
	* Demographics
	safetab agegroup 							`outvar', col
	safetab male 								`outvar', col
	safetab ethnicity							`outvar', col m
	safetab ethnicity_16						`outvar', col m
	safetab bmicat 								`outvar', col m 
	safetab obese4cat							`outvar', col m 
	safetab bmicat_sa							`outvar', col m 
	safetab obese4cat_sa						`outvar', col m 
	safetab smoke 								`outvar', col m

	* Comorbidities
	safetab chronic_respiratory_disease 		`outvar', col
	safetab asthma 								`outvar', col
	safetab asthmacat							`outvar', col
	safetab chronic_cardiac_disease 			`outvar', col
	safetab dm_type								`outvar', col
	safetab dm_type_exeter_os					`outvar', col
	safetab cancer								`outvar', col
	safetab chronic_liver_disease 				`outvar', col
	safetab stroke 								`outvar', col
	safetab dementia 							`outvar', col
	safetab other_neuro 						`outvar', col
	safetab reduced_kidney_function_cat			`outvar', col
	safetab ra_sle_psoriasis					`outvar', col
	
	safetab imd  								`outvar', col m
	safetab rural_urban							`outvar', col
	safetab region 								`outvar', col
	safetab hh_size 							`outvar', col
	safetab carehome							`outvar', col


}


********************************************
*  Cumulative incidence of EACH OUTCOME *
********************************************
foreach i of global outcomes {
	use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear
	safetab `i'
	sts list , at(0 80) by(agegroup male) fail
}

* Close the log file
log close


