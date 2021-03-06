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
global outcomes "tested positivetest icu hes onscoviddeath ons_noncoviddeath onsdeath onsconfirmeddeath" 
global alloutcomes "tested positivetest icu hes onscoviddeath ons_noncoviddeath onsdeath" 


/**********************
Data cleaning
**********************/

*Create analysis dataset
do "$Dodir/01_eth_cr_analysis_dataset.do"

*Table 0: Numbers of outcomes in study population
*do "$Dodir/03a_eth_outcomes_checks_eth16.do"
*do "$Dodir/03b_eth_outcomes_checks_eth5.do"


/*Table 1 baseline characteristics - stratified by carehome status
do "$Dodir/05a_eth_table1_descriptives_eth16_nocarehomes.do"
do "$Dodir/05b_eth_table1_descriptives_eth5_nocarehomes.do"
do "$Dodir/05b_eth_table1_descriptives_eth5_carehomesonly.do"
*/

/**********************
NO CARE HOMES
**********************/

*Table 2: multivariable analysis - complete case 
*do "$Dodir/06a_eth_an_multivariable_eth16_nocarehomes.do" 
*do "$Dodir/06b_eth_an_multivariable_eth5_nocarehomes.do" 

*Table 4: Odds of testing positive amongst those with SGSS testing data
*do "$Dodir/11a_eth_an_testedpop_eth16_nocarehomes" 
*do "$Dodir/11b_eth_an_testedpop_eth5_nocarehomes" 

*Sensitivity analysis - models without adjustment for region
do "$Dodir/07b_eth_sensanalysis_nostp_eth5.do" 

*Sensitivity analysis - proportional hazards assumptions checks
do "$Dodir/20_eth_an_model_checks.do"

/**********************
CARE HOMES ONLY
**********************/
*Table 2: multivariable analysis - complete case 
do "$Dodir/06b_eth_an_multivariable_eth5_carehomesonly.do" 

/**********************
MULTIPLE IMPUTATION
**********************/
/*
*Table 2: multiple imputation
do "$Dodir/08b_eth_cr_imputed_eth5.do"
do "$Dodir/08c_eth_an_multivariable_eth5_mi.do"
*/

*sensitivity analysis no STP, eth16
do "$Dodir/07a_eth_sensanalysis_nostp_eth16.do" 
*Sensitivity analysis - urban vs. rural
do "$Dodir/07c_eth_sensanalysis_ruralurban_eth16.do"

