/* Main Model=================================================================*/
foreach i of global outcomes {
* Open Stata dataset

use "$Tempdir/analysis_dataset_STSET_`i'_eth16_mi.dta", clear

/* Multivariable models */ 

if "`1'"=="demog"{
*Age and gender
mi estimate, dots eform: stcox i.eth16 i.male age1 age2 age3, strata(stp) nolog
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model0_`i'_eth16", replace) idstr("model0_`i'_eth16")
local hr "`hr' "$Tempdir/model0_`i'_eth16" "
estimates save "./output/an_imputed_demog_eth16", replace						
}


if "`1'"=="full"{
						
* Age, Gender, IMD and Comorbidities  and household size and carehome
  mi estimate, dots eform: stcox i.eth16 i.male age1 age2 age3 	i.imd						///
										bmi	hba1c_pct				///
										gp_consult_count			///
										i.smoke_nomiss				///
										i.hypertension bp_map		 	///	
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
										i.ra_sle_psoriasis			///
										i.hh_total_cat i.carehome, strata(stp) nolog		
	
parmest, label eform format(estimate p lb ub) saving("$Tempdir/model3_`i'_eth16", replace) idstr("model3_`i'_eth16") 
local hr "`hr' "$Tempdir/model3_`i'_eth16" "
estimates save "./output/an_imputed_full_eth16", replace						
}

} //end outcomes

************************************************create forestplot dataset
dsconcat `hr'
duplicates drop
split idstr, p(_)
ren idstr1 model
ren idstr2 outcome
drop idstr idstr3 idstr4
tab model

gen eth16=1 if regexm(parm, "1b")
forvalues i=2/14 {
	replace eth16=`i' if regexm(parm, "`i'.eth16")
}

drop parm  stderr dof t 
order outcome model eth16 

destring eth16, replace
label define eth16 	///
						1 "British" ///
						2 "Irish" ///
						3 "Other White" ///
						4 "Indian" ///
						5 "Pakistani" ///
						6 "Bangladeshi" ///	
						7 "Other Asian" ///
						8 "Caribbean" ///
						9 "African" ///
						10 "Other Black" ///
						11 "Chinese" ///
						12 "All mixed" ///
						13  "Other" ///
						14 "Unknown"
label values eth16 eth16

gen num=[_n]
sum num

gen adjusted="Crude" if model=="crude"
replace adjusted="Age-sex" if model=="model0"
replace adjusted="+ IMD" if model=="model1"
replace adjusted="+ co-morbidities" if model=="model2"
replace adjusted="+ household size & carehome" if model=="model3"

*save dataset for later
outsheet using "$Tabfigdir/FP_mi_eth16.txt", replace

* Close log file 
log close
insheet using "$Tabfigdir/FP_mi_eth16.txt", clear


