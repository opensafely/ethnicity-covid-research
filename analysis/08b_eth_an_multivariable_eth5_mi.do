/*==============================================================================
DO FILE NAME:			08b_eth_an_multivariable_eth5_mi
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
log using $logdir\08b_eth_an_multivariable_eth5_mi, replace text


foreach i of global outcomes {
* Open Stata dataset
use "$Tempdir/analysis_dataset_STSET_`i'.dta", clear

*mi set the data
mi set mlong

*mi register 
replace eth5=. if eth5==6 //set unknown to missing
mi register imputed eth5

*mi impute the dataset - remove variables with missing values - bmi	hba1c_pct bp_map 
noisily mi impute mlogit eth5 `i' i.stp i.male age1 age2 age3 i.imd 	 ///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension 		 	///	
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
										i.ra_sle_psoriasis		///			
										i.hh_total_cat ///
										i.carehome, ///
										add(10) rseed(70548) augment force // can maybe remove the force option in the server
										

*mi stset
mi	stset stime_`i', fail(`i') 	id(patient_id) enter(indexdate) origin(indexdate)

 
/* Main Model=================================================================*/

/* Multivariable models */ 
*Age and gender
  mi estimate, dots eform: stcox i.eth5 i.male age1 age2 age3, strata(stp) nolog
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_`i'_eth5", replace) idstr("model0_`i'_eth5")
local hr "`hr' "$Tempdir/model0_`i'_eth5" "
 

						
* Age, Gender, IMD and Comorbidities  and household size and carehome
  mi estimate, dots eform: stcox i.eth5 i.male age1 age2 age3 	i.imd						///
										bmi	hba1c_pct				///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension bp_map		 	///	
										i.asthma					///
										chronic_respiratory_disease ///
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
										i.hh_total_cat i.carehome, strata(stp) nolog		
	
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_`i'_eth5", replace) idstr("model3_`i'_eth5") 
local hr "`hr' "$Tempdir/model3_`i'_eth5" "

} //end outcomes

************************************************create forestplot dataset
dsconcat `hr'
duplicates drop
split idstr, p(_)
ren idstr1 model
ren idstr2 outcome
drop idstr idstr3 idstr4
tab model

gen eth5=1 if regexm(parm, "1b")
forvalues i=2/11 {
	replace eth5=`i' if regexm(parm, "`i'.eth5")
}

drop parm  stderr dof t 
order outcome model eth5 

destring eth5, replace
label define eth5 	///
						1 "White" ///
						2 "South Asian" ///
						3 "Black" ///
						4 "Mixed" ///
						5 "Other" ///
						6 "Unknown" 					
label values eth5 eth5

gen num=[_n]
sum num

gen adjusted="Crude" if model=="crude"
replace adjusted="Age-sex" if model=="model0"
replace adjusted="+ IMD" if model=="model1"
replace adjusted="+ co-morbidities" if model=="model2"
replace adjusted="+ household size & carehome" if model=="model3"

*save dataset for later
outsheet using "$Tabfigdir/FP_mi_eth5.txt", replace

* Close log file 
log close
insheet using "$Tabfigdir/FP_mi_eth5.txt", clear


