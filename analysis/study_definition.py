from cohortextractor import (
    StudyDefinition,
    patients,
    codelist_from_csv,
    codelist,
    filter_codes_by_category,
    combine_codelists
)


## CODE LISTS
# All codelist are held within the codelist/ folder and this imports them from
# codelists.py file which imports from that folder

from codelists import *

## STUDY POPULATION
# Defines both the study population and points to the important covariates

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1970-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.2,
    },

    # STUDY POPULATION
    population=patients.registered_with_one_practice_between(
        "2019-02-01", "2020-02-01"
    ),

    # OUTCOMES,
    primary_care_case=patients.with_these_clinical_events(
        covid_primary_care_case,
        returning="date",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest" : "2020-02-01",
                                      "latest": "2020-08-24"},
                             "rate" : "exponential_increase"},
    ),
    primary_care_historic_case=patients.with_these_clinical_events(
        covid_primary_care_historic_case,
        returning="date",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest" : "2020-02-01",
                                      "latest": "2020-08-24"},
                             "rate" : "exponential_increase"},
    ),

    primary_care_potential_historic_case=patients.with_these_clinical_events(
        covid_primary_care_potential_historic_case,
        returning="date",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest" : "2020-02-01",
                                      "latest": "2020-08-24"},
                             "rate" : "exponential_increase"},
    ),
    primary_care_exposure=patients.with_these_clinical_events(
        covid_primary_exposure,
        returning="date",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest" : "2020-02-01",
                                      "latest": "2020-08-24"},
                             "rate" : "exponential_increase"},
    ),
    primary_care_suspect_case=patients.with_these_clinical_events(
        covid_primary_care_suspect_case,
        returning="date",
        find_first_match_in_period=True,
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest" : "2020-02-01",
                                      "latest": "2020-08-24"},
                             "rate" : "exponential_increase"},
    ),

    ### A&E attendence
    a_e_consult_date=patients.attended_emergency_care(
        on_or_after="2020-02-01",
        returning="date_arrived",
        date_format="YYYY-MM-DD",
        find_first_match_in_period=True,
        return_expectations={"date": {"earliest": "2020-02-01",
                                      "latest": "2020-08-24"},
                             "rate": "exponential_increase"},

    # ICU attendance and ventilation
    # icu_date_ventilated=patients.ventilated_in_icu(
    # on_or_after="2020-02-01",
    # returning="icu_date_ventilated"
    # ),

    icu_date_admitted=patients.admitted_to_icu(
        on_or_after="2020-02-01",
        include_day=True,
        returning="date_admitted",
        find_first_match_in_period=True,
    ),

    # cpns
    died_date_cpns=patients.with_death_recorded_in_cpns(
        on_or_before="2020-06-01",
        returning="date_of_death",
        include_month=True,
        include_day=True,
    ),

    # ons
    died_ons_covid_flag_any=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        on_or_before="2020-06-01",
        match_only_underlying_cause=False,
        return_expectations={"date": {"earliest": "2020-02-01"}},
    ),
    died_ons_covid_flag_underlying=patients.with_these_codes_on_death_certificate(
        covid_codelist,
        on_or_before="2020-06-01",
        match_only_underlying_cause=True,
        return_expectations={"date": {"earliest": "2020-02-01"}},
    ),
    died_date_ons=patients.died_from_any_cause(
        on_or_before="2020-08-01",
        returning="date_of_death",
        include_month=True,
        include_day=True,
    ),
    first_tested_for_covid=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="any",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-02-01"}},
    ),
    first_positive_test_date=patients.with_test_result_in_sgss(
        pathogen="SARS-CoV-2",
        test_result="positive",
        find_first_match_in_period=True,
        returning="date",
        date_format="YYYY-MM-DD",
        return_expectations={"date": {"earliest": "2020-02-01"}},
    ),

    ## DEMOGRAPHIC COVARIATES
    # AGE
    age=patients.age_as_of(
        "2020-02-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),

    # SEX
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        }
    ),

    # DEPRIVIATION
    imd=patients.address_as_of(
        "2020-02-01",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),

    # RURAL OR URBAN LOCATION
    rural_urban=patients.address_as_of(
        "2020-02-01",
        returning="rural_urban_classification",
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"rural": 0.1, "urban": 0.9}},
        },
    ),

    # GEOGRAPHIC REGION CALLED STP
    stp=patients.registered_practice_as_of(
        "2020-02-01",
        returning="stp_code",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "STP1": 0.1,
                    "STP2": 0.1,
                    "STP3": 0.1,
                    "STP4": 0.1,
                    "STP5": 0.1,
                    "STP6": 0.1,
                    "STP7": 0.1,
                    "STP8": 0.1,
                    "STP9": 0.1,
                    "STP10": 0.1,
                }
            },
        },
    ),

    # OTHER REGION
    region=patients.registered_practice_as_of(
        "2020-02-01",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "North East": 0.1,
                    "North West": 0.1,
                    "Yorkshire and the Humber": 0.1,
                    "East Midlands": 0.1,
                    "West Midlands": 0.1,
                    "East of England": 0.1,
                    "London": 0.2,
                    "South East": 0.2,
                },
            },
        },
    ),

    # ETHNICITY IN 16 CATEGORIES
    ethnicity_16=patients.with_these_clinical_events(
        ethnicity_codes_16,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
        return_expectations={
            "category": {
                "ratios": {
                    "1": 0.5,
                    "2": 0.1,
                    "3": 0.05,
                    "4": 0.05,
                    "5": 0.05,
                    "6": 0.05,
                    "7": 0.05,
                    "8": 0.05,
                    "9": 0.02,
                    "10": 0.02,
                    "11": 0.01,
                    "12": 0.01,
                    "13": 0.01,
                    "14": 0.01,
                    "15": 0.01,
                    "16": 0.01,
                }
            },
            "incidence": 0.75,
        },
    ),

   
    # ETHNICITY IN 6 CATEGORIES
    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
        return_expectations={
            "category": {"ratios": {"1": 0.8, "5": 0.1, "3": 0.1}},
            "incidence": 0.75,
        },
    ),

    ## HOUSEHOLD INFORMATION
    # CAREHOME STATUS
    care_home_type=patients.care_home_status_as_of(
        "2020-02-01",
        categorised_as={
            "PC": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='Y'
              AND LocationRequiresNursing='N'
            """,
            "PN": """
              IsPotentialCareHome
              AND LocationDoesNotRequireNursing='N'
              AND LocationRequiresNursing='Y'
            """,
            "PS": "IsPotentialCareHome",
            "U": "DEFAULT",
        },
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"PC": 0.05, "PN": 0.05, "PS": 0.05, "U": 0.85,},},
        },
    ),

    hh_id=patients.household_as_of(
        "2020-02-01",
        returning="pseudo_id",
        return_expectations={
            "int": {"distribution": "normal", "mean": 1000, "stddev": 200},
            "incidence": 1,
        },
    ),

    hh_size=patients.household_as_of(
        "2020-02-01",
        returning="household_size",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 1},
            "incidence": 1,
        },
    ),

    ### GP CONSULTATION RATE IN 12 MONTH BEFORE FEB 1 2020
    gp_consult_count=patients.with_gp_consultations(
        between=["2019-02-01", "2020-01-31"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 4, "stddev": 2},
            "date": {"earliest": "2019-03-01", "latest": "2020-02-29"},
            "incidence": 0.7,
        },
    ),
    has_consultation_history=patients.with_complete_gp_consultation_history_between(
        "2019-02-01", "2020-01-31", return_expectations={"incidence": 0.9},
    ),



    # CONTINUOUS MEASURED COVARIATES
    bmi=patients.most_recent_bmi(
        on_or_after="2010-02-01",
        minimum_age_at_measurement=16,
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "date": {},
            "float": {"distribution": "normal", "mean": 35, "stddev": 10},
            "incidence": 0.95,
        },
    ),

    # Blood pressure
    bp_sys=patients.mean_recorded_value(
        systolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="2020-02-01",
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 80, "stddev": 10},
            "date": {"latest": "2020-02-29"},
            "incidence": 0.95,
        },
    ),

    bp_dias=patients.mean_recorded_value(
        diastolic_blood_pressure_codes,
        on_most_recent_day_of_measurement=True,
        on_or_before="2020-02-01",
        include_measurement_date=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 120, "stddev": 10},
            "date": {"latest": "2020-02-29"},
            "incidence": 0.95,
        },
    ),

    ## HBA1C
    hba1c_mmol_per_mol=patients.with_these_clinical_events(
        hba1c_new_codes,
        find_last_match_in_period=True,
        on_or_before="2020-02-01",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"latest": "2020-02-29"},
            "float": {"distribution": "normal", "mean": 40.0, "stddev": 20},
            "incidence": 0.95,
        },
    ),

    hba1c_percentage=patients.with_these_clinical_events(
        hba1c_old_codes,
        find_last_match_in_period=True,
        on_or_before="2020-02-01",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "date": {"latest": "2020-02-29"},
            "float": {"distribution": "normal", "mean": 5, "stddev": 2},
            "incidence": 0.95,
        },
    ),

    # # Creatinine
    creatinine=patients.with_these_clinical_events(
        creatinine_codes,
        find_last_match_in_period=True,
        on_or_before="2020-02-01",
        returning="numeric_value",
        include_date_of_match=True,
        include_month=True,
        return_expectations={
            "float": {"distribution": "normal", "mean": 60.0, "stddev": 15},
            "date": {"earliest": "2019-02-28", "latest": "2020-02-29"},
            "incidence": 0.95,
        },
    ),

    # COVARIATES
    smoking_status=patients.categorised_as(
        {
            "S": "most_recent_smoking_code = 'S'",
            "E": """
                 most_recent_smoking_code = 'E' OR (
                   most_recent_smoking_code = 'N' AND ever_smoked
                 )
            """,
            "N": "most_recent_smoking_code = 'N' AND NOT ever_smoked",
            "M": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"S": 0.6, "E": 0.1, "N": 0.2, "M": 0.1}}
        },
        most_recent_smoking_code=patients.with_these_clinical_events(
            clear_smoking_codes,
            find_last_match_in_period=True,
            on_or_before="2020-02-01",
            returning="category",
        ),
        ever_smoked=patients.with_these_clinical_events(
            filter_codes_by_category(clear_smoking_codes, include=["S", "E"]),
            on_or_before="2020-02-01",
        ),
    ),
    smoking_status_date=patients.with_these_clinical_events(
        clear_smoking_codes,
        on_or_before="2020-02-01",
        return_last_date_in_period=True,
        include_month=True,
    ),


    chronic_respiratory_disease=patients.with_these_clinical_events(
        chronic_respiratory_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),

    asthma=patients.with_these_clinical_events(
        current_asthma_codes,
        on_or_before="2020-02-29",
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),

    chronic_cardiac_disease=patients.with_these_clinical_events(
        chronic_cardiac_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),

    diabetes=patients.categorised_as(
        {
            "T1DM":
                """
                        (type1_diabetes AND NOT
                        type2_diabetes) 
                    OR
                        (((type1_diabetes AND type2_diabetes) OR 
                        (type1_diabetes AND unknown_diabetes) OR
                        (unknown_diabetes AND NOT type1_diabetes AND NOT type2_diabetes))
                        AND 
                        (insulin_lastyear_meds > 0 AND NOT
                        oad_lastyear_meds > 0))
                """,
            "T2DM":
                """
                        (type2_diabetes AND NOT
                        type1_diabetes)
                    OR
                        (((type1_diabetes AND type2_diabetes) OR 
                        (type2_diabetes AND unknown_diabetes) OR
                        (unknown_diabetes AND NOT type1_diabetes AND NOT type2_diabetes))
                        AND 
                        (oad_lastyear_meds > 0 AND NOT
                        insulin_lastyear_meds > 0))
                """,
            "UNKNOWN_DM":
                """
                        ((unknown_diabetes AND NOT type1_diabetes AND NOT type2_diabetes) AND NOT
                        oad_lastyear_meds AND NOT
                        insulin_lastyear_meds) 
                    OR
                        (unknown_diabetes AND NOT type1_diabetes AND NOT type2_diabetes) AND 
                        oad_lastyear_meds AND 
                        insulin_lastyear_meds
                """,
            "NO_DM": "DEFAULT",
        },

        return_expectations={
            "category": {"ratios": {"T1DM": 0.03, "T2DM": 0.2, "UNKNOWN_DM": 0.02, "NO_DM": 0.75}},
            "rate" : "universal"

        },

        type1_diabetes=patients.with_these_clinical_events(
            diabetes_t1_codes,
            on_or_before="2020-02-01",
            return_first_date_in_period=True,
            include_month=True,
        ),
        type2_diabetes=patients.with_these_clinical_events(
            diabetes_t2_codes,
            on_or_before="2020-02-01",
            return_first_date_in_period=True,
            include_month=True,
        ),
        unknown_diabetes=patients.with_these_clinical_events(
            diabetes_unknown_codes,
            on_or_before="2020-02-01",
            return_first_date_in_period=True,
            include_month=True,
        ),
        oad_lastyear_meds=patients.with_these_medications(
            ace_codes, ### THIS IS A PLACEHOLDER
            between=["2019-02-01", "2020-02-01"],
            returning="number_of_matches_in_period",
        ),
        insulin_lastyear_meds=patients.with_these_medications(
            insulin_med_codes,
            between=["2019-02-01", "2020-02-01"],
            returning="number_of_matches_in_period",
        ),
    ),

#EXETER ALGORITHM USING OPENSAFELY CODELISTS
    diabetes_exeter_os=patients.categorised_as(
        {
            "T1DM_EX_OS":
                """
                        ((insulin_last6mo >= 2) AND ((t1dm_count / t2dm_count) >= 2))
                """,
            "T2DM_EX_OS":
                """
                        (insulin_last6mo < 2) AND ((t2dm_count>0))
                        OR
                        ((insulin_last6mo >= 2) AND ((t1dm_count / t2dm_count) < 2)) AND ((t2dm_count>0))
                """,
            "NO_DM": "DEFAULT",
        },

        return_expectations={
            "category": {"ratios": {"T1_DM": 0.03, "T2_DM": 0.2, "NO_DM": 0.77}},
            "rate" : "universal"

        },

        t1dm_count=patients.with_these_clinical_events(
            diabetes_t1_codes,
            on_or_before="2020-02-01",
            returning="number_of_matches_in_period",
        ),

        t2dm_count=patients.with_these_clinical_events(
            diabetes_t2_codes,
            on_or_before="2020-02-01",
            returning="number_of_matches_in_period",
        ),
            
        insulin_last6mo=patients.with_these_medications(
            insulin_med_codes,
            between=["2019-09-01", "2020-02-01"],
            returning="number_of_matches_in_period",
        ),
    ),

#EXETER ALGORITHM USING EXETER CODELISTS
#    diabetes_exeter=patients.categorised_as(
#        {
#            "T1DM_EX":
#                """
#                        ((insulin_last6mo >= 2) AND ((t1dm_count / t2dm_count) >= 2))
#                """,
#            "T2DM_EX":
#                """
#                        (insulin_last6mo < 2) AND ((t2dm_count>0))
#                        OR
#                        ((insulin_last6mo >= 2) AND ((t1dm_count / t2dm_count) < 2)) AND ((t2dm_count>0))
#                """,
#            "NO_DM": "DEFAULT",
#        },
#
#        return_expectations={
#            "category": {"ratios": {"T1_DM": 0.02, "T2_DM": 0.4, "NO_DM": 0.78}},
#            "rate" : "universal"
#
#        },
#
#        t1dm_count=patients.categorised_as(
#            "T1DM_EX": "diabetes_t1t2_codes_exeter = '1'",
#            on_or_before="2020-02-01",
#            returning="number_of_matches_in_period",
#        ),
#
#        t2dm_count=patients.patients.categorised_as(
#            "T2DM_EX": "diabetes_t1t2_codes_exeter = '2'",
#            on_or_before="2020-02-01",
#            returning="number_of_matches_in_period",
#        ),
#            
#        insulin_last6mo=patients.with_these_medications(
#            insulin_med_codes,
#            between=["2019-09-01", "2020-02-01"],
#            returning="number_of_matches_in_period",
#        ),
#    ),


    # CANCER - 3 TYPES
    cancer=patients.with_these_clinical_events(
        combine_codelists(lung_cancer_codes,
                          haem_cancer_codes,
                          other_cancer_codes),
        return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),

    #### PERMANENT
    permanent_immunodeficiency=patients.with_these_clinical_events(
        combine_codelists(hiv_codes,
                          permanent_immune_codes,
                          sickle_cell_codes,
                          organ_transplant_codes,
                          spleen_codes)
        ,
        on_or_before="2020-02-29",
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),

    ### TEMPROARY IMMUNE
    temporary_immunodeficiency=patients.with_these_clinical_events(
        combine_codelists(aplastic_codes,
                temp_immune_codes),
        between=["2019-03-01", "2020-02-29"], ## THIS IS RESTRICTED TO LAST YEAR
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-03-01", "latest": "2020-02-01"}
        },
    ),

    chronic_liver_disease=patients.with_these_clinical_events(
        chronic_liver_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),

    other_neuro=patients.with_these_clinical_events(
        other_neuro, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),

    stroke=patients.with_these_clinical_events(
        stroke, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),

    dementia=patients.with_these_clinical_events(
        dementia, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),

    # END STAGE RENAL DISEASE - DIALYSIS, TRANSPLANT OR END STAGE RENAL DISEASE
    esrf=patients.with_these_clinical_events(
        dialysis_codes, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),

    # hypertension
    hypertension=patients.with_these_clinical_events(
        hypertension_codes, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),


    ra_sle_psoriasis=patients.with_these_clinical_events(
        ra_sle_psoriasis_codes, return_first_date_in_period=True, include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},

    ),

    gi_bleed_and_ulcer=patients.with_these_clinical_events(
        gi_bleed_and_ulcer_codes, return_first_date_in_period=True, include_month=True,
        return_expectations = {"date": {"latest": "2020-02-01"}},
    ),

    inflammatory_bowel_disease=patients.with_these_clinical_events(
        inflammatory_bowel_disease_codes,
        return_first_date_in_period=True,
        include_month=True,
        return_expectations={"date": {"latest": "2020-02-01"}},
    ),
     # MEDICATION COVARIATES
    ace_inhibitors=patients.with_these_medications(
        ace_codes,
        between=["2019-08-01", "2020-02-01"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    alpha_blockers=patients.with_these_medications(
        alpha_blocker_codes,
        between=["2019-08-01", "2020-02-01"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    arbs=patients.with_these_medications(
        arb_codes,
        between=["2019-08-01", "2020-02-01"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    betablockers=patients.with_these_medications(
        betablocker_codes,
        between=["2019-08-01", "2020-02-01"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    calcium_channel_blockers=patients.with_these_medications(
        calcium_channel_blockers_codes,
        between=["2019-08-01", "2020-02-01"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    combination_bp_meds=patients.with_these_medications(
        combination_bp_med_codes,
        between=["2019-08-01", "2020-02-01"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    spironolactone=patients.with_these_medications(
        spironolactone_codes,
        between=["2019-08-01", "2020-02-01"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),

    thiazide_diuretics=patients.with_these_medications(
        thiazide_type_diuretic_codes,
        between=["2019-08-01", "2020-02-01"],
        returning="number_of_matches_in_period",
        return_expectations={
            "int": {"distribution": "normal", "mean": 3, "stddev": 2},
            "incidence": 0.30,
        },
    ),
    
    ### INSULIN USE
    insulin=patients.with_these_medications(
        insulin_med_codes,
        between=["2019-08-01", "2020-02-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-11-01", "latest": "2020-02-01"}
        },
    ),
    ### STATIN USE
    statin=patients.with_these_medications(
        statin_med_codes,
        between=["2019-08-01", "2020-02-01"],
        return_last_date_in_period=True,
        include_month=True,
        return_expectations={
            "date": {"earliest": "2019-08-01", "latest": "2020-02-01"}
        },
    ),


)
