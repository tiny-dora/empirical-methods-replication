*ssc install RANGESTAT
*********Initial Setup**********

clear all
set more off

* Converting the files created for each of the distances in km to define "close"


foreach var in  25km 20km 15km{


cd "C:\DTA_Files"


	use `var_year', replace

	// keep if events == 0

	*** We have a variable for the day after a game
	replace day_after_y = 0 if day_after_y==.


	*Making a variable for days where there is a game

	gen game=0

	*Setting the games to not include the day after

	replace game=1 if home_y=="Tottenham"&day_after_y==0
	replace game=1 if away_y=="Tottenham"&day_after_y==0



	*Creating a unique ID per district
	
	egen loc_id = group(district_name)

	* replacing missing values to zero for games close to a stadium

	replace close_home_adj = 0 if close_home_adj==.
	replace close_away_adj = 0 if close_away_adj==.

	g game_tot = game*tot
	
	*Adding the words jew and jewish to one variable
	g jewish = jew+jwi

	foreach var in pos neu neg{
		g jewish_`var' = jew_`var'+jwi_`var'
	}

* Creating variables for the average sentiment

	foreach var in jewish tot {
	g `var'_average_pos = `var'_pos/`var'
	g `var'_average_neg = `var'_neg/`var'
	replace `var'_average_pos = 0 if `var'_average_pos==.
	replace `var'_average_neg = 0 if `var'_average_neg==.

	}

	* creating a variable for districts which are in proximity to the stadium of
	* the team playing against Tottenham
	
	g close_otherteam_adj = 0
	replace close_otherteam_adj = close_away_adj if home_y=="Tottenham"&day_after_y==0
	replace close_otherteam_adj = close_home_adj if away_y=="Tottenham"&day_after_y==0

******************************************************************************************
**************** creating variables for windows around the time of the game	**************
******************************************************************************************

	gen edate = mdy(month, day, year)

* creating variables for windows around the date of the game	

	rangestat(mean) game , interval(edate -1 -1) by(district)
	rename game_mean day_before


	
		foreach var in game  close_otherteam_adj{
	rangestat (sum) `var'  , interval(edate -1 1) by(district)
	replace `var'_sum = 1 if `var'_sum>0 & `var'_sum!=.
		}

*Day before and after running sum

	rename game_sum game_three
	rename close_otherteam_adj_sum close_otherteam_adj_three

	
* 4 days before and after running sum
	
rangestat (sum) close_otherteam_adj  , interval(edate -4 4) by(district)
	replace close_otherteam_adj_sum = 1 if close_otherteam_adj_sum>0 & close_otherteam_adj_sum!=.
	rename close_otherteam_adj_sum close_otherteam_adj_eight

rangestat (sum) game  , interval(edate -4 4) by(district)
	replace game_sum = 1 if game_sum>0 & game_sum!=.
	rename game_sum game_eight



* Dummy variable for each game within 4 days before and after a game	
forval var = -4/0{
	foreach val in game close_otherteam_adj{
		local save_name = abs(`var')

		rangestat (sum)  `val' , interval(edate `var' `var') by(district)
		dis `save_name'
		rename `val'_sum `val'_`save_name'

}
}
	
forval var = 1/4{
	foreach val in game close_otherteam_adj{
		local save_name = abs(`var')

		rangestat (sum)  `val' , interval(edate `var' `var') by(district)

		dis `save_name'
		rename `val'_sum `val'_minus_`save_name'

}
}

* Creating different time ranges of time for each game

foreach var in    game   close_otherteam_adj    {
	g `var'_window1 = `var'_0 +`var'_1+`var'_minus_1
	g `var'_window2 = `var'_window1+`var'_2+`var'_minus_2
	g `var'_window3 = `var'_window2+`var'_3+`var'_minus_3
	g `var'_window4 = `var'_window3+`var'_4+`var'_minus_4

foreach val in window1 window2 window3 window4 {
replace `var'_`val' = 1 if `var'_`val'>1&  `var'_`val'!=.
}
}


* Creating variables for the days before and after a game
g game_before = game_minus_4 + game_minus_3 + game_minus_2 + game_minus_1
g game_after = game_1 + game_2 + game_3 + game_4 


keep  loc_id  district_name edate  date_format  weekday year month  events  isr  isr_pos  isr_neg  isr_neu  jewish  jewish_pos jewish_neg  jewish_neu  tot tot_pos  tot_neg  tot_neu  chi  chi_pos  chi_neg chi_neu  close_otherteam_adj_*   game_*


	cd "C:"

	save jeea_`var_year' ,replace
	
	
	
}

