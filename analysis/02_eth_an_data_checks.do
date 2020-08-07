/*==============================================================================
DO FILE NAME:			02_an_data_checks
PROJECT:				Ethnicity and COVID
AUTHOR:					Rohini Mathur Adapted from H Forbes, A Wong, A Schultze, C Rentsch
						 K Baskharan, E Williamson
DATE: 					12th July 2020
DESCRIPTION OF FILE:	Run sanity checks on all variables
							- Check variables take expected ranges 
							- Cross-check logical relationships 
							- Explore expected relationships 
							- Check stsettings 
DATASETS USED:			$tempdir\`analysis_dataset'.dta
DATASETS CREATED: 		None
OTHER OUTPUT: 			Log file: $logdir\02_an_data_checks
							
==============================================================================*/

* Open a log file

capture log close
log using "$Logdir/02_an_data_checks", replace t

numlabel, add

* Open Stata dataset
use "$Tempdir/analysis_dataset.dta", clear


*Duplicate patient check
datacheck _n==1, by(patient_id) nol


/* CHECK INCLUSION AND EXCLUSION CRITERIA=====================================*/ 

* DATA STRUCTURE: Confirm one row per patient 
duplicates tag patient_id, generate(dup_check)
cap assert dup_check == 0 
drop dup_check

* INCLUSION 1: >=18 and <=110 at 1 Feb 2020 
cap assert age < .
cap assert age >= 18 
cap assert age <= 110
 
* INCLUSION 2: M or F gender at 1 Feb 2020 
cap assert inlist(sex, "M", "F")

* EXCLUDE 1:  MISSING IMD
cap assert inlist(imd, 1, 2, 3, 4, 5)


/* EXPECTED VALUES============================================================*/ 

*HH
summ hh_size
datacheck inlist(hh_size, 1, 2, 3, 4, 5,6, 7, 8, 9, 10), nol

safetab hh_total_cat, m
datacheck inlist(hh_total_cat, 0, 1, 2), nol

*Care home
safetab carehome
safetab carehome hh_total_cat, m

* Age
summ age
datacheck age<., nol
datacheck inlist(agegroup, 1, 2, 3, 4, 5, 6, 7), nol
datacheck inlist(age66, 0, 1), nol

* Sex
safetab male, m
datacheck inlist(male, 0, 1), nol

* BMI 
summ bmi
safetab obese4cat, m 
datacheck inlist(obese4cat, 1, 2, 3, 4), nol

safetab obese4cat_sa, m
datacheck inlist(obese4cat_sa, 1, 2, 3, 4), nol

safetab bmicat, m
datacheck inlist(bmicat, 1, 2, 3, 4, 5, 6, .u), nol

safetab bmicat_sa, m
datacheck inlist(bmicat_sa, 1, 2, 3, 4, 5, 6, .u), nol

* IMD
summ imd
safetab imd, m
datacheck inlist(imd, 1, 2, 3, 4, 5), nol

* Ethnicity
safetab ethnicity
datacheck inlist(ethnicity, 1, 2, 3, 4, 5), nol

safetab eth5,m
datacheck inlist(eth5, 1, 2, 3, 4, 5, .), nol

safetab ethnicity_16,m
datacheck inlist(ethnicity_16, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, .), nol

safetab eth16,m
datacheck inlist(eth16, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, .), nol

* Smoking
datacheck inlist(smoke, 1, 2, 3, .u), nol
datacheck inlist(smoke_nomiss, 1, 2, 3), nol 


* Check date ranges for all variables - keep in mind they'll all be 15th of the month!

foreach var of varlist  *date {
	format `var' %d
	summ `var', format
}

**********************************
*  Distribution in whole cohort  *
**********************************

* Comorbidities
safetab bpcat
safetab bpcat, m
safetab htdiag_or_highbp
safetab chronic_respiratory_disease
safetab asthma
safetab chronic_cardiac_disease
safetab cancer
safetab chronic_liver_disease
safetab diabcat
safetab perm_immunodef
safetab temp_immunodef
safetab other_neuro
safetab dementia
safetab stroke
safetab egfr_cat
safetab egfr60
safetab esrf
safetab hypertension
safetab ra_sle_psoriasis
safetab stp
safetab region
safetab rural_urban


/* LOGICAL RELATIONSHIPS======================================================*/ 

*HH variables
summ hh_size hh_total

* BMI
bysort bmicat: summ bmi
bysort bmicat_sa: summ bmi

safetab bmicat obese4cat, m
safetab bmicat_sa obese4cat_sa, m

* Age
bysort agegroup: summ age
safetab agegroup age66, m

* Smoking
safetab smoke smoke_nomiss, m

* Diabetes
safetab dm_type
safetab dm_type_exeter_os
tab dm_type dm_type_exeter_os, row col
safetab diabcat

* CKD
safetab egfr60, m

/* EXPECTED RELATIONSHIPS WITH ETHNICITY =======================================*/ 

foreach var in $varlist {	
	safetab `var'
	safetab eth5 `var', row 
	safetab eth16 `var', row
}


/* SENSE CHECK OUTCOMES=======================================================*/
foreach i of global outcomes {
		safetab `i'
		safetab eth5 `i', row
		safetab eth16 `i', row
}

/* ENSURE ENOUGH OUTCOMES IN EACH CATEGORY INCLUDED IN FULLY ADJUSTED MODEL ====*/
foreach i of global outcomes {
	foreach var in $varlist 				{
		local var: subinstr local var "i." ""	
		safetab `i' `var', row 
} //end varlist
} //end outcomes


* Close log file 
log close
