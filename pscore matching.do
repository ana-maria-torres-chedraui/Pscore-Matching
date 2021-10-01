

cd "C:\Users\t_ana\OneDrive\Documents\Ana Maria\PPA\Final assignment"

capture log close
log using "logs/finalassignment.log", replace
set more off

use "input/CashTransferProgramme", clear
describe
sum 
count

**** Formating variables********
rename treatment Treatment
recode Treatment (1=1 "Treatment") (0=0 "Non-treatment"), gen(treatment)
lab var treatment "=1 if the household is in treatment group"

rename female_headed_baseline Female_headed_baseline
recode Female_headed_baseline (1=1 "Female-headed") (0=0 "Non-female-headed"), gen(female_headed_baseline)
lab var treatment "=1 if the household is female-headed"

**** TARGETING CHARACTERISTICS******
asdoc sum asset_index_baseline unemployed_baseline children_baseline hh_highest_edu_baseline rural_baseline female_headed_baseline hhsize_baseline parents_alive_baseline, by(treatment) format(%3.2f) title(Targeting Characteristics) save(targeting_characteristics.doc), replace

graph bar (mean) asset_index_baseline unemployed_baseline children_baseline hh_highest_edu_baseline rural_baseline female_headed_baseline hhsize_baseline parents_alive_baseline, over(treatment) asyvars subtitle(Targeting Characteristics) blabel(bar, position(upper) format(%5.2f)) legend(label(1 "Asset Index") label(2 "Unemployment") label(3 "Children") label(4 "HH Highest Educ") label(5 "Rural") label(6 "Female Headed") label(7 "HH Size") label(8 "Parents Alive"))
save "Graphs/Targeting_characteristics.gph", replace

* THere seems to be a good targeting. The program was implemented to the most vulnerable gorup


***** DETERMINING WHO THE POOREST ARE

gen pov_line_abs_2014= 25
*Absolute poverty line in 2014: 1.25 USD dollars
** Exchange rate of Honduran Lempira to USD dollars in 2018: 1HNL --> 0.05 USD dollars.
* Source: https://freecurrencyrates.com/en/exchange-rate-history/HNL-USD/2014/yahoo

gen pcc_2014=consumption_baseline/hhsize_baseline 
lab var pcc "annual per capita consumption 2014"
gen pcc_day_2014=pcc_2014/365
label var pcc_day_2014 "household consumption per capita per day"

*Poverty headcount
gen headcount_abs_2014=0
replace headcount_abs_2014=1 if pcc_day_2014<pov_line_abs_2014
lab var headcount_abs_2014 "absolute poverty headcount"
recode headcount_abs_2014 (1=1 "Poor") (0=0 "Non-poor"), gen (Headcount_abs_2014)

asdoc mean Headcount_abs_2014, over(treatment) title(Headcount absolute poverty 2014 over treatment group) save(headcount_abs_2014.doc), replace

graph bar (mean) Headcount_abs_2014, over(treatment) asyvars subtitle(Absolute Poverty Headcount by treatment group) blabel(bar, position(upper) format(%5.4f))
save "Graphs/Headcount Absolute Poverty by Treatment group.gph"



************THE EFFECT OF THE PROGRAM PARTICIPATION ON THE OUTCOME VARIABLES *********
********** 1. CONSUMPTION *********************

* Simple regression 
reg consumption treatment, r
outreg2 using "PPA.doc", bdec(2) word replace

// The coefficient on treatment is positive and statistically significant at all significant levels. It can be interpreted as follows: If the household is in the treatment group, the estimated consumption is  83.63 units higher than the non-treatment group


* Controlling for other factors
reg consumption treatment hhsize_baseline rural_baseline hh_highest_edu_baseline asset_index_baseline  unemployed_baseline consumption_baseline parents_alive_baseline hhsize_baseline female_headed_baseline, r
outreg2 using "PPA.doc", bdec(2) word append

 mother_working 


// I have included as covariates those that empirical studies have determined important to evaluate the impact on poverty. (Sumarto et al. 2007) (Lanjouw & Ravallion 1995) 
//The coefficient on treatment has decreased but it is still positive and statistically significant at all significant levels. It can be interpreted as follows: holding all else constant, if the household is in the treatment group, the estimated consumption is 31.31 units higher than the non-treatment group.

// All seems to point out that the estimated consumption has increased in the treatment group after the treatment. 


********** 2. EMPLOYABILITY OF THE MOTHER********************

* Tabulate mean employment status of the mother by treatment
tab treatment mother_working, row

//24.29% of the mothers in the treatment group are working while 27.82% of the mothers in the non-treatment group are working. 

reg mother_working treatment, r
outreg2 using "PPA2.doc", bdec(2) word replace

// The coefficient of treatment is statistically significant at 10% significant level and it is negative, meaning that if the household is in the treatment group, the probability that the mother is working is 3.53 percentage points less than households in the non-treatment group. 

* Controlling for other factors

reg mother_working treatment unemployed_baseline children_baseline hh_highest_edu_baseline rural_baseline asset_index_baseline hhsize_baseline consumption age, r
outreg2 using "PPA2.doc", bdec(2) word append


// I included as covariates what empirical studies consider important to determine the employability of the mother. For example: human capital(education, work experience), personal and family characteristics: number of children, marital status, income. (Higley 1997, Song 2015). 

// After controlling for other factors, the coefficient on treatment is now statistically significant at 5% significant level. However, it keeps being negative, which means that: holding all else constant, if the household is in the treatment group, the probability that the mother is working is 5.41 percentage points less than households in the non-treatment group. 

probit mother_working treatment, r
margins, dydx (treatment)
outreg2 using "PPA2.doc", bdec(2) word append

probit mother_working treatment unemployed_baseline children_baseline hh_highest_edu_baseline rural_baseline asset_index_baseline hhsize_baseline consumption_baseline, r
margins, dydx (treatment)
outreg2 using "PPA2.doc", bdec(2) word append

//Using the probit model, the coefficient on treatment is still negative and statistically significant at 5% significant level although it is slighly smaller than the one calculated using the linear probability model: holding all else constant, if the household is in the treatment group, the probability that the mother is working is 5.03 percentage points less than households in the non-treatment group. 

// Everything points towards a negative impact of the program on the employability of the mother.


********** 3. SCHOOL PERFORMANCE OF YOUNGEST CHILD**********

bysort treatment: sum(math_score)

//Those that are in the treatment group have an average math score of -0.02 which is better than the average of the non-treatment group -0.08. The maximum grade of non-treatment group (1.99) is though higher than the max of treatment group (1.63). However, the minimum grade of the non-treatment group (-1.23) is lower than that of the treatment group (-1.01)

reg math_score treatment, r
outreg2 using "PPA3.doc", bdec(2) word replace

// The coefficient of treatment is positive and statistically significant at 1% significant level and can be interpreted as follows: If the household is in the treatment group, the math score of the youngest child is  0.061 points higher than the non-treatment group


* Controlling for other factors


reg math_score treatment hh_highest_edu_baseline education_att_baseline science_score_baseline consumption_baseline asset_index_baseline education_att depression_index hope_index, r
outreg2 using "PPA3.doc", bdec(2) word append

// I included as covariates all what -according to empirical studies- could impact on  school performance. (see Moreira el al 2013)
// After controlling for other factors, the coefficient on treatment is now negative and statistically significant at all significant levels. It can be interpreted as follows: holding all else constant, if the household is in the treatment group, the math score of the youngest child is  0.04 points lower than the non-treatment group


*****************PROPENSITY SCORE MATCHING*******************
*The compared group already exists and it has been called "non-treatment group", but I cannot be sure if it is comparable to the treatment group, that is why I will use the PSM to create a control group that has similar characteristics to the households in the treatment group.

/*
Propensity score matching consists of three steps: 
STEP 3.1. Estimate a binary model of program participation 
STEP 3.2. Define the region of common support 
STEP 3.3. Match participants and non participants and evaluate the impact of the programme
*/

********************************************************************************
* STEP 3.1. Estimate a binary model of program participation
********************************************************************************
// Many combinations of variables are possible. I will observe two requirements to choose the appropriate balanced combination: 1. variable should be unaffected by the program; and 2. "variables that influence simultaneously the participation decision and the outcome variable" (p.6)

*Targeting process: Poor + with children + unemployed

pscore treatment asset_index_baseline hh_highest_edu_baseline rural_baseline children_baseline unemployed_baseline female_headed_baseline hhsize_baseline parents_alive_baseline, pscore(ps1) blockid(block) comsup
*The final number of blocks is 6

pstest asset_index_baseline hh_highest_edu_baseline rural_baseline children_baseline unemployed_baseline female_headed_baseline hhsize_baseline parents_alive_baseline, t(treatment) sup(comsup) mweight(ps1) rub graph both


* We see that the bias has been reduced after matching. The mean bias of matched variables is 1.6 which is lower than 5, meanning that this is a good result. 
*The graph shows that the bias of the matched variables is close to 0, while those that are unmatched are further away from 0. This shows that the matching has done a good work at reducing bias in the variables. 
//The balancing property is satisfied. The targeting characteristics have been used to match the treatment group with a control group.

probit treatment asset_index_baseline hh_highest_edu_baseline rural_baseline children_baseline unemployed_baseline female_headed_baseline hhsize_baseline parents_alive_baseline, r
predict probit_reg


********************************************************************************
* STEP 3.2. Define the region of common support  
********************************************************************************

histogram ps1, by(treatment, col(1))
graph save "graphs/Histogram_CSA.gph", replace

ssc install psmatch2, replace
psgraph, treated (treatment) pscore(ps1) title("Common Support Area")
graph save "graphs/Common_Support_Area.gph", replace
* the common support area: the overlap of the distribution of treated and not treated
* There are bins on both groups treated and non-treated. The common support extends to almost all the area covered by the pscore. There is a very good coverage of the propensity score.


********************************************************************************
* Visualize the distribution of the propensity score for the two groups (treated and non treated)
********************************************************************************
twoway (kdensity ps1 if treatment==1) (kdensity ps1 if treatment==0), legend(order(1 "propensity score treated" 2 "propensity score non treated")) title("Kernel Density Propensity Score")
graph save "graphs/Histogram_Kdensity.gph", replace

graph combine "graphs/Histogram_CSA.gph" "graphs/Common_Support_Area.gph" "graphs/Histogram_Kdensity.gph", title("Common Support Area") scale(0.7) 

** This last graph confirms what it was shown before: there is a very good common support for the area covered by the pscore. Almost the whole treatment group is covered by the non-treatment group, except for the very latest tail (0.2370-0.2405). This is the only part of the treatment group that is not covered by the non-treatment group. This can be checked using the following command:
asdoc sum(ps1) if treatment==1 & block==6 & comsup==1, title(Common Support area) save(common_support_area.doc), replace
asdoc sum(ps1) if treatment==0 & block==6 & comsup==1, title(Common Support area) save(common_support_area.doc), append


* STEP 3.3. Match participants and non participants and evaluate the impact of the programme
********************************************************************************
	
***************** NEAREST NEIGHBOUR MATCHING

asdoc attnd consumption treatment, pscore(ps1) comsup title(ATT Consumption using Nearest Neighbour Matching) save(NNM.doc), replace
//The ATT is 105.798  and the t-score is 9.494 This suggests that the programme has a positive effect on HH consumption, and this is statistically significant at even 0.1% significance level: 9.494>3.29.

asdoc attnd mother_working treatment, pscore(ps1) comsup title(ATT Mother Working using Nearest Neighbour Matching) save(NNM.doc), append
//The ATT is -0.074 and the t-score is -2.448. This suggests that the programme has a negative effect on the employment status of the mother, and this is statistically significant at 2% significance level: -2.448>-2.326.
 
asdoc attnd math_score treatment, pscore(ps1) comsup radius(0.01) title(ATT Math Score using Nearest Neighbour Matching) save(NNM.doc), append
// The ATT is 0.052 and the t-score is 1.756. This suggests that the programme has a positive effect on children school performance, and this is statistically significant at 10% significance level: 1.756>1.645.


********************************************************************************
* TASK 3: Reflect on the difference between the results from the matching and the regression results
********************************************************************************

* Simple regression 
reg consumption treatment, r level(99.9)
//The effect of treatment on consumption is positive and statistically significant at 0.1% significance level.

reg mother_working treatment, r level(90)
// The effect of treatment on the employability of the mother is negative and it is statistically significant at 10% significance level.

reg math_score treatment, r level(99.5)
// The effect of treatment on children's school performance is positive and statistically significant at 0.5% significance level.

********************************************************************************
* TASK 4. Robustness: test your data using various matching methods and specifications
********************************************************************************

* To account for the robustness of your results, you conduct alternative matching methods (e.g. atts, attr, attk)

**************** STRATIFICATION MATCHING

asdoc atts consumption treatment, pscore(ps1) blockid(block) comsup title(ATT Consumption using Stratification Matching) save(consumption_SM.doc), replace
// The ATT is 97.494 and the t-score is 12.434. This suggests that the programme has a positive effect on HH consumption,  and this is statistically significant at even 0.1% significance level: 12.434>3.29.

asdoc atts mother_working treatment, pscore(ps1) blockid(block) comsup title(ATT Mother Working using Stratification Matching) save(mother_working_SM.doc), replace
// The ATT is  -0.063 and the t-score is -2.969. This suggests that the programme has a negative effect on the employability of the mother, and this is statistically significant at 0.5% significance level: -2.969>-2.807.

asdoc atts math_score treatment, pscore(ps1) blockid(block) comsup radius(0.01) title(ATT Math Score using Stratification Matching) save(math_score_SM.doc), replace
// The ATT is 0.059 and the t-score is 2.827. This suggests that the programme has a positive effect on children's school performance. This effect is statistically significant at 0.5% significance level: 2.827>2.807.


**************** RADIUS MATCHING

asdoc attr consumption treatment, pscore(ps1) comsup title(ATT Consumption using Radius Matching) save(consumption_RM.doc) replace
// The ATT is 90.380 and the t-score 11.432. This suggests that the programme has a positive effect on hh consumption. This effect is statistically significant even at 0.1% significant level (11.432>3.29).

asdoc attr mother_working treatment, pscore(ps1) comsup title(ATT Mother Working using Radius Matching) save(mother_working_RM.doc) replace
//The ATT is -0.041 and the t-value is -1.97. This suggests that the programme has a negative effect on the employability of the mother and this effect is statistically significant at 5% significance level -1.97>-1.96.

attr math_score treatment, pscore(ps1) comsup radius(0.01) title(ATT Math Score using Radius Matching) save(math_score_RM.doc) replace
// The ATT is 0.062 and the t-value is 2.549. This suggests that hte programme has a positive effect on the math score of children. This effect is statistically significant at 2% significant level 2.549>2.326


************* KERNEL MATCHING

asdoc attk consumption treatment, pscore(ps1) comsup bootstrap reps(100) title(ATT Consumption using Kernel Matching) save(consumption_KM.doc), replace
// The ATT is  94.004  and the t-score 10.96. This suggests that the programme has a positive effect on hh consumption. This effect is statistically significant even at 0.1% significant level (10.96>3.291).

asdoc attk mother_working treatment, pscore(ps1) comsup bootstrap reps(100) title(ATT Mother working using Kernel Matching) save(mother_working_KM.doc), replace
//The ATT is -0.048 and the t-value is -2.295. This suggests that the programme has a negative effect on the employability of the mother. This effect is statistically significant at 98% significant level -2.295>-2.326.

asdoc attk math_score treatment, pscore(ps1) comsup bootstrap reps(100) title(ATT Math Score using Kernel Matching) save(math_score_KM.doc), replace
// The ATT is  0.059  and the t-value is 2.8. This suggests that the programme has a positive effect on children's school performance. This effect is statistically significant at 1% significant level: 2.8>2.58.


************HETEROGENOUS IMPACT: OUTCOME CONSUMPTION *********************
************ IMPACT OF THE PROGRAMME BY CONSUMPTION QUINTILES
sum consumption
codebook consumption
xtile quintile = consumption, nquantiles(5)
bysort quintile: sum(consumption)
graph bar (mean) consumption, over(quintile) asyvars subtitle(Consumption distribution by quintiles)blabel(bar, position(upper) format(%7.2f)) legend(label(1 "First Quintile") label(2 "Second Quintile") label(3 "Third Quintile") label(4 "Fourth Quintile") label(5 "Fifth Quintile"))
save "Graphs/Consumption by Quintiles.gph", replace

asdoc attnd consumption treatment if quintile==1, pscore(ps1) comsup title(ATT Consumption First Quintile) save(consumption_quintile.doc) replace
asdoc attnd consumption treatment if quintile==2, pscore(ps1) comsup title(ATT Consumption Second Quintile) save(consumption_quintile.doc) append
asdoc attnd consumption treatment if quintile==3, pscore(ps1) comsup title(ATT Consumption Third Quintile) save(consumption_quintile.doc) append
asdoc attnd consumption treatment if quintile==4, pscore(ps1) comsup title(ATT Consumption Fourth Quintile) save(consumption_quintile.doc) append
asdoc attnd consumption treatment if quintile==5, pscore(ps1) comsup title(ATT Consumption Fifth Quintile) save(consumption_quintile.doc) append
*** the program did not have a positive impact for the poorest

************ CONSUMPTION IN FEMALE HEADED HOUSEHOLDS ********
bysort female_headed_baseline: sum(consumption)
graph bar (mean) consumption, over(female_headed_baseline) over (quintile) asyvars subtitle(Consumption distribution by quintile and female-headed household) 
save "Graphs/Consumption by Quintiles and Female-Headed.gph", replace

bysort female_headed_baseline: sum(consumption) if quintile==1
bysort female_headed_baseline: sum(consumption) if quintile==2
bysort female_headed_baseline: sum(consumption) if quintile==3
bysort female_headed_baseline: sum(consumption) if quintile==4
bysort female_headed_baseline: sum(consumption) if quintile==5
* Consumption per quantile did not vary based on whether the household was or not female-headed. However, when applied the NNM, there is a difference. Female-headed households have a larger increase in consumption than non-female headed households


asdoc attnd consumption treatment if female_headed_baseline==1, pscore(ps1) comsup title(ATT NNM Consumption in Female Headed households) save(consumption_femaleheaded.doc), replace

asdoc attnd consumption treatment if female_headed_baseline==0, pscore(ps1) comsup title(ATT NNM Consumption in Non-Female Headed households) save(consumption_femaleheaded.doc), append

* The increment of consumption is bigger in female_headed households



*******DOES THE CASH TRANSFER BRING PEOPLE OUT OF POVERTY?

***************************************************
gen pov_line_abs_2018= 45.24
*Absolute poverty line: 1.90 USD dollars
* Exchange rate of Honduran Lempira to USD dollars in 2018: 1HNL --> 0.042 USD dollars.
*Source: https://freecurrencyrates.com/en/exchange-rate-history/HNL-USD/2018/yahoo
gen pcc_2018=consumption/hhsize_baseline 
lab var pcc "annual per capita consumption 2018"
gen pcc_day_2018=pcc_2018/365
label var pcc_day_2018 "household consumption per capita per day 2018"

*Poverty headcount
gen headcount_abs_2018=0
replace headcount_abs_2018=1 if pcc_day_2018<pov_line_abs_2018
lab var headcount_abs_2018 "absolute poverty headcount 2018"
recode headcount_abs_2018 (1=1 "Poor") (0=0 "Non-poor"), gen (Headcount_abs_2018)

asdoc tab Headcount_abs_2018, title(Headcount absolute poverty 2018) save(headcount_abs_2018.doc), replace

* Absolute Poverty gap
gen pov_gap_abs_2018=0
replace pov_gap_abs_2018=pov_line_abs_2018-pcc_day_2018 if pcc_day_2018<pov_line_abs_2018
lab var pov_gap_abs_2018 "absolute poverty gap 2018"
sum pov_gap_abs_2018

* Absolute Poverty index
gen pov_gapindex_abs_2018=0
replace pov_gapindex_abs_2018=pov_gap_abs_2018/pov_line_abs_2018 if pcc_day_2018<pov_line_abs_2018
lab var pov_gapindex_abs_2018 "absolute poverty gap index 2018"
sum pov_gapindex_abs_2018

asdoc sum pov_gapindex_abs_2018, title(Poverty Gap Index Absolute Poverty 2018) save(poverty_gapindex_abs_2018.doc), replace

* Absolute Poverty severity 
gen pov_sev_abs_2018=(pov_gapindex_abs_2018)^2
lab var pov_sev_abs_2018 "absolute poverty severity 2018"

* NEAREST NEIGHBOUR MATCHING POVERTY
asdoc attnd Headcount_abs treatment, pscore(ps1) comsup title(ATT Absolute Poverty Headcount using Nearest Neighbour Matching) save(Poverty_NNM.doc), replace
* Poverty Headcount was not reduced and it is not statistically significant
asdoc attnd pov_gap_abs treatment, pscore(ps1) comsup title(ATT Absolute Poverty Gap using Nearest Neighbour Matching) save(Poverty_NNM.doc), append
* The poverty gap reduction is not statistically significant


***********SHARE OF POOR BY CONSUMPTION QUINTILE ********
asdoc attnd Headcount_abs treatment if quintile==1, pscore(ps1) comsup title(ATT Absolute Poverty Headcount of First Consumption Quintile using Nearest Neighbour Matching) save(poverty_headcount_1_5.doc), replace

asdoc attnd Headcount_abs treatment if quintile==5, pscore(ps1) comsup title(ATT Absolute Poverty Headcount of Fifth Quintile using Nearest Neighbour Matching) save(poverty_headcount_5_5.doc), replace

asdoc attnd pov_gapindex_abs treatment if quintile==1, pscore(ps1) comsup title(ATT Absolute Poverty Gap Index of First Quintile using Nearest Neighbour Matching) save(poverty_gapindex_1_5.doc), replace

asdoc attnd pov_gapindex_abs treatment if quintile==5, pscore(ps1) comsup title(ATT Absolute Poverty Gap Index of Fifth Quintile using Nearest Neighbour Matching) save(poverty_gapindex_5_5.doc), replace

asdoc attnd pov_sev_abs treatment if quintile==1, pscore(ps1) comsup title(ATT Absolute Poverty Gap Index of First Quintile using Nearest Neighbour Matching) save(poverty_gapindex_1_5.doc), replace

asdoc attnd pov_sev_abs treatment if quintile==5, pscore(ps1) comsup title(ATT Absolute Poverty Gap Index of Fifth Quintile using Nearest Neighbour Matching) save(poverty_gapindex_5_5.doc), replace

*** POVERTY AND HOUSEHOLD SIZE
bysort quintile: sum hhsize_baseline
graph bar hhsize_baseline, over(quintile)

corr hhsize_baseline quintile
corr hhsize_baseline consumption
 * There is no high correlation between poverty and hhsize

 
************HETEROGENOUS IMPACT: OUTCOME SCHOOL PERFORMANCE
 *********************
 * BY CONSUMPTION QUINTILES
 
asdoc attnd math_score treatment if quintile==1, pscore(ps1) comsup title(ATT Math Score First Quintile) save(math_score_quintile.doc) replace
asdoc attnd math_score treatment if quintile==2, pscore(ps1) comsup title(ATT Math Score Second Quintile) save(math_score_quintile.doc) append
asdoc attnd math_score treatment if quintile==3, pscore(ps1) comsup title(ATT Math Score Third Quintile) save(math_score_quintile.doc) append
asdoc attnd math_score treatment if quintile==4, pscore(ps1) comsup title(ATT Math Score Fourth Quintile) save(math_score_quintile.doc) append
asdoc attnd math_score treatment if quintile==5, pscore(ps1) comsup title(ATT Math Score Fifth Quintile) save(math_score_quintile.doc) append
 
 
 * BY FEMALE-HEADED HOUSEHOLDS
 *May the outcome differ if transfers were made to mothers?? Female-headed households****
 
asdoc attnd math_score treatment if female_headed_baseline==1, pscore(ps1) comsup radius(0.01) title(ATT NNM Math Score in female-headed households) save(math_score_NNM.doc), replace
 
asdoc attnd math_score treatment if female_headed_baseline==0, pscore(ps1) comsup radius(0.01) title(ATT NNM Math Score in non-female headed households) save(math_score_NNM.doc), append
 
* The impact of the program on math score is negative on female headed households. The result is not statistically significant. 
* it can be that female-headed families experience more burden as there is only one source of income. Sending then a child to school may be more costly for this sort of households.

 
 
 ************HETEROGENOUS IMPACT: OUTCOME MOTHER WORKING*************
* CONSUMPTION QUINTILE 
 asdoc attnd mother_working treatment if quintile==1, pscore(ps1) comsup title(ATT NNM Mother Working First Quintile) save(mother_working_NNM.doc), replace
  asdoc attnd mother_working treatment if quintile==2, pscore(ps1) comsup title(ATT NNM Mother Working Second Quintile) save(mother_working_NNM.doc), append
   asdoc attnd mother_working treatment if quintile==3, pscore(ps1) comsup title(ATT NNM Mother Working Third Quintile) save(mother_working_NNM.doc), append
    asdoc attnd mother_working treatment if quintile==4, pscore(ps1) comsup title(ATT NNM Mother Working Fourth Quintile) save(mother_working_NNM.doc), append
    asdoc attnd mother_working treatment if quintile==5, pscore(ps1) comsup title(ATT NNM Mother Working Fifth Quintile) save(mother_working_NNM.doc), append
	
 * THe poorest the more the negative impact on mother working.
 
 * FEMALE-HEADED HOUSEHOLD
 
asdoc attnd mother_working treatment if female_headed_baseline==1, pscore(ps1) comsup title(ATT NNM Employability of the Mother in female-headed households) save(mother_working_NNM2.doc), replace
 
asdoc attnd mother_working treatment if female_headed_baseline==0, pscore(ps1) comsup title(ATT NNM Employability of the Mother in female-headed households) save(mother_working_NNM2.doc), append

bysort quintile: sum hh_highest_edu_baseline
graph bar hh_highest_edu_baseline, over(quintile)
*** Not much of a difference of highest education accorss quintiles
