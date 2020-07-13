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

*run ssc install if not on local machine - server needs datacheck.ado file
ssc install datacheck 

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
					combination_bp_meds ///
					{
						summ `var'_date, format

}

summ diabetes_date, format


foreach comorb in $varlist { 

	local comorb: subinstr local comorb "i." ""
	tab `comorb', m
	
}

* Outcome dates
local p"suspected confirmed tested positivetest ae icu  cpnsdeath onsdeath onscoviddeath ons_noncoviddeath" //ventilation
foreach i of local p {
	 summ `i'_date, format
}

/* LOGICAL RELATIONSHIPS======================================================*/ 

*HH variables
summ hh_size hh_total

* BMI
bysort bmicat: summ bmi
bysort bmicat_sa: summ bmi

tab bmicat obese4cat, m
tab bmicat_sa obese4cat_sa, m

* Age
bysort agegroup: summ age
tab agegroup age66, m

* Smoking
tab smoke smoke_nomiss, m

* Diabetes
tab diabetes_type
tab diabetes_exeter_os
tab diabetes_type diabetes_exeter_os, row col

* CKD
tab reduced egfr_cat, m


/* EXPECTED RELATIONSHIPS=====================================================*/ 

/*  Relationships between demographic/lifestyle variables  */
tab agegroup bmicat, 	row 
tab agegroup smoke, 	row  
tab agegroup ethnicity, row 
tab agegroup ethnicity_16, row 
tab agegroup imd, 		row 

tab bmicat smoke, 		 row   
tab bmicat ethnicity, 	 row 
tab bmicat ethnicity_16, 	 row 
tab bmicat imd, 	 	 row 
tab bmicat hypertension, row 

tab smoke ethnicity, 	row 
tab smoke ethnicity_16, 	row 
tab smoke imd, 			row 
tab smoke hypertension, row 
                      
tab ethnicity imd, 		row 
tab ethnicity_16 imd, 		row 




* Relationships with age

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
						diabetes_type ///
					{
						tab agegroup `var', row 
 }


 * Relationships with sex
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
						diabetes_type ///
					{
						tab male `var', row 
}

 * Relationships with smoking
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
						diabetes_type ///
					{	
					tab smoke `var', row 
}


/* SENSE CHECK OUTCOMES=======================================================*/

local p"suspected confirmed tested positivetest ae icu  cpnsdeath onscoviddeath ons_noncoviddeath" //ventilation
foreach i of local p {
	tab onsdeath `i', row col
}
* Close log file 
log close
