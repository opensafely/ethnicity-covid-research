/*==============================================================================
DO FILE NAME:			00_eth_flowchart
PROJECT:				Ethnciity and COVID-19 
DATE: 					13 September 2020 
AUTHOR:					R  Mathur based  on C Rentsch
DESCRIPTION OF FILE:	generate numbers for flow diagram 
DATASETS USED:			separate study definition input ($Outdir/input_flow_chart.csv)

DATASETS CREATED: 		none
OTHER OUTPUT: 			logfiles, printed to folder $Logdir
USER-INSTALLED ADO: 	 
  (place .ado file(s) in analysis folder)								
==============================================================================*/

* Open a log file

cap log close
log using $Logdir\00_eth_flowchart, replace t

cd  "$Dodir"
cd ..
import delimited `c(pwd)'/output/input_flow_chart.csv, clear

/*
has_follow_up AND
(age >=18 AND age <= 110) AND
(sex = "M" OR sex = "F") AND
imd > 0 AND
(rheumatoid OR sle) AND NOT
chloroquine_not_hcq
*/

*assess variables
*codebook has_follow_up age sex imd rheumatoid sle chloroquine_not_hcq ethnicity
count
drop if has_follow_up!=1
count
drop if age < 18 
count
drop if age > 110
count
drop if sex != "M" & sex != "F"
count




log close
