
clear

use "ZA5252_v1-0-0.dta"

gen year = 2016

rename  mj01   jews_influence 
rename  mj04   jews_not_without_blame
rename  mj02   jews_shame
rename  mj06   israel_unjust  
rename  mm02   islam_fits_in 
rename  pn11   not_proud_german 
rename  ma11   foreigners_bad 
rename  mp03   foreigners_enrich_culture
rename  mg23   jews_same_rights
rename  pa01   political_spectrum
rename  mj05   israel_policy
rename  xr14   attractive
rename  gr03   county_urate
rename  gr01   county_perc_foriegners
rename  mg11   jews_neighbor_pleasant
rename  me18   jews_dont_annoy_me
rename  mg17   jews_marriage_pleasant
rename  mj03   jews_take_adv
rename  ma06   foreigners_same_welfare
rename  land   state



foreach varbx in jews_influence  israel_unjust islam_fits_in   not_proud_german  foreigners_bad   foreigners_enrich_culture   jews_same_rights  political_spectrum israel_policy  jews_not_without_blame  jews_shame    jews_neighbor_pleasant  jews_dont_annoy_me  jews_marriage_pleasant jews_take_adv  foreigners_same_welfare {
replace  `varbx' = .  if  `varbx' == -14  |  `varbx' == -11  |  `varbx' == -10  | `varbx' == -9  | `varbx' == -8  

}


gen very_proud_german   =  not_proud_german==1 if not_proud_german~=.
gen anti_jews_influence =  jews_influence
gen anti_jews_blame     =  jews_not_without_blame
gen anti_jews_take_adv  =  jews_take_adv
gen interviewer_over75  =  xi03c>=5  if xi03c~=.




foreach varbx  in  jews_same_rights  jews_shame  jews_neighbor_pleasant  jews_marriage_pleasant  {
gen       anti_`varbx' =  1   if  `varbx'==7
replace   anti_`varbx' =  2   if  `varbx'==6
replace   anti_`varbx' =  3   if  `varbx'==5
replace   anti_`varbx' =  4   if  `varbx'==4
replace   anti_`varbx' =  5   if  `varbx'==3
replace   anti_`varbx' =  6   if  `varbx'==2
replace   anti_`varbx' =  7   if  `varbx'==1
}

rename anti_jews_same_rights             anti_jews_rights
rename anti_jews_neighbor_pleasant       anti_jews_neighbor
rename anti_jews_marriage_pleasant       anti_jews_marriage



factor   anti_jews_influence   anti_jews_blame   anti_jews_take_adv   anti_jews_shame   anti_jews_neighbor,   factors(2)
predict  anti_jews_factor_1

factor   anti_jews_influence   anti_jews_blame   anti_jews_take_adv   anti_jews_shame   anti_jews_neighbor,   pcf
rotate

egen  anti_jews_mean  =  rowmean( anti_jews_influence    anti_jews_blame   anti_jews_take_adv    anti_jews_shame     anti_jews_neighbor)

replace  educ = .  if  educ==-9 |  educ==-41
replace  educ=. if educ==7                        /*  still in school       */
gen      cog  = educ==5                           /* qualify for university */


replace age = .  if age==-32 
gen age2 = age^2
gen male = sex==1

gen non_christian = rd01==5   if rd01~=-10  & rd01~=-9
rename rd01  religion
gen religion_none = religion==6  if religion~=.

gen native =  dn05==1  if   dn05~=-10

gen cohort_1930_45 =  yborn>=1930 & yborn<=1945
gen cohort_half_1  =  yborn< 1960
gen cohort_half_2  =  yborn>=1960  

label define  disagree_agree_7_lbl  1 "1 Completely Disagree"
label define  disagree_agree_7_lbl  2 "2"                     , add
label define  disagree_agree_7_lbl  3 "3"                     , add
label define  disagree_agree_7_lbl  4 "4"                     , add
label define  disagree_agree_7_lbl  5 "5"                     , add
label define  disagree_agree_7_lbl  6 "6"                     , add
label define  disagree_agree_7_lbl  7 "7 Completely Agree"      , add
label values  anti_jews_influence  disagree_agree_7_lbl


global  SPEC_1    " male   native                                                                                                                                                                 "
global  SPEC_2    " male   native  i.educ                                                                                                                                                         "
global  SPEC_3    " male   native  i.educ    county_perc_foriegners county_urate        i.state                                                                                              "
global  SPEC_4    " male   native  i.educ    county_perc_foriegners county_urate        i.state        i.political_spectrum  i.religion                                                                       "
global  SPEC_5    " male   native  i.educ    county_perc_foriegners county_urate        i.state        i.political_spectrum  i.religion     very_proud_german                                                "
global  SPEC_6    " male   native  i.educ    county_perc_foriegners county_urate        i.state        i.political_spectrum  i.religion     very_proud_german  foreigners_enrich_culture                     "
global  SPEC_7    " male   native  i.educ    county_perc_foriegners county_urate        i.state        i.political_spectrum  i.religion     very_proud_german  foreigners_enrich_culture   islam_fits_in     "


global  SAMPLE_1        "if  non_christian~=1  & native==1 & yborn>=1930 & yborn<=1990  , robust"
global  AGE_CONTROLS    "anti_jews_influence   political_spectrum  very_proud_german   religion_none  cog  foreigners_enrich_culture   islam_fits_in   israel_unjust   israel_policy"
global  JEW_VARBS       "anti_jews_factor_1    anti_jews_mean    anti_jews_influence   anti_jews_blame     anti_jews_take_adv      anti_jews_neighbor   anti_jews_shame   "



*************************************************																																		  
*   TABLE 6:  SUMMARY STATS
*************************************************


preserve
xi:  reg   israel_policy   anti_jews_influence  age age2  $SPEC_7  $SAMPLE_1
keep if e(sample)==1
sum   anti_jews_factor_1    anti_jews_mean  israel_unjust  israel_policy   anti_jews_influence    anti_jews_blame   anti_jews_take_adv    anti_jews_shame     anti_jews_neighbor          political_spectrum    very_proud_german   religion_none  cog  foreigners_enrich_culture   islam_fits_in      age  cohort_1930_45   cohort_half_1    male  

gen israel_unjust_6 = israel_unjust>=6  if israel_unjust~=.
gen israel_unjust_7 = israel_unjust>=7  if israel_unjust~=.

sum  israel_unjust_6  israel_unjust_7

tab anti_jews_influence if e(sample)
tab anti_jews_influence if e(sample)  &   israel_unjust==7
tab anti_jews_influence if e(sample)  &  (israel_unjust==7 | israel_unjust==6)


eststo clear
eststo: estpost   sum   israel_unjust  israel_policy   anti_jews_influence    anti_jews_blame   anti_jews_take_adv    anti_jews_shame     anti_jews_neighbor    anti_jews_factor_1    anti_jews_mean       political_spectrum    very_proud_german   religion_none  cog  foreigners_enrich_culture   islam_fits_in      age  cohort_1930_45   cohort_half_1    male  
esttab using SUMMARYSTATS_GSS_means.csv, cells("mean(fmt(2))") replace           
esttab using SUMMARYSTATS_GSS_stdev.csv, cells("sd(fmt(2))") replace           


eststo clear
eststo: estpost   sum   israel_unjust  israel_policy   anti_jews_influence    anti_jews_blame   anti_jews_take_adv    anti_jews_shame     anti_jews_neighbor    anti_jews_factor_1    anti_jews_mean       political_spectrum    very_proud_german   religion_none  cog  foreigners_enrich_culture   islam_fits_in      age  cohort_1930_45   cohort_half_1    male   if  (israel_unjust==7 & anti_jews_influence>3)
esttab using SUMMARYSTATS_7_above3.csv, cells("mean(fmt(2))") replace           

eststo clear
eststo: estpost   sum   israel_unjust  israel_policy   anti_jews_influence    anti_jews_blame   anti_jews_take_adv    anti_jews_shame     anti_jews_neighbor    anti_jews_factor_1    anti_jews_mean       political_spectrum    very_proud_german   religion_none  cog  foreigners_enrich_culture   islam_fits_in      age  cohort_1930_45   cohort_half_1    male   if  (israel_unjust==7 & anti_jews_influence<=3)
esttab using SUMMARYSTATS_7_below3.csv, cells("mean(fmt(2))") replace           



eststo clear
eststo: estpost   sum   israel_unjust  israel_policy   anti_jews_influence    anti_jews_blame   anti_jews_take_adv    anti_jews_shame     anti_jews_neighbor    anti_jews_factor_1    anti_jews_mean       political_spectrum    very_proud_german   religion_none  cog  foreigners_enrich_culture   islam_fits_in      age  cohort_1930_45   cohort_half_1    male   if  anti_jews_influence==7
esttab using SUMMARYSTATS_antijew7.csv, cells("mean(fmt(2))") replace           


bysort  israel_unjust:  sum   israel_unjust  israel_policy   anti_jews_influence    anti_jews_blame   anti_jews_take_adv    anti_jews_shame     anti_jews_neighbor    anti_jews_factor_1    anti_jews_mean       political_spectrum    very_proud_german   religion_none  cog  foreigners_enrich_culture   islam_fits_in      age  cohort_1930_45   cohort_half_1    male   if  anti_jews_influence==7

restore





*************************************************																																		  
*   TABLE 7:  Main OLS Results
*************************************************



xi:  reg   israel_unjust   anti_jews_influence  age age2  $SPEC_1  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel replace
xi:  reg   israel_unjust   anti_jews_influence  age age2  $SPEC_2  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
xi:  reg   israel_unjust   anti_jews_influence  age age2  $SPEC_3  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
xi:  reg   israel_unjust   anti_jews_influence  age age2  $SPEC_4  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
xi:  reg   israel_unjust   anti_jews_influence  age age2  $SPEC_5  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
xi:  reg   israel_unjust   anti_jews_influence  age age2  $SPEC_6  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
xi:  reg   israel_unjust   anti_jews_influence  age age2  $SPEC_7  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append


xi:  reg   israel_policy   anti_jews_influence  age age2  $SPEC_1  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
xi:  reg   israel_policy   anti_jews_influence  age age2  $SPEC_2  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
xi:  reg   israel_policy   anti_jews_influence  age age2  $SPEC_3  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
xi:  reg   israel_policy   anti_jews_influence  age age2  $SPEC_4  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
xi:  reg   israel_policy   anti_jews_influence  age age2  $SPEC_5  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
xi:  reg   israel_policy   anti_jews_influence  age age2  $SPEC_6  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
xi:  reg   israel_policy   anti_jews_influence  age age2  $SPEC_7  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
																   

																   
																   

*********************************************************																																		  
*   TABLE 8:  OLS Results for Various Views about Jews
*********************************************************
					
	
foreach varbx in  $JEW_VARBS {
reg   israel_unjust   `varbx'  age age2  $SPEC_3  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
}


foreach varbx in  $JEW_VARBS {
reg   israel_policy   `varbx'  age age2  $SPEC_3  $SAMPLE_1
                                                                   outreg2    using  Table_7_8.xls, excel append
}




																   

******************************************************************************																																		  
*   TABLE 9:  Reduced Form, First Stage, and Age patterns of personal views
******************************************************************************


reg   age      cohort_1930_45  age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Table_9.xls, excel replace
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'                  age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Table_9.xls, excel append
}
																				
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  cohort_1930_45  age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Table_9.xls, excel append
}

foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  cohort_1930_45  cohort_half_1    $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Table_9.xls, excel append
}

foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  anti_jews_influence              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Table_9.xls, excel append
}

foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  israel_unjust                    $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Table_9.xls, excel append
}



															   

******************************************************************************																																		  
*   TABLE 10:  Main IV Results
******************************************************************************


xi:  ivreg2     israel_unjust     ( anti_jews_influence = cohort_1930_45 )                                 $SPEC_1   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel replace
xi:  ivreg2     israel_unjust     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_1   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_2   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_3   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_4   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_5   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_6   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_7   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append



xi:  ivreg2     israel_policy     ( anti_jews_influence = cohort_1930_45 )                                 $SPEC_1   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_1   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_2   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_3   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_4   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_5   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_6   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = cohort_1930_45 )  cohort_half_1                  $SPEC_7   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
																								  
																																		  
																																		  
******************************************************************************																																		  
*   TABLE 11:  IV Results for Various Views about Jews
******************************************************************************
	
	
foreach varbx in  $JEW_VARBS {
xi:  ivreg2     israel_unjust     ( `varbx' = cohort_1930_45 )  cohort_half_1                  $SPEC_3   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
}


foreach varbx in  $JEW_VARBS {
xi:  ivreg2     israel_policy     ( `varbx' = cohort_1930_45 )  cohort_half_1                  $SPEC_3   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_10_11.xls, excel append
}



																																		  

******************************************************************************																																		  
*   TABLE 12:  IV Results by Birth Cohorts using year of birth as the IV
******************************************************************************						  


preserve
keep if yborn>=1930 & yborn<1960

xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_1   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel replace
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_2   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_3   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_4   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_5   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_6   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_7   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
restore


preserve
keep if yborn>=1960 & yborn<1990

xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_1   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_2   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_3   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_4   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_5   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_6   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_7   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
restore


xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_1   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_2   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_3   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_4   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_5   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_6   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_7   $SAMPLE_1   
                                                                                                                                          outreg2    using  Table_12.xls, excel append

																																		  
																																		  
																																		  
																																		  
																																		  
																																		  

******************************************************
*   APPENDIX TABLE 6 - OLS Results by Subgroups
******************************************************
																							  


preserve
keep if yborn>=1930 & yborn<1960

xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_1   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel replace
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_2   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_3   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_4   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_5   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_6   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_7   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
restore																																		  
		
		
preserve
keep if yborn>=1960 & yborn<1990

xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_1   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_2   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_3   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_4   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_5   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_6   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_7   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
restore																																		  



preserve
keep if male==1

xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_1   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_2   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_3   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_4   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_5   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_6   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_7   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
restore																																		  


preserve
keep if male==0

xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_1   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_2   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_3   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_4   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_5   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_6   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_7   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
restore																																		  


preserve
keep if cog==1

xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_1   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_2   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_3   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_4   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_5   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_6   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_7   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
restore																																		  


preserve
keep if cog==0

xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_1   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_2   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_3   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_4   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_5   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_6   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_7   $SAMPLE_1   
                                                                                                         outreg2    using  OLS_subgroups.xls, excel append
restore																																		  




																																	  

****************************************************************************
*   APPENDIX TABLE 7 - OSTER ANALYSIS
****************************************************************************

* net install rcr, from("http://www.sfu.ca/~bkrauth/code")

global SPEC_SELECT "age age2  male  county_perc_foriegners county_urate   _Ieduc_2 _Ieduc_3 _Ieduc_4 _Ieduc_5 _Ieduc_6 _Istate_20 _Istate_30 _Istate_40 _Istate_50 _Istate_60 _Istate_70  _Istate_80 _Istate_90 _Istate_100 _Istate_111 _Istate_112 _Istate_120 _Istate_130 _Istate_140 _Istate_150 _Istate_160    _Ipolitical_2 _Ipolitical_3 _Ipolitical_4 _Ipolitical_5 _Ipolitical_6 _Ipolitical_7 _Ipolitical_8 _Ipolitical_9 _Ipolitical_10   _Ireligion_3    _Ireligion_5 _Ireligion_6    _Ireligion_8  very_proud_german  foreigners_enrich_culture   islam_fits_in    if  non_christian~=1  & native==1 & yborn>=1930 & yborn<=1990"

xi:  reg     israel_unjust      anti_jews_influence   age age2                $SPEC_7   $SAMPLE_1   


rcr   israel_unjust   anti_jews_factor_1   $SPEC_SELECT, citype("imbens-manski")
                                                                                  outreg2    using  Appendix_Table_7.xls, excel replace
rcr   israel_unjust   anti_jews_mean       $SPEC_SELECT, citype("imbens-manski")
                                                                                  outreg2    using  Appendix_Table_7.xls, excel append
rcr   israel_unjust   anti_jews_influence  $SPEC_SELECT, citype("imbens-manski")
                                                                                  outreg2    using  Appendix_Table_7.xls, excel append
rcr   israel_unjust   anti_jews_blame      $SPEC_SELECT, citype("imbens-manski")
                                                                                  outreg2    using  Appendix_Table_7.xls, excel append
rcr   israel_unjust   anti_jews_take_adv   $SPEC_SELECT, citype("imbens-manski")
                                                                                  outreg2    using  Appendix_Table_7.xls, excel append
rcr   israel_unjust   anti_jews_neighbor   $SPEC_SELECT, citype("imbens-manski")
                                                                                  outreg2    using  Appendix_Table_7.xls, excel append
rcr   israel_unjust   anti_jews_shame      $SPEC_SELECT, citype("imbens-manski")
                                                                                  outreg2    using  Appendix_Table_7.xls, excel append
																				  

reg   israel_unjust   anti_jews_factor_1   $SPEC_SELECT, robust
                                                                                  outreg2    using  Appendix_Table_7b.xls, excel replace
reg   israel_unjust   anti_jews_mean       $SPEC_SELECT, robust
                                                                                  outreg2    using  Appendix_Table_7b.xls, excel append
reg   israel_unjust   anti_jews_influence  $SPEC_SELECT, robust
                                                                                  outreg2    using  Appendix_Table_7b.xls, excel append
reg   israel_unjust   anti_jews_blame      $SPEC_SELECT, robust
                                                                                  outreg2    using  Appendix_Table_7b.xls, excel append
reg   israel_unjust   anti_jews_take_adv   $SPEC_SELECT, robust
                                                                                  outreg2    using  Appendix_Table_7b.xls, excel append
reg   israel_unjust   anti_jews_neighbor   $SPEC_SELECT, robust
                                                                                  outreg2    using  Appendix_Table_7b.xls, excel append
reg   israel_unjust   anti_jews_shame      $SPEC_SELECT, robust
                                                                                  outreg2    using  Appendix_Table_7b.xls, excel append
																				  

						
	
																																																					  
																																		  
																																		  

****************************************************************************
*   APPENDIX TABLE 8 - Age Patterns of Personal Views by Birth Cohorts
****************************************************************************
																						  


reg   age                      age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_8.xls, excel replace																						  

preserve
keep if yborn>=1930 & yborn<1960

foreach varbx in  $AGE_CONTROLS {
reg   `varbx'                  age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_8.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  anti_jews_influence              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_8.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  israel_unjust                    $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_8.xls, excel append
}
restore



preserve
keep if yborn>=1960 & yborn<1990

foreach varbx in  $AGE_CONTROLS {
reg   `varbx'                  age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_8.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  anti_jews_influence              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_8.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  israel_unjust                    $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_8.xls, excel append
}
restore




																															  

********************************************************************************************************																																		  
*   APPENDIX TABLE 9:  IV Results by Gender and College Grad STatus using year of birth as the IV
********************************************************************************************************						  


preserve
keep if male==1

xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_1   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel replace
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_2   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_3   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_4   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_5   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_6   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_7   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
restore


preserve
keep if male==0

xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_1   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_2   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_3   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_4   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_5   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_6   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_7   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
restore





preserve
keep if cog==1

xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_1   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_2   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_3   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_4   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_5   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_6   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_7   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
restore


preserve
keep if cog==0

xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_1   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_2   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_3   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_4   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_5   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_6   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = yborn )    cohort_half_1                $SPEC_7   $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_9.xls, excel append
restore

																																		  
									

****************************************************************************
*   APPENDIX TABLE 10 - Age Patterns of Personal Views by Gender
****************************************************************************
																						  


reg   age                      age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_10.xls, excel replace																						  

preserve
keep if male==1

foreach varbx in  $AGE_CONTROLS {
reg   `varbx'                  age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_10.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  anti_jews_influence              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_10.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  israel_unjust                    $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_10.xls, excel append
}
restore



preserve
keep if male==0

foreach varbx in  $AGE_CONTROLS {
reg   `varbx'                  age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_10.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  anti_jews_influence              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_10.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  israel_unjust                    $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_10.xls, excel append
}
restore





*******************************************************************************
*   APPENDIX TABLE 11 - Age Patterns of Personal Views by College Grad Status
*******************************************************************************
																						  


reg   age                      age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_11.xls, excel replace																						  

preserve
keep if cog==1

foreach varbx in  $AGE_CONTROLS {
reg   `varbx'                  age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_11.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  anti_jews_influence              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_11.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  israel_unjust                    $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_11.xls, excel append
}
restore



preserve
keep if cog==0

foreach varbx in  $AGE_CONTROLS {
reg   `varbx'                  age              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_11.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  anti_jews_influence              $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_11.xls, excel append
}
foreach varbx in  $AGE_CONTROLS {
reg   `varbx'  israel_unjust                    $SPEC_1   $SAMPLE_1
                                                                                outreg2    using  Appendix_Table_11.xls, excel append
}
restore




												   

******************************************************************************																																		  
*   Appendix Table 12:  using interviewer age>75 as an IV
******************************************************************************


reg anti_jews_influence  interviewer_over75          $SAMPLE_1
sum anti_jews_influence  interviewer_over75          if e(sample)
reg age                  interviewer_over75          $SAMPLE_1


xi:  ivreg2     israel_unjust     ( anti_jews_influence = interviewer_over75 )                    $SPEC_1   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel replace
xi:  ivreg2     israel_unjust     ( anti_jews_influence = interviewer_over75 )                    $SPEC_2   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = interviewer_over75 )                    $SPEC_3   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = interviewer_over75 )                    $SPEC_4   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = interviewer_over75 )                    $SPEC_5   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = interviewer_over75 )                    $SPEC_6   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append
xi:  ivreg2     israel_unjust     ( anti_jews_influence = interviewer_over75 )                    $SPEC_7   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append



xi:  ivreg2     israel_policy     ( anti_jews_influence = interviewer_over75 )                    $SPEC_1   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = interviewer_over75 )                    $SPEC_2   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = interviewer_over75 )                    $SPEC_3   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = interviewer_over75 )                    $SPEC_4   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = interviewer_over75 )                    $SPEC_5   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = interviewer_over75 )                    $SPEC_6   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append
xi:  ivreg2     israel_policy     ( anti_jews_influence = interviewer_over75 )                    $SPEC_7   age age2  $SAMPLE_1   
                                                                                                                                          outreg2    using  Appendix_Table_12.xls, excel append

	
																																		  




**********************************************
*  FIGURES
**********************************************



gen          yborn_decade = 1920  if  yborn>=1920 & yborn<=1929
replace      yborn_decade = 1930  if  yborn>=1930 & yborn<=1939
replace      yborn_decade = 1940  if  yborn>=1940 & yborn<=1949
replace      yborn_decade = 1950  if  yborn>=1950 & yborn<=1959
replace      yborn_decade = 1960  if  yborn>=1960 & yborn<=1969
replace      yborn_decade = 1970  if  yborn>=1970 & yborn<=1979
replace      yborn_decade = 1980  if  yborn>=1980 & yborn<=1989
replace      yborn_decade = 1990  if  yborn>=1990 & yborn<=1999


label define yborn_decade_lbl 1920  "1920's"   1930 "1930's"   1940 "1940's" 1950 "1950's" 1960 "1960's" 1970 "1970's" 1980 "1980's" 1990 "1990's"
label  values yborn_decade  "yborn_decade_lbl"


label define seven_level_agree_lbl 1  "Completely Disagree"  2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "Completely Agree"
label  values israel_unjust  "seven_level_agree_lbl"

label  values israel_policy  "seven_level_agree_lbl"
label  values anti_jews_influence  "seven_level_agree_lbl"


global  SAMPLE_1  "if non_christian~=1  & native==1 & yborn>=1930 & yborn<=1989"

global STARTER = 0




global FIGNUMBER = 1
global TITLE_1     "Figure $FIGNUMBER:  Frequency of Views about Israel Taking Palestinian Land"
global SUB_TITLE_1 "German Social Survey 2016"
global LEFT_TITLE  "Sample Frequency"
global XTITLE      "It is unjust that Israel is taking away land from the Palestinians"

graph bar (count)  $SAMPLE_1 & year==2016, over(israel_unjust, label(labsize(vsmall)))      ytitle("$LEFT_TITLE", size(small))      title("$TITLE_1", size(automatic)) subtitle("$SUB_TITLE_1", size(small))  caption("Notes: The sample includes native born, Christians in the German Social Survey", size(tiny)) blabel(total, size(vsmall) format(%9.0f))   b1title($XTITLE, size(small))
graph save Graph "Figure_$FIGNUMBER", replace


global FIGNUMBER = $FIGNUMBER + 1
global TITLE_1     "Figure $FIGNUMBER:  Frequency of Views about Israeli Policy"
global SUB_TITLE_1 "German Social Survey 2016"
global LEFT_TITLE  "Sample Frequency"
global XTITLE      "Given Israel's policies I can well understand that people are against the Jews"

graph bar (count)  $SAMPLE_1 & year==2016, over(israel_policy, label(labsize(vsmall)))      ytitle("$LEFT_TITLE", size(small))      title("$TITLE_1", size(automatic)) subtitle("$SUB_TITLE_1", size(small))  caption("Notes: The sample includes native born, Christians in the German Social Survey", size(tiny)) blabel(total, size(vsmall) format(%9.0f))   b1title($XTITLE, size(small))
graph save Graph "Figure_$FIGNUMBER", replace





global FIGNUMBER = $FIGNUMBER + 1
global TITLE_1     "Figure $FIGNUMBER:  Two Views on Israel"
global SUB_TITLE_1 "German Social Survey 2016"
global LEFT_TITLE  "Mean of Israel Policy Justifies Antisemitism"
global XTITLE      "Israel Taking Palestinian Land is Unjust"

graph bar (mean) israel_policy  $SAMPLE_1 & year==2016, over(israel_unjust, label(labsize(vsmall)))  yscale(range(1 7)) ylabel(1(1)7)    ytitle("$LEFT_TITLE", size(small))      title("$TITLE_1", size(automatic)) subtitle("$SUB_TITLE_1", size(small))  caption("Notes: The sample includes native born, Christians in the German Social Survey", size(tiny)) blabel(total, size(vsmall) format(%9.2f))   b1title($XTITLE)
graph save Graph "Figure_$FIGNUMBER", replace








global FIGNUMBER = $FIGNUMBER + 1
global TITLE_1     "Figure $FIGNUMBER:  Frequency of Views about Jews Having Influence"
global SUB_TITLE_1 "German Social Survey 2016"
global LEFT_TITLE  "Sample Frequency"
global XTITLE      "Jewish people have too much influence in the world"

graph bar (count)  $SAMPLE_1 & year==2016, over(anti_jews_influence, label(labsize(vsmall)))      ytitle("$LEFT_TITLE", size(small))      title("$TITLE_1", size(automatic)) subtitle("$SUB_TITLE_1", size(small))  caption("Notes: The sample includes native born, Christians in the German Social Survey", size(tiny)) blabel(total, size(vsmall) format(%9.0f))   b1title($XTITLE, size(small))
graph save Graph "Figure_$FIGNUMBER", replace





global FIGNUMBER = $FIGNUMBER + 1
global TITLE_1     "Figure $FIGNUMBER:  Views on Jewish Influence by Views on Israel"
global SUB_TITLE_1 "German Social Survey 2016"
global LEFT_TITLE  "Jews Have Too Much Influence - Level of Agreement"
global XTITLE      "Israel Taking Palestinian Land is Unjust"

graph bar (mean) anti_jews_influence  $SAMPLE_1 & year==2016, over(israel_unjust, label(labsize(vsmall)))  yscale(range(1 7)) ylabel(1(1)7)    ytitle("$LEFT_TITLE", size(small))      title("$TITLE_1", size(automatic)) subtitle("$SUB_TITLE_1", size(small))  caption("Notes: The sample includes native born, Christians in the German Social Survey", size(tiny)) blabel(total, size(vsmall) format(%9.2f))   b1title($XTITLE)
graph save Graph "Figure_$FIGNUMBER", replace





global FIGNUMBER = $FIGNUMBER + 1
global TITLE_1     "Figure $FIGNUMBER:  Views on Jewish Influence by Views on Israeli Policy"
global SUB_TITLE_1 "German Social Survey 2016"
global LEFT_TITLE  "Jews Have Too Much Influence - Level of Agreement"
global XTITLE      "Israel Policy Justifies Antisemitism"

graph bar (mean) anti_jews_influence  $SAMPLE_1 & year==2016, over(israel_policy, label(labsize(vsmall)))  yscale(range(1 7)) ylabel(1(1)7)    ytitle("$LEFT_TITLE", size(small))      title("$TITLE_1", size(automatic)) subtitle("$SUB_TITLE_1", size(small))  caption("Notes: The sample includes native born, Christians in the German Social Survey", size(tiny)) blabel(total, size(vsmall) format(%9.2f))   b1title($XTITLE)
graph save Graph "Figure_$FIGNUMBER", replace



global FIGNUMBER = $FIGNUMBER + 1
global TITLE_1     "Figure $FIGNUMBER:  Jews Have Too Much Influence by Birth Cohort in 2016"
global SUB_TITLE_1 "German Social Survey 2016"
global LEFT_TITLE  "Completely Disagree = 1 and Completely Agree = 7"
global XTITLE      "Birth Cohort Decade"

graph bar (mean) anti_jews_influence  $SAMPLE_1 & year==2016, over(yborn_decade, label(labsize(vsmall)))  yscale(range(1 7)) ylabel(1(1)7)    ytitle("$LEFT_TITLE", size(small))      title("$TITLE_1", size(automatic)) subtitle("$SUB_TITLE_1", size(small))  caption("Notes: The sample includes native born, Christians in the German Social Survey", size(tiny)) blabel(total, size(vsmall) format(%9.2f))   b1title($XTITLE)
graph save Graph "Figure_$FIGNUMBER", replace



