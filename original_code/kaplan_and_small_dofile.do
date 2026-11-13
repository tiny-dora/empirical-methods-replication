

clear


use  "kaplan and small data.dta" 




factor  care_jews shady loyal_israel bus_power int_fin_mkt power_country unfair_compete irr_faults stick_tog head_things honest,   factors(2)
predict  anti_jews_factor_1


factor  israel_apartheid israel_violence target_civilians suicide_bombing_ok,   factors(2)
predict  anti_israel_factor_1


global VARBS_JEWS    "  antisemiticindex  anti_jews_factor_1  care_jews shady loyal_israel bus_power int_fin_mkt power_country unfair_compete irr_faults stick_tog head_things honest"
global VARBS_ISRAEL  "  antiisraelindex  anti_israel_factor_1 israel_apartheid israel_violence target_civilians suicide_bombing_ok "



tab age, gen(_age_cat)

gen  age_cat_4_5 = _age_cat4 + _age_cat5

gen      age_group = 1  if age=="18-24"
replace  age_group = 2  if age=="25-34"
replace  age_group = 3  if age=="35-44"
replace  age_group = 4  if age=="45-54"
replace  age_group = 5  if age=="55-64"
replace  age_group = 6  if age=="Refuse"
replace  age_group = 7  if age=="Unknown"



gen      yborn  =  1    if  age_group==5
replace  yborn  =  2    if  age_group==4
replace  yborn  =  3    if  age_group==3
replace  yborn  =  4    if  age_group==2
replace  yborn  =  5    if  age_group==1


gen  yborn_1_2 = _age_cat4 + _age_cat5

gen  yborn_1 = yborn==1
gen  yborn_2 = yborn==2
gen  yborn_3 = yborn==3
gen  yborn_4 = yborn==4
gen  yborn_5 = yborn==5



gen     age1 = 21 if age=="18-24"
replace age1 = 30 if age=="25-34"
replace age1 = 40 if age=="35-44"
replace age1 = 50 if age=="45-54"
replace age1 = 60 if age=="55-64"
 
label define yborn_lbl   1    "1940's"   2  "1950's"   3   "1960's"   4   "1970's"   5  "1980's" 
label  values yborn  "yborn_lbl"



gen much_in_common      =  common=="Disagree a lot"            if  common~="Refuse"  & common~="Unknown"
gen not_much_in_common  =  much_in_common==0                   if  much_in_common~=.
gen religion_none       =  religion=="None"                    if religion~="Refuse"  & religion~="Unknown"
gen religion_christian  =  religion_none==0                    if religion_none~=.
gen income_low          =  income=="< 11" |  income=="11-33"   if income~="Refuse"

gen male                =  gender=="Male"
gen immigrants_burden   =  immigrants=="Agree a little"  | immigrants=="Agree a lot"  if  immigrants~="Refuse"  & immigrants~="Unknown"


keep if _age_cat6~=1 & _age_cat7~=1 & (religion=="Christ" |  religion=="None")

global  BCOHORTS  "yborn_1  yborn_2  yborn_3  yborn_4   "


															   

*********************************************************																																		  
*   Appendix TABLE 13:  ADL Survey Summary Statistics
*********************************************************														   


preserve
xi:  reg  antiisraelindex   antisemiticindex   $BCOHORTS  i.gender i.country  i.religion  i.income  i.common  i.immigrants          , robust
keep if e(sample)==1
eststo clear
bysort country: eststo: estpost   sum    antiisraelindex   antisemiticindex   anti_israel_factor_1  anti_jews_factor_1   yborn_1   yborn_2  yborn_3  yborn_4 yborn_5  male  not_much_in_common   immigrants_burden  religion_christian  income_low 
esttab using SUMMARYSTATS_ADL_bycountry.csv, cells("mean(fmt(2))") replace           
                eststo: estpost   sum    antiisraelindex   antisemiticindex   anti_israel_factor_1  anti_jews_factor_1   yborn_1   yborn_2  yborn_3  yborn_4 yborn_5  male  not_much_in_common   immigrants_burden  religion_christian  income_low 
esttab using SUMMARYSTATS_ADL.csv, cells("mean(fmt(2))"  "sd(fmt(2))") replace           

restore



*********************************************************																																		  
*   TABLE 13:  ADL OLS Results
*********************************************************														   



xi:  reg  antiisraelindex   antisemiticindex   age1       i.gender i.country                                                        , robust
                                                                   outreg2    using  ADL_OLS.xls, excel replace
xi:  reg  antiisraelindex   antisemiticindex   $BCOHORTS  i.gender i.country                                                        , robust
                                                                   outreg2    using  ADL_OLS.xls, excel append
xi:  reg  antiisraelindex   antisemiticindex   $BCOHORTS  i.gender i.country  i.religion                                            , robust
                                                                   outreg2    using  ADL_OLS.xls, excel append
xi:  reg  antiisraelindex   antisemiticindex   $BCOHORTS  i.gender i.country  i.religion  i.income                                  , robust
                                                                   outreg2    using  ADL_OLS.xls, excel append																   
xi:  reg  antiisraelindex   antisemiticindex   $BCOHORTS  i.gender i.country  i.religion  i.income  i.common                        , robust
                                                                   outreg2    using  ADL_OLS.xls, excel append
xi:  reg  antiisraelindex   antisemiticindex   $BCOHORTS  i.gender i.country  i.religion  i.income  i.common  i.immigrants          , robust
                                                                   outreg2    using  ADL_OLS.xls, excel append
															   

															   
															   

********************************************************************************																																		  
*   Appendix TABLE 14:  ADL Age Patterns of Personal Views and Characteristics
********************************************************************************														   
					
					
					

xi:  reg  antisemiticindex      yborn_1  yborn_2    yborn_3  yborn_4      i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1.xls, excel replace
xi:  reg  antisemiticindex      yborn_1  yborn_1_2  yborn_3  yborn_4      i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1.xls, excel append
xi:  reg  antisemiticindex      yborn_1  yborn_1_2                        i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1.xls, excel append
xi:  reg  not_much_in_common    yborn_1  yborn_1_2                        i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1.xls, excel append
xi:  reg  immigrants_burden     yborn_1  yborn_1_2                        i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1.xls, excel append
xi:  reg  religion_christian    yborn_1  yborn_1_2                        i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1.xls, excel append
xi:  reg  income_low            yborn_1  yborn_1_2                        i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1.xls, excel append
xi:  reg  antiisraelindex       yborn_1  yborn_1_2                        i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1.xls, excel append


				   

xi:  reg  antisemiticindex      age1          i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1_age.xls, excel replace
xi:  reg  antisemiticindex      age1          i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1_age.xls, excel append
xi:  reg  antisemiticindex      age1          i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1_age.xls, excel append
xi:  reg  not_much_in_common    age1          i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1_age.xls, excel append
xi:  reg  immigrants_burden     age1          i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1_age.xls, excel append
xi:  reg  religion_christian    age1          i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1_age.xls, excel append
xi:  reg  income_low            age1          i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1_age.xls, excel append
xi:  reg  antiisraelindex       age1          i.gender i.country            , robust
                                                                   outreg2    using  ADL_STAGE1_age.xls, excel append

																   
														   
															   

********************************************************************************																																		  
*   TABLE 14:  ADL IV Results
********************************************************************************														   
																			   
																   
																   
xi: ivreg2 antiisraelindex ( antisemiticindex = yborn_1 )                               i.gender i.country                                                         , first robust
                                                                   outreg2    using  ADL_IV.xls, excel replace
xi: ivreg2 antiisraelindex ( antisemiticindex = yborn_1 )  yborn_1_2                    i.gender i.country                                                         , first robust
                                                                   outreg2    using  ADL_IV.xls, excel append
xi: ivreg2 antiisraelindex ( antisemiticindex = yborn_1 )  yborn_1_2                    i.gender i.country   i.religion                                            , first robust
                                                                   outreg2    using  ADL_IV.xls, excel append
xi: ivreg2 antiisraelindex ( antisemiticindex = yborn_1 )  yborn_1_2                    i.gender i.country   i.religion  i.income                                  , first robust
                                                                   outreg2    using  ADL_IV.xls, excel append
xi: ivreg2 antiisraelindex ( antisemiticindex = yborn_1 )  yborn_1_2                    i.gender i.country   i.religion  i.income   i.common   i.immigrants        , first robust
                                                                   outreg2    using  ADL_IV.xls, excel append
xi: ivreg2 antiisraelindex ( antisemiticindex = yborn_1 )  yborn_1_2                    i.gender i.country   i.religion  i.income   i.common   i.immigrants        , first robust
                                                                   outreg2    using  ADL_IV.xls, excel append


xi: ivreg2 anti_israel_factor_1 ( anti_jews_factor_1 = yborn_1 )                               i.gender i.country                                                         , first robust
                                                                   outreg2    using  ADL_IV.xls, excel append
xi: ivreg2 anti_israel_factor_1 ( anti_jews_factor_1 = yborn_1 )  yborn_1_2                    i.gender i.country                                                         , first robust
                                                                   outreg2    using  ADL_IV.xls, excel append
xi: ivreg2 anti_israel_factor_1 ( anti_jews_factor_1 = yborn_1 )  yborn_1_2                    i.gender i.country   i.religion                                            , first robust
                                                                   outreg2    using  ADL_IV.xls, excel append
xi: ivreg2 anti_israel_factor_1 ( anti_jews_factor_1 = yborn_1 )  yborn_1_2                    i.gender i.country   i.religion  i.income                                  , first robust
                                                                   outreg2    using  ADL_IV.xls, excel append
xi: ivreg2 anti_israel_factor_1 ( anti_jews_factor_1 = yborn_1 )  yborn_1_2                    i.gender i.country   i.religion  i.income   i.common   i.immigrants        , first robust
                                                                   outreg2    using  ADL_IV.xls, excel append
xi: ivreg2 anti_israel_factor_1 ( anti_jews_factor_1 = yborn_1 )  yborn_1_2                    i.gender i.country   i.religion  i.income   i.common   i.immigrants        , first robust
                                                                   outreg2    using  ADL_IV.xls, excel append


											   

********************************************************************************																																		  
*   Bonus Table 
********************************************************************************		
																   
xi: ivreg2 antiisraelindex ( antisemiticindex = yborn )                               i.gender i.country                                                         , first robust
                                                                   outreg2    using  ADL_IV_age.xls, excel replace
xi: ivreg2 antiisraelindex ( antisemiticindex = yborn )                               i.gender i.country   i.religion                                            , first robust
                                                                   outreg2    using  ADL_IV_age.xls, excel append
xi: ivreg2 antiisraelindex ( antisemiticindex = yborn )                               i.gender i.country   i.religion  i.income                                  , first robust
                                                                   outreg2    using  ADL_IV_age.xls, excel append
xi: ivreg2 antiisraelindex ( antisemiticindex = yborn )                               i.gender i.country   i.religion  i.income   i.common   i.immigrants        , first robust
                                                                   outreg2    using  ADL_IV_age.xls, excel append
xi: ivreg2 antiisraelindex ( antisemiticindex = yborn )                               i.gender i.country   i.religion  i.income   i.common   i.immigrants        , first robust
                                                                   outreg2    using  ADL_IV_age.xls, excel append


xi: ivreg2 anti_israel_factor_1 ( anti_jews_factor_1 = yborn )                               i.gender i.country                                                         , first robust
                                                                   outreg2    using  ADL_IV_age.xls, excel append
xi: ivreg2 anti_israel_factor_1 ( anti_jews_factor_1 = yborn )                               i.gender i.country   i.religion                                            , first robust
                                                                   outreg2    using  ADL_IV_age.xls, excel append
xi: ivreg2 anti_israel_factor_1 ( anti_jews_factor_1 = yborn )                               i.gender i.country   i.religion  i.income                                  , first robust
                                                                   outreg2    using  ADL_IV_age.xls, excel append
xi: ivreg2 anti_israel_factor_1 ( anti_jews_factor_1 = yborn )                               i.gender i.country   i.religion  i.income   i.common   i.immigrants        , first robust
                                                                   outreg2    using  ADL_IV_age.xls, excel append
xi: ivreg2 anti_israel_factor_1 ( anti_jews_factor_1 = yborn )                               i.gender i.country   i.religion  i.income   i.common   i.immigrants        , first robust
                                                                   outreg2    using  ADL_IV_age.xls, excel append

																   
																   
		


***************************************************************************************************************************************************************************
*                                                                     FIGURES
***************************************************************************************************************************************************************************





global STARTER = 8
global FIGNUMBER = $STARTER
global TITLE_1     "Figure $FIGNUMBER:  Views on Israel by Views on Jews"
global SUB_TITLE_1 "ADL Survey 2004"
global LEFT_TITLE  "Anti-Israel Index"
global XTITLE      "Antisemitism Index"

graph bar (mean) antiisraelindex   , over( antisemiticindex , label(labsize(vsmall)))  yscale(range(0 2)) ylabel(0.5(0.5)2)    ytitle("$LEFT_TITLE", size(small))      title("$TITLE_1", size(automatic)) subtitle("$SUB_TITLE_1", size(small))  caption("Notes: The sample includes Christians or Non-Affiliated individuals", size(tiny)) blabel(total, size(vsmall) format(%9.2f))   b1title($XTITLE)
graph save Graph "Figure_$FIGNUMBER", replace



global FIGNUMBER = $FIGNUMBER + 1
global TITLE_1     "Figure $FIGNUMBER:  Views on Jews by Birth Cohort"
global SUB_TITLE_1 "ADL Survey 2004"
global LEFT_TITLE  "Antisemitic Index"
global XTITLE      "Birth Cohort"

graph bar (mean) antisemiticindex  , over(yborn, label(labsize(vsmall)))  yscale(range(1 5)) ylabel(1(1)5)    ytitle("$LEFT_TITLE", size(small))      title("$TITLE_1", size(automatic)) subtitle("$SUB_TITLE_1", size(small))  caption("Notes: The sample includes Christians or Non-Affiliated individuals", size(tiny)) blabel(total, size(vsmall) format(%9.2f))   b1title($XTITLE)
graph save Graph "Figure_$FIGNUMBER", replace







   