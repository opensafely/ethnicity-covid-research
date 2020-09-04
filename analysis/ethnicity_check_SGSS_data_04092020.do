

import delimited `c(pwd)'/output/input.csv, clear
							
di "STARTING safecount FROM IMPORT:"
safecount


summ first_tested_for_covid
summ first_positive_test_date


gen tested=0
replace tested=1 if first_tested_for_covid!=.

gen positivetest=0
replace positivetest=1 if if first_positive_test_date!=.

**COUNTS IN RAW DATA

safetab tested
safetab positivetest
safetab tested positivetest


**COUNTS IN ETHNICITY STUDY POPULATION
drop if age<18
drop if age>105
drop if inlist(sex, "I", "U")


safetab tested
safetab positivetest
safetab tested positivetest
