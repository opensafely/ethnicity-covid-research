from cohortextractor import (
    codelist,
    codelist_from_csv,
)

covid_codelist = codelist(["U071", "U072"], system="icd10")

confirmed_covid_codelist = codelist(["U071"], system="icd10")

suspected_covid_codelist = codelist(["U072"], system="icd10")

covid_primary_care_positive_test=codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-positive-test.csv",
    system="ctv3", 
    column="CTV3ID",
)

covid_primary_care_code=codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-clinical-code.csv",
    system="ctv3", 
    column="CTV3ID",
)

covid_primary_care_sequalae=codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-sequelae.csv",
    system="ctv3",
    column="CTV3ID",
)

covid_primary_care_exposure = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-exposure-to-disease.csv", 
    system="ctv3", 
    column="CTV3ID",
)

covid_primary_care_historic_case = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-historic-case.csv", 
    system="ctv3", 
    column="CTV3ID",
)

covid_primary_care_potential_historic_case = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-potential-historic-case.csv", 
    system="ctv3", 
    column="CTV3ID",
)

covid_suspected_code = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-suspected-covid-suspected-codes.csv", 
    system="ctv3", 
    column="CTV3ID",
)

covid_suspected_111 = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-helper-111-suspected.csv",
    system="ctv3",
    column="CTV3ID",
)

covid_suspected_advice = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-suspected-covid-advice.csv",
    system="ctv3",
    column="CTV3ID",
)

covid_suspected_test = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-suspected-covid-had-test.csv",  
    system="ctv3",
    column="CTV3ID",
)


aplastic_codes = codelist_from_csv(
    "codelists/opensafely-aplastic-anaemia.csv", system="ctv3", column="CTV3ID"
)

hiv_codes = codelist_from_csv(
    "codelists/opensafely-hiv.csv", system="ctv3", column="CTV3ID"
)

permanent_immune_codes = codelist_from_csv(
    "codelists/opensafely-permanent-immunosuppression.csv",
    system="ctv3",
    column="CTV3ID",
)

temp_immune_codes = codelist_from_csv(
    "codelists/opensafely-temporary-immunosuppression.csv",
    system="ctv3",
    column="CTV3ID",
)

stroke = codelist_from_csv(
    "codelists/opensafely-stroke-updated.csv", system="ctv3", column="CTV3ID"
)

dementia = codelist_from_csv(
    "codelists/opensafely-dementia.csv", system="ctv3", column="CTV3ID"
)

other_neuro = codelist_from_csv(
    "codelists/opensafely-other-neurological-conditions.csv",
    system="ctv3",
    column="CTV3ID",
)
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)
ethnicity_codes_16 = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_16",
)

chronic_respiratory_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-respiratory-disease.csv",
    system="ctv3",
    column="CTV3ID",
)

asthma_codes = codelist_from_csv(
    "codelists/opensafely-current-asthma.csv", system="ctv3", column="CTV3ID"
)

salbutamol_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-salbutamol-medication.csv",
    system="snomed",
    column="id",
)

ics_codes = codelist_from_csv(
    "codelists/opensafely-asthma-inhaler-steroid-medication.csv",
    system="snomed",
    column="id",
)

pred_codes = codelist_from_csv(
    "codelists/opensafely-asthma-oral-prednisolone-medication.csv",
    system="snomed",
    column="snomed_id",
)

chronic_cardiac_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease.csv", system="ctv3", column="CTV3ID"
)


diabetes_t1_codes = codelist_from_csv(
    "codelists/opensafely-type-1-diabetes.csv", system="ctv3", column="CTV3ID"
)

diabetes_t2_codes = codelist_from_csv(
    "codelists/opensafely-type-2-diabetes.csv", system="ctv3", column="CTV3ID"
)

diabetes_unknown_codes = codelist_from_csv(
    "codelists/opensafely-diabetes-unknown-type.csv", system="ctv3", column="CTV3ID"
)

diabetes_t1t2_codes_exeter = codelist_from_csv(
        "codelists/opensafely-diabetes-exeter-group.csv", 
        system="ctv3", 
        column="CTV3ID",
        category_column="Category",
)

clear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-clear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)

unclear_smoking_codes = codelist_from_csv(
    "codelists/opensafely-smoking-unclear.csv",
    system="ctv3",
    column="CTV3Code",
    category_column="Category",
)
lung_cancer_codes = codelist_from_csv(
    "codelists/opensafely-lung-cancer.csv", system="ctv3", column="CTV3ID"
)

haem_cancer_codes = codelist_from_csv(
    "codelists/opensafely-haematological-cancer.csv", system="ctv3", column="CTV3ID"
)

other_cancer_codes = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological.csv",
    system="ctv3",
    column="CTV3ID",
)

chronic_liver_disease_codes = codelist_from_csv(
    "codelists/opensafely-chronic-liver-disease.csv", system="ctv3", column="CTV3ID"
)
gi_bleed_and_ulcer_codes = codelist_from_csv(
    "codelists/opensafely-gi-bleed-or-ulcer.csv", system="ctv3", column="CTV3ID"
)
inflammatory_bowel_disease_codes = codelist_from_csv(
    "codelists/opensafely-inflammatory-bowel-disease.csv",
    system="ctv3",
    column="CTV3ID",
)

creatinine_codes = codelist(["XE2q5"], system="ctv3")

hba1c_new_codes = codelist(["XaPbt", "Xaeze", "Xaezd"], system="ctv3")
hba1c_old_codes = codelist(["X772q", "XaERo", "XaERp"], system="ctv3")


dialysis_codes = codelist_from_csv(
    "codelists/opensafely-chronic-kidney-disease.csv", system="ctv3", column="CTV3ID"
)

organ_transplant_codes = codelist_from_csv(
    "codelists/opensafely-solid-organ-transplantation.csv",
    system="ctv3",
    column="CTV3ID",
)

spleen_codes = codelist_from_csv(
    "codelists/opensafely-asplenia.csv", system="ctv3", column="CTV3ID"
)

sickle_cell_codes = codelist_from_csv(
    "codelists/opensafely-sickle-cell-disease.csv", system="ctv3", column="CTV3ID"
)

ra_sle_psoriasis_codes = codelist_from_csv(
    "codelists/opensafely-ra-sle-psoriasis.csv", system="ctv3", column="CTV3ID"
)

systolic_blood_pressure_codes = codelist(["2469."], system="ctv3")
diastolic_blood_pressure_codes = codelist(["246A."], system="ctv3")

hypertension_codes = codelist_from_csv(
    "codelists/opensafely-hypertension.csv", system="ctv3", column="CTV3ID"
)

# MEDICATION CODELISTS
ace_codes = codelist_from_csv(
    "codelists/opensafely-ace-inhibitor-medications.csv",
    system="snomed",
    column="id",
)

alpha_blocker_codes = codelist_from_csv(
    "codelists/opensafely-alpha-adrenoceptor-blocking-drugs.csv",
    system="snomed",
    column="id",
)

arb_codes = codelist_from_csv(
    "codelists/opensafely-angiotensin-ii-receptor-blockers-arbs.csv",
    system="snomed",
    column="id",
)

betablocker_codes = codelist_from_csv(
    "codelists/opensafely-beta-blocker-medications.csv",
    system="snomed",
    column="id",
)

calcium_channel_blockers_codes = codelist_from_csv(
    "codelists/opensafely-calcium-channel-blockers.csv",
    system="snomed",
    column="id",
)

combination_bp_med_codes = codelist_from_csv(
    "codelists/opensafely-combination-blood-pressure-medication.csv",
    system="snomed",
    column="id",
)

spironolactone_codes = codelist_from_csv(
    "codelists/opensafely-spironolactone.csv",
    system="snomed",
    column="id",
)

thiazide_type_diuretic_codes = codelist_from_csv(
    "codelists/opensafely-thiazide-type-diuretic-medication.csv",
    system="snomed",
    column="id",
)

insulin_med_codes = codelist_from_csv(
    "codelists/opensafely-insulin-medication.csv", 
    system="snomed", 
    column="id"
)

statin_med_codes = codelist_from_csv(
    "codelists/opensafely-statin-medication.csv", 
    system="snomed", 
    column="id"
)

oad_med_codes = codelist_from_csv(
    "codelists/opensafely-antidiabetic-drugs.csv",
    system="snomed",
    column="id"
)