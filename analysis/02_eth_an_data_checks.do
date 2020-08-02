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
log using $logdir/02_an_data_checks, replace t

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
datacheck inlist(hh_size, 1, 2, 3, 4, 5,6, 7, 8, 9, 10), nol

* Age
datacheck age<., nol
datacheck inlist(agegroup, 1, 2, 3, 4, 5, 6), nol
datacheck inlist(age66, 0, 1), nol

* Sex
datacheck inlist(male, 0, 1), nol

* BMI 
datacheck inlist(obese4cat, 1, 2, 3, 4), nol
datacheck inlist(obese4cat_sa, 1, 2, 3, 4), nol

datacheck inlist(bmicat, 1, 2, 3, 4, 5, 6, .u), nol
datacheck inlist(bmicat_sa, 1, 2, 3, 4, 5, 6, .u), nol

* IMD
datacheck inlist(imd, 1, 2, 3, 4, 5), nol

* Ethnicity
datacheck inlist(ethnicity, 1, 2, 3, 4, 5), nol
datacheck inlist(ethnicity_16, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16), nol

* Smoking
datacheck inlist(smoke, 1, 2, 3, .u), nol
datacheck inlist(smoke_nomiss, 1, 2, 3), nol 


* Check date ranges for all comorbidities - keep in mind they'll all be 15th of the month!

foreach var of varlist  chronic_respiratory_disease 	///
					chronic_cardiac_disease		///
					cancer ///
					perm_immunodef  ///
					temp_immunodef  ///
					chronic_liver_disease  		///
					other_neuro 			///
					stroke ///
					dementia ///
					hypertension	///
					ra_sle_psoriasis				///
					insulin ///
					statin ///
					asthma ///
					combination_bp_meds ///
					{
						summ `var'_date, format

}

summ diabetes_date, format


foreach comorb in $varlist { 

	local comorb: subinstr local comorb "i." ""
	safetab `comorb', m
	
}

foreach i of global outcomes {
	 summ `i'_date, format
}

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
safetab dm_type dm_type_exeter_os, row col
safetab diabcat, row col

* CKD
safetab reduced egfr_cat, m


/* EXPECTED RELATIONSHIPS=====================================================*/ 

/*  Relationships between demographic/lifestyle variables  */
safetab agegroup bmicat, 	row 
safetab agegroup smoke, 	row  
safetab agegroup ethnicity, row 
safetab agegroup ethnicity_16, row 
safetab agegroup imd, 		row 

safetab bmicat smoke, 		 row   
safetab bmicat ethnicity, 	 row 
safetab bmicat ethnicity_16, 	 row 
safetab bmicat imd, 	 	 row 
safetab bmicat hypertension, row 

safetab smoke ethnicity, 	row 
safetab smoke ethnicity_16, 	row 
safetab smoke imd, 			row 
safetab smoke hypertension, row 
                      
safetab ethnicity imd, 		row 
safetab ethnicity_16 imd, 		row 

safetab ethnicity carehome, 		row 
safetab ethnicity_16 carehome, 		row 

safetab ethnicity hh_size, 		row 
safetab ethnicity_16 hh_size, 		row 




 * Relationships with ethnicity
foreach var of varlist 	chronic_respiratory_disease ///
						chronic_cardiac_disease  ///
						cancer  ///
						perm_immunodef  ///
						temp_immunodef  ///
						chronic_liver_disease  ///
						other_neuro  ///
						stroke			///
						dementia ///
						esrf  ///
						hypertension  ///
						asthma ///
						ra_sle_psoriasis  ///
						dm_type ///
					{	
					safetab ethnicity `var', row 
}

foreach var of varlist 	chronic_respiratory_disease ///
						chronic_cardiac_disease  ///
						cancer  ///
						perm_immunodef  ///
						temp_immunodef  ///
						chronic_liver_disease  ///
						other_neuro  ///
						stroke			///
						dementia ///
						esrf  ///
						hypertension  ///
						asthma ///
						ra_sle_psoriasis  ///
						dm_type ///
					{	
					safetab eth16 `var', row 
}



* Close log file 
log close
