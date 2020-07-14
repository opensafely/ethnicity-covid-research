import delimited `c(pwd)'/output/input.csv, clear

numlabel, add

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

adopath + "./extra_ados"

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

*suspected confirmed ae

*ventilation is yes/no so outcome will be odds not risk

*  Pre-analysis data manipulation  
do "$Dodir/01_eth_cr_analysis_dataset.do"
*  Checks 
do "$Dodir/02_eth_an_data_checks.do"


*  Descriptives
do "$Dodir/03_eth_an_descriptive_tables.do"
do "$Dodir/04_eth_an_descriptive_plots.do"
*do "$Dodir/05_eth_an_descriptive_tables.do"
