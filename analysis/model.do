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

adopath + "$Dodir"
sysdir
sysdir set PLUS "$Dodir"

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
global outcomes "tested positivetest icu cpnsdeath onsdeath onscoviddeath ons_noncoviddeath"

*Create analysis dataset
do "$Dodir/01_eth_cr_analysis_dataset.do"

*Checks 
do "$Dodir/02_eth_an_data_checks.do"

*  Descriptives
do "$Dodir/03_eth_an_descriptive_tables.do"
do "$Dodir/04_eth_an_descriptive_plots.do"
do "$Dodir/05a_eth_table1_descriptives_eth16.do"
do "$Dodir/05b_eth_table1_descriptives_eth5.do"

*rates - crude, age, and age-sex stratified

*multivariable analysis - complete case 
do "$Dodir/06a_eth_an_multivariable_eth16.do" 
do "$Dodir/06b_eth_an_multivariable_eth5.do"

*Forest plots for complete case analysis
do "$Dodir/07a_eth_cr_forestplots_eth16.do" 
do "$Dodir/07b_eth_cr_forestplots_eth5.do" 

*ventilation - in those admitted to ICU
do "$Dodir/09a_eth_an_ventilation_eth16"
do "$Dodir/09b_eth_an_ventilation_eth5"

/*multivariable analysis - imputed ethnicity
do "$Dodir/08a_eth_an_multivariable_eth16_mi.do"
do "$Dodir/08b_eth_an_multivariable_eth5_mi.do"

*multivariable analysis - in those with infection


*in those with infection (admitted to ICU)


*Household exploration


*Exploratory analyses

*Diabetes

*Hypertension
