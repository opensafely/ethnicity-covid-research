********************************************************************************
*
*	Do-file:		03_eth_an_descriptive_tables.do
*
*	Project:		Ethnicity and  COVID
*	Programmed by:	R Mathur based on E Williamson
*
*	Data used:		analysis_dataset.dta
*
*	Data created:	None
*
*	Other output:	Log file: output/log/03_eth_an_descriptive_tables.log
*
********************************************************************************
*
*	Purpose:		This do-file runs some basic tabulations on the analysis
*					dataset.
*  
********************************************************************************



* Open a log file
capture log close
log using $logdir/03_eth_an_descriptive_tables, replace t

* Open Stata dataset
use $tempdir/analysis_dataset, clear


**********************************
*  Distribution in whole cohort  *
**********************************


* Demographics
tab ethnicity
tab ethnicity, m
tab ethnicity_16
tab ethnicity_16, m

tab ethnicity ethnicity_16, m

summ age
tab agegroup
tab male
tab bmicat
tab bmicat, m
tab bmicat_sa
tab bmicat_sa, m
tab obese4cat
tab obese4cat, m
tab obese4cat_sa, m
tab smoke
tab smoke, m
tab bpcat
tab bpcat, m
tab htdiag_or_highbp


* Comorbidities
tab chronic_respiratory_disease
tab asthma
tab chronic_cardiac_disease
tab cancer
tab chronic_liver_disease
tab dm_type
tab perm_immunodef
tab temp_immunodef
tab other_neuro
tab dementia
tab stroke
tab esrf
tab hypertension
tab reduced_kidney_function_cat
tab ra_sle_psoriasis

tab imd 
tab imd, m


tab stp
tab region
tab rural_urban


* Outcomes
foreach i of global outcomes {
	tab  `i'
}


**********************************
*  Number (%) with each outcome  *
**********************************

foreach outvar of global outcomes {
							
	* Demographics
	tab agegroup 							`outvar', col
	tab male 								`outvar', col
	tab ethnicity							`outvar', col m
	tab ethnicity_16						`outvar', col m
	tab bmicat 								`outvar', col m 
	tab obese4cat							`outvar', col m 
	tab bmicat_sa							`outvar', col m 
	tab obese4cat_sa						`outvar', col m 
	tab smoke 								`outvar', col m

	* Comorbidities
	tab chronic_respiratory_disease 		`outvar', col
	tab asthma 								`outvar', col
	tab asthmacat							`outvar', col
	tab chronic_cardiac_disease 			`outvar', col
	tab dm_type								`outvar', col
	tab dm_type_exeter_os					`outvar', col
	tab cancer								`outvar', col
	tab chronic_liver_disease 				`outvar', col
	tab stroke 								`outvar', col
	tab dementia 							`outvar', col
	tab other_neuro 						`outvar', col
	tab reduced_kidney_function_cat			`outvar', col
	tab ra_sle_psoriasis					`outvar', col
	
	tab imd  								`outvar', col m
	tab rural_urban							`outvar', col
	tab region 								`outvar', col
}


********************************************
*  Cumulative incidence of EACH OUTCOME *
********************************************
foreach i of global outcomes {
	use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear
	tab `i'
	sts list , at(0 80) by(agegroup male) fail
}

* Close the log file
log close


