********************************************************************************
*****************Code for converting csv files to dta files*********************
********************************************************************************

clear all

global CSV_FOLDER = "GENERAL PATH\files_for_stata"
global STATA_FOLDER = "GENERAL PATH\DTA_Files"


foreach val in "25km" "20km" "15km"{
	clear all
	cd $CSV_FOLDER
	import delimited `val'.csv
	cd $STATA_FOLDER
	save `val'
	
	
}
