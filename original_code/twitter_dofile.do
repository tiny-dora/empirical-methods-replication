
clear all
set more off


use jeea_25km


drop if events==1


global  VARBLIST        "isr  isr_pos  isr_neg  jewish  jewish_pos jewish_neg  tot tot_pos  tot_neg  close_otherteam_adj_eight   game_eight"


foreach var in    game   close_otherteam_adj    {

    gen   pre4_`var'       =    `var'_minus_1 + `var'_minus_2 +`var'_minus_3 + `var'_minus_4
	gen   post4_`var'      =    `var'_0 +`var'_1 + `var'_2 +`var'_3 + `var'_4
	gen   window4_`var'    =     pre4_`var' + post4_`var'

	replace   pre4_`var'       = 1  if pre4_`var' >1    &   pre4_`var'~=.
	replace   post4_`var'      = 1  if post4_`var'>1    &   post4_`var'~=.
	replace	  window4_`var'    = 1  if window4_`var'>1  &   window4_`var'~=.
}


global CLOSE_VARBS  " close_otherteam_adj_minus_4  close_otherteam_adj_minus_3  close_otherteam_adj_minus_2  close_otherteam_adj_minus_1  close_otherteam_adj_0  close_otherteam_adj_1  close_otherteam_adj_2  close_otherteam_adj_3  close_otherteam_adj_4 "
global GAME_VARBS  "  game_minus_4  game_minus_3  game_minus_2  game_minus_1  game_0  game_1  game_2  game_3  game_4 "



***************************************
* Table 1:  Descriptive Statistics
***************************************

global  SUMSTATS_VARBS        "isr isr_pos isr_neg  jewish  jewish_pos  jewish_neg  tot  tot_pos  tot_neg  chi  chi_pos  chi_neg"


sum  $SUMSTATS_VARBS

preserve
xi:  reg   isr  jewish tot  loc_id  weekday year month
keep if e(sample)==1
sum    
eststo clear
eststo: estpost   sum   $SUMSTATS_VARBS  
esttab using SUMMARYSTATS_TWITTER_means.csv, cells("mean(fmt(3))") replace           
*esttab using SUMMARYSTATS_TWITTER_stdev.csv, cells("sd(fmt(3))") replace 


sum   $SUMSTATS_VARBS   if window4_game ==1
eststo clear
eststo: estpost   sum   $SUMSTATS_VARBS   if window4_game ==1
esttab using SUMMARYSTATS_TWITTER_means_games.csv, cells("mean(fmt(3))") replace           


sum   $SUMSTATS_VARBS   if window4_close_otherteam_adj ==1
eststo clear
eststo: estpost   sum   $SUMSTATS_VARBS   if window4_close_otherteam_adj ==1
esttab using SUMMARYSTATS_TWITTER_means_close.csv, cells("mean(fmt(3))") replace           

restore


*********************************************************************************
* Table 2:  OLS relationships between Tweets about Israel, Jews, and Tottenham
*********************************************************************************


reghdfe isr          jewish                             , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) replace

reghdfe isr_pos      jewish_pos jewish_neg              , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) append
reghdfe isr_neg      jewish_pos jewish_neg              , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) append
reghdfe isr_neg                 jewish_neg              , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) append

reghdfe jewish_pos   tot_pos    tot_neg                 , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) append
reghdfe jewish_neg   tot_pos    tot_neg                 , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) append
reghdfe jewish_neg              tot_neg                 , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) append

reghdfe isr_pos      tot_pos    tot_neg                 , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) append
reghdfe isr_neg      tot_pos    tot_neg                 , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) append
reghdfe isr_neg                 tot_neg                 , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) append

																											  
																											  
reghdfe chi_neg      tot_pos    tot_neg                 , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) append
reghdfe chi_neg                 tot_neg                 , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                              outreg2 using TABLE_2.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) append
																											  
																								




************************************************************
* Table 3: IV Results for Negative Tweets About Israel 
************************************************************


ivreghdfe isr_neg          (jewish_neg = tot_neg                                                      )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                               outreg2 using TABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, No , Game 8, No , Close Game 8, No , Game 8 Dummies, No , Close Game Dummies, No ) replace
ivreghdfe isr_neg          (jewish_neg = tot_neg   tot_pos                                            )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                               outreg2 using TABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, Yes, Game 8, No , Close Game 8, No , Game 8 Dummies, No , Close Game Dummies, No ) append
ivreghdfe isr_neg          (jewish_neg =                     window4_game  window4_close_otherteam_adj)      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                               outreg2 using TABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, No , Pos Tot, No , Game 8, Yes, Close Game 8, Yes, Game 8 Dummies, No , Close Game Dummies, No ) append
ivreghdfe isr_neg          (jewish_neg =                     $GAME_VARBS   $CLOSE_VARBS               )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                               outreg2 using TABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, No , Pos Tot, No , Game 8, No , Close Game 8, No , Game 8 Dummies, Yes, Close Game Dummies, Yes) append

ivreghdfe isr_neg          (jewish_neg = tot_neg   tot_pos   window4_game  window4_close_otherteam_adj)      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                               outreg2 using TABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, Yes, Game 8, Yes, Close Game 8, Yes, Game 8 Dummies, No , Close Game Dummies, No ) append
ivreghdfe isr_neg          (jewish_neg = tot_neg   tot_pos   $GAME_VARBS   $CLOSE_VARBS               )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                               outreg2 using TABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, Yes, Game 8, No , Close Game 8, No , Game 8 Dummies, Yes, Close Game Dummies, Yes) append

ivreghdfe isr_pos          (jewish_neg = tot_neg                                                      )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                               outreg2 using TABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, No , Game 8, No , Close Game 8, No , Game 8 Dummies, No , Close Game Dummies, No ) append																											   

																											   
ivreghdfe chi_neg          (jewish_neg = tot_neg                                                      )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                               outreg2 using TABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, No , Game 8, No , Close Game 8, No , Game 8 Dummies, No , Close Game Dummies, No ) append
ivreghdfe chi_neg          (jewish_neg = tot_neg   tot_pos                                            )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                               outreg2 using TABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, Yes, Game 8, No , Close Game 8, No , Game 8 Dummies, No , Close Game Dummies, No ) append

			


**************************************************************************
* Table 4:  Main Results using Observations at the Weekly Level
**************************************************************************


preserve

gen  weekofyear = week(edate)
collapse (sum) $VARBLIST, by(loc_id year weekofyear)

reghdfe   isr          jewish                             , absorb(loc_id year weekofyear) cluster(loc_id)
                                                                                                          outreg2 using TABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No, Neg Tot, No, Pos Tot, No) replace
reghdfe   isr_pos      jewish_pos jewish_neg              , absorb(loc_id year weekofyear) cluster(loc_id)
                                                                                                          outreg2 using TABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No, Neg Tot, No, Pos Tot, No) append
reghdfe   isr_neg      jewish_pos jewish_neg              , absorb(loc_id year weekofyear) cluster(loc_id)
                                                                                                          outreg2 using TABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No, Neg Tot, No, Pos Tot, No) append
reghdfe   isr_neg                 jewish_neg              , absorb(loc_id year weekofyear) cluster(loc_id)
                                                                                                          outreg2 using TABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No, Neg Tot, No, Pos Tot, No) append
ivreghdfe isr_pos      (jewish_neg = tot_neg           )  , absorb(loc_id year weekofyear) cluster(loc_id) first
                                                                                                          outreg2 using TABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, YES, Neg Tot, YES, Pos Tot, No) append
ivreghdfe isr_neg      (jewish_neg = tot_neg           )  , absorb(loc_id year weekofyear) cluster(loc_id) first
                                                                                                          outreg2 using TABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, YES, Neg Tot, YES, Pos Tot, No) append
ivreghdfe isr_neg      (jewish_neg = tot_neg   tot_pos )  , absorb(loc_id year weekofyear) cluster(loc_id) first
                                                                                                          outreg2 using TABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, YES, Neg Tot, YES, Pos Tot, YES) append
restore
																											  

																											  
																											  
**************************************************************************
*  Table 5:  Main Results using All Tweets about Jews and Tottenham
**************************************************************************


reghdfe    isr_pos           jewish                              , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No) replace
ivreghdfe  isr_pos          (jewish = tot                 )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append
ivreghdfe  isr_pos          (jewish = tot_pos   tot_neu   )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append
ivreghdfe  isr_pos          (jewish =           tot_neg   )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append

reghdfe    isr_pos           jewish_neg                              , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No)  append
ivreghdfe  isr_pos          (jewish_neg = tot                 )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append
ivreghdfe  isr_pos          (jewish_neg = tot_pos   tot_neu   )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append
ivreghdfe  isr_pos          (jewish_neg =           tot_neg   )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append


reghdfe    isr_neg           jewish                              , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No)  append
ivreghdfe  isr_neg          (jewish = tot                 )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append
ivreghdfe  isr_neg          (jewish = tot_pos   tot_neu   )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append
ivreghdfe  isr_neg          (jewish =           tot_neg   )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append

reghdfe    isr_neg           jewish_neg                              , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, No)  append
ivreghdfe  isr_neg          (jewish_neg = tot                 )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append
ivreghdfe  isr_neg          (jewish_neg = tot_pos   tot_neu   )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append
ivreghdfe  isr_neg          (jewish_neg =           tot_neg   )      , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                                       outreg2 using TABLE_5.xls, nocons bdec(3) sdec(3)  addtex(Time FE, Yes, Location FE, Yes, IV, YES) append

	
*************************************************************************************************************************************************
*************************************************************************************************************************************************



***************************************************************************************************
* APPENDIX TABLE 1
***************************************************************************************************


reghdfe tot_neg                 window4_game                                      , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                    outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) replace
reghdfe tot_neg                 window4_game     window4_close_otherteam_adj      , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                    outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) append

reghdfe jewish_neg              window4_game                                      , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                    outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) append
reghdfe jewish_neg              window4_game     window4_close_otherteam_adj      , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                    outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) append

reghdfe isr_neg                 window4_game                                      , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                    outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) append
reghdfe isr_neg                 window4_game     window4_close_otherteam_adj      , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                    outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) append

reghdfe chi_neg                 window4_game                                      , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                    outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) append
reghdfe chi_neg                 window4_game     window4_close_otherteam_adj      , absorb(loc_id weekday year month) cluster(loc_id)
                                                                                    outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) append

																					
*******************
* Not reported
*******************

reghdfe tot_neg                 $GAME_VARBS                     , absorb(loc_id weekday year month) cluster(loc_id)
                                                                  outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) replace
reghdfe tot_neg                 $GAME_VARBS   $CLOSE_VARBS      , absorb(loc_id weekday year month) cluster(loc_id)
                                                                  outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) append

reghdfe jewish_neg              $GAME_VARBS                     , absorb(loc_id weekday year month) cluster(loc_id)
                                                                  outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) append
reghdfe jewish_neg              $GAME_VARBS   $CLOSE_VARBS      , absorb(loc_id weekday year month) cluster(loc_id)
                                                                  outreg2 using APP_TABLE_1.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No) append





*******************************************************************************
* Appendix Table 2: IV Results for Positive and Negative Tweets About Israel 
*******************************************************************************

ivreghdfe isr_pos          (jewish_neg              = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS    )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                            outreg2 using APPTABLE_2.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, Yes, Game 8, No, Close Game 8, No, Game 8 Dummies, YES, Close Game Dummies, YES ) replace
ivreghdfe isr_pos          (jewish_neg  jewish_pos  = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS    )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                            outreg2 using APPTABLE_2.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, Yes, Game 8, No, Close Game 8, No, Game 8 Dummies, YES, Close Game Dummies, YES ) append


ivreghdfe isr_neg          (jewish_neg              = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS    )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                            outreg2 using APPTABLE_2.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, Yes, Game 8, No, Close Game 8, No, Game 8 Dummies, YES, Close Game Dummies, YES ) append
ivreghdfe isr_neg          (jewish_neg  jewish_pos  = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS    )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                            outreg2 using APPTABLE_2.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, Yes, Game 8, No, Close Game 8, No, Game 8 Dummies, YES, Close Game Dummies, YES ) append


ivreghdfe chi_neg          (jewish_neg              = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS    )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                            outreg2 using APPTABLE_2.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, Yes, Game 8, No, Close Game 8, No, Game 8 Dummies, YES, Close Game Dummies, YES ) append
ivreghdfe chi_neg          (jewish_neg  jewish_pos  = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS    )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                            outreg2 using APPTABLE_2.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, Yes, Pos Tot, Yes, Game 8, No, Close Game 8, No, Game 8 Dummies, YES, Close Game Dummies, YES ) append
																											
	

**************************************************************************
* Appendix Table 4:  Main Results using Observations at the Monthly Level
**************************************************************************


preserve
collapse (sum) $VARBLIST, by(loc_id year month)


reghdfe   isr          jewish                             , absorb(loc_id year month) cluster(loc_id)
                                                                                                          outreg2 using APPTABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No, Neg Tot, No, Pos Tot, No) replace
reghdfe   isr_pos      jewish_pos jewish_neg              , absorb(loc_id year month) cluster(loc_id)
                                                                                                          outreg2 using APPTABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No, Neg Tot, No, Pos Tot, No) append
reghdfe   isr_neg      jewish_pos jewish_neg              , absorb(loc_id year month) cluster(loc_id)
                                                                                                          outreg2 using APPTABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No, Neg Tot, No, Pos Tot, No) append
reghdfe   isr_neg                 jewish_neg              , absorb(loc_id year month) cluster(loc_id)
                                                                                                          outreg2 using APPTABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, No, Neg Tot, No, Pos Tot, No) append
ivreghdfe isr_pos      (jewish_neg = tot_neg           )  , absorb(loc_id year month) cluster(loc_id) first
                                                                                                          outreg2 using APPTABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, YES, Neg Tot, YES, Pos Tot, No) append
ivreghdfe isr_neg      (jewish_neg = tot_neg           )  , absorb(loc_id year month) cluster(loc_id) first
                                                                                                          outreg2 using APPTABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, YES, Neg Tot, YES, Pos Tot, No) append
ivreghdfe isr_neg      (jewish_neg = tot_neg   tot_pos )  , absorb(loc_id year month) cluster(loc_id) first
                                                                                                          outreg2 using APPTABLE_4.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, YES, Neg Tot, YES, Pos Tot, YES) append

restore




																										  
****************************************************************************************************************
* Appendix Table 5: OLS Results with Poisson Model with Fixed Effects and Robust St. Errors
****************************************************************************************************************


xi: xtpqml isr           jewish                i.weekday i.month i.year , i(loc_id) cluster(loc_id)
margins, dydx(jewish)
                                               outreg2 using APPTABLE_5.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes) replace
xi: xtpqml isr_neg       jewish_neg            i.weekday i.month i.year , i(loc_id) cluster(loc_id)
margins, dydx(jewish_neg)
                                               outreg2 using APPTABLE_5.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes) append
xi: xtpqml isr_pos       jewish_neg            i.weekday i.month i.year , i(loc_id) cluster(loc_id)
margins, dydx(jewish_neg)
                                               outreg2 using APPTABLE_5.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes) append
xi: xtpqml isr_neg       tot_neg               i.weekday i.month i.year , i(loc_id) cluster(loc_id)
margins, dydx(tot_neg)
                                               outreg2 using APPTABLE_5.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes) append
			
																													   

***************************************************************************************************************************************************************
***************************************************************************************************************************************************************
***************************************************************************************************************************************************************



*********************************************************************************
* Appendix Table 3 (15 kilometers): IV Results using "NEAR" at different ranges
*********************************************************************************


clear
use jeea_15km
drop if events==1


sum  isr  isr_pos  isr_neg  jewish  jewish_pos jewish_neg  tot tot_pos  tot_neg  close_otherteam_adj_eight   game_eight

global  VARBLIST        "isr  isr_pos  isr_neg  jewish  jewish_pos jewish_neg  tot tot_pos  tot_neg  close_otherteam_adj_eight   game_eight"


foreach var in    game   close_otherteam_adj    {

    gen   pre4_`var'       =    `var'_minus_1 + `var'_minus_2 +`var'_minus_3 + `var'_minus_4
	gen   post4_`var'      =    `var'_0 +`var'_1 + `var'_2 +`var'_3 + `var'_4
	gen   window4_`var'    =     pre4_`var' + post4_`var'

	replace   pre4_`var'       = 1  if pre4_`var' >1    &   pre4_`var'~=.
	replace   post4_`var'      = 1  if post4_`var'>1    &   post4_`var'~=.
	replace	  window4_`var'    = 1  if window4_`var'>1  &   window4_`var'~=.
}


global CLOSE_VARBS  " close_otherteam_adj_minus_4  close_otherteam_adj_minus_3  close_otherteam_adj_minus_2  close_otherteam_adj_minus_1  close_otherteam_adj_0  close_otherteam_adj_1  close_otherteam_adj_2  close_otherteam_adj_3  close_otherteam_adj_4 "
global GAME_VARBS  "  game_minus_4  game_minus_3  game_minus_2  game_minus_1  game_0  game_1  game_2  game_3  game_4 "





ivreghdfe isr_pos          (jewish_neg             = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS                  )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                              outreg2 using APPTABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, YES, Pos Tot, YES, Game 8, No , Close Game 8, No , Game 8 Dummies, YES, Close Game Dummies, YES, Near Distance, 15) replace
ivreghdfe isr_pos          (jewish_neg  jewish_pos = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS                  )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                              outreg2 using APPTABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, YES, Pos Tot, YES, Game 8, No , Close Game 8, No , Game 8 Dummies, YES, Close Game Dummies, YES, Near Distance, 15) append

ivreghdfe isr_neg          (jewish_neg             = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS                  )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                              outreg2 using APPTABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, YES, Pos Tot, YES, Game 8, No , Close Game 8, No , Game 8 Dummies, YES, Close Game Dummies, YES, Near Distance, 15) append
ivreghdfe isr_neg          (jewish_neg  jewish_pos = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS                  )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                              outreg2 using APPTABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, YES, Pos Tot, YES, Game 8, No , Close Game 8, No , Game 8 Dummies, YES, Close Game Dummies, YES, Near Distance, 15) append
	
																											  
																											  
*********************************************************************************
* Appendix Table 3 (20 kilometers): IV Results using "NEAR" at different ranges
*********************************************************************************

clear
use jeea_20km
drop if events==1


sum  isr  isr_pos  isr_neg  jewish  jewish_pos jewish_neg  tot tot_pos  tot_neg  close_otherteam_adj_eight   game_eight

global  VARBLIST        "isr  isr_pos  isr_neg  jewish  jewish_pos jewish_neg  tot tot_pos  tot_neg  close_otherteam_adj_eight   game_eight"


foreach var in    game   close_otherteam_adj    {

    gen   pre4_`var'       =    `var'_minus_1 + `var'_minus_2 +`var'_minus_3 + `var'_minus_4
	gen   post4_`var'      =    `var'_0 +`var'_1 + `var'_2 +`var'_3 + `var'_4
	gen   window4_`var'    =     pre4_`var' + post4_`var'

	replace   pre4_`var'       = 1  if pre4_`var' >1    &   pre4_`var'~=.
	replace   post4_`var'      = 1  if post4_`var'>1    &   post4_`var'~=.
	replace	  window4_`var'    = 1  if window4_`var'>1  &   window4_`var'~=.
}


global CLOSE_VARBS  " close_otherteam_adj_minus_4  close_otherteam_adj_minus_3  close_otherteam_adj_minus_2  close_otherteam_adj_minus_1  close_otherteam_adj_0  close_otherteam_adj_1  close_otherteam_adj_2  close_otherteam_adj_3  close_otherteam_adj_4 "
global GAME_VARBS  "  game_minus_4  game_minus_3  game_minus_2  game_minus_1  game_0  game_1  game_2  game_3  game_4 "




ivreghdfe isr_pos          (jewish_neg             = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS                  )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                              outreg2 using APPTABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, YES, Pos Tot, YES, Game 8, No , Close Game 8, No , Game 8 Dummies, YES, Close Game Dummies, YES, Near Distance, 20) append
ivreghdfe isr_pos          (jewish_neg  jewish_pos = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS                  )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                              outreg2 using APPTABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, YES, Pos Tot, YES, Game 8, No , Close Game 8, No , Game 8 Dummies, YES, Close Game Dummies, YES, Near Distance, 20) append

ivreghdfe isr_neg          (jewish_neg             = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS                  )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                              outreg2 using APPTABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, YES, Pos Tot, YES, Game 8, No , Close Game 8, No , Game 8 Dummies, YES, Close Game Dummies, YES, Near Distance, 20) append
ivreghdfe isr_neg          (jewish_neg  jewish_pos = tot_pos  tot_neg   $GAME_VARBS   $CLOSE_VARBS                  )   , absorb(loc_id weekday year month) cluster(loc_id) first
                                                                                                              outreg2 using APPTABLE_3.xls, nocons bdec(3) sdec(3) addtex(Time FE, Yes, Location FE, Yes, IV, Yes, Neg Tot, YES, Pos Tot, YES, Game 8, No , Close Game 8, No , Game 8 Dummies, YES, Close Game Dummies, YES, Near Distance, 20) append

clear
																										  
	