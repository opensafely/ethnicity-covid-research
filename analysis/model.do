import delimited `c(pwd)'/output/input.csv, clear

*set filepaths
global Projectdir `c(pwd)'
global Dodir "$Projectdir/analysis" 
di "$Dodir"
global Outdir "$Projectdir/output" 
di "$Outdir"
global Logdir "$Outdir/log"
di "$Logdir"
global Tempdir "$Outdir/tempdata" 
di "$Tempdir"
global Tabfigdir "$Outdir/tabfig" 
di "$Tabfigdir"

cd  "`c(pwd)'/analysis"

adopath + "$Dodir/adofiles"
sysdir
sysdir set PLUS "$Dodir/adofiles"

cd  "$Projectdir"

***********************HOUSE-KEEPING*******************************************
* Create directories required 

capture mkdir "$Outdir/log"
capture mkdir "$Outdir/tempdata"
capture mkdir "$Outdir/tabfig"

* Set globals that will print in programs and direct output
global outdir  	  "$Outdir" 
global logdir     "$Logdir"
global tempdir    "$Tempdir"


* Set globals for  outcomes
global outcomes "tested positivetest icu onscoviddeath ons_noncoviddeath onsdeath"


/**********************
Data cleaning
**********************/

*Create analysis dataset
do "$Dodir/01_eth_cr_analysis_dataset.do"

*Table 0: Numbers of outcomes in study population
do "$Dodir/03a_eth_outcomes_checks_eth16.do"
do "$Dodir/03b_eth_outcomes_checks_eth5.do"

/**********************
ETH 5
**********************/

*Table 1 baseline characteristics
do "$Dodir/05b_eth_table1_descriptives_eth5.do"

*Table 2: multivariable analysis - complete case 
do "$Dodir/06b_eth_an_multivariable_eth5.do" 
do "$Dodir/06b_eth_an_multivariable_eth5_nocarehomes.do" 
do "$Dodir/06b_eth_an_multivariable_eth5_carehomesonly.do" 

*Table 4: Odds of testing positive amongst those with SGSS testing data
do "$Dodir/11b_eth_an_testedpop_eth5" 
do "$Dodir/11b_eth_an_testedpop_eth5_nocarehomes" 
do "$Dodir/11b_eth_an_testedpop_eth5_carehomesonly" 


/**********************
ETH 16
**********************/
*Table 1 baseline characteristics
do "$Dodir/05a_eth_table1_descriptives_eth16.do"

*Table 2: multivariable analysis - complete case 
do "$Dodir/06a_eth_an_multivariable_eth16.do" 
do "$Dodir/06a_eth_an_multivariable_eth16_nocarehomes.do" 
do "$Dodir/06a_eth_an_multivariable_eth16_carehomesonly.do" 

*Table 4: Odds of testing positive amongst those with SGSS testing data
do "$Dodir/11a_eth_an_testedpop_eth16" 
do "$Dodir/11a_eth_an_testedpop_eth16_nocarehomes" 
do "$Dodir/11a_eth_an_testedpop_eth16_carehomesonly" 


/**********************
MULTIPLE IMPUTATION
**********************/
*Table 2: multiple imputation
do "$Dodir/08b_eth_cr_imputed_eth5.do"
do "$Dodir/08c_eth_an_multivariable_eth5_mi.do" 

*do "$Dodir/08a_eth_cr_imputed_eth16.do"
*do "$Dodir/08d_eth_an_multivariable_eth16_mi.do" 

*Checks 
do "$Dodir/02_eth_an_data_checks.do"


*Table 5: Characteristics of people with and without key outcomes
do "$Dodir/16_eth_an_outcome_characteristics.do"

*Table 1 baseline characteristics - stratified by carehome status
do "$Dodir/05b_eth_table1_descriptives_eth5_nocarehomes.do"
do "$Dodir/05b_eth_table1_descriptives_eth5_carehomesonly.do"
do "$Dodir/05b_eth_table1_descriptives_eth16_nocarehomes.do"
do "$Dodir/05b_eth_table1_descriptives_eth16_carehomesonly.do"

