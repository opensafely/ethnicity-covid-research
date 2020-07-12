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



***********************HOUSE-KEEPING*******************************************
* Create directories required 

capture mkdir "$Outdir/log"
capture mkdir "$Outdir/tempdata"
capture mkdir "$Outdir/tabfig"

* Set globals that will print in programs and direct output
global outdir  	  "$Outdir" 
global logdir     "$Logdir"
global tempdir    "$Tempdir"




*  Pre-analysis data manipulation  
do "$Dodir/01_eth_cr_analysis_dataset.do"
  
*  Checks 
do "$Dodir/02_eth_an_data_checks.do"


*  Descriptives
do "$Dodir/03_eth_an_descriptive_tables.do"
*do "$Dodir/04_eth_ an_descriptive_plots.do"
