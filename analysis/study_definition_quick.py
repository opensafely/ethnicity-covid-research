  
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

    dereg_date=patients.date_deregistered_from_all_supported_practices(
        on_or_before="2020-12-01", 
        date_format="YYYY-MM",
        return_expectations={"date": {"earliest": "2020-02-01"}},

    ),

    # OUTCOMES,
    # ICU attendance and ventilation
    was_ventilated_flag=patients.admitted_to_icu(
    on_or_after="2020-02-01",
    returning="was_ventilated",
    return_expectations={
            "rate": "exponential_increase",
            "incidence" : 0.20,
            "date" : {"earliest" : "2020-02-01"},
            "bool" : True,
        }
    ),

    icu_date_admitted=patients.admitted_to_icu(
        on_or_after="2020-02-01",
        include_day=True,
        returning="date_admitted",
        find_first_match_in_period=True,
        return_expectations={"date": {"earliest" : "2020-02-01"},
        "rate" : "exponential_increase"},

    ),

)
