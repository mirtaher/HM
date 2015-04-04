//Mohsen Mirtaher 6 Mar 2015

capture log close
cd "/Users/Mohsen/Desktop/HM"
log using hm-data01.log, replace text 

version 13
clear all
macro drop _all
set linesize 80

// hm_1 contains sex, age, race, education (highest grade completed,
// Hs diploma, and change in schooling), and marital history 
// (chanage in marital status, 1st, 2nd, 3rd change in ms and their dates)
// hm_2 adds on top of that the 40+ and 5+ modules and some late health variables
// and outcomes in 2012. plus the weight data
// hm_3 adds many binary health problems from 40+ module 

import delimited "/Users/Mohsen/Desktop/HM/hm_3.csv"
rename r* R*
rename t* T*
rename h* H*
do "/Users/Mohsen/Desktop/HM/hm_3-value-labels.do"


/////////////////////////////////////////////////////////////////

* Variables Label 

* 1979 specific variables

local l_ms        "Marital status" 
local l_num_m1979 "Number of marriges in 1979"
local l_fms_m1979 "Month of 1st marrige start"
local l_fms_y1979 "Year of first marriage start"
local l_fme_m1979 "Month of first marriage end"
local l_fme_y1979 "Year of first marriage end"
local l_rms_m1979 "Most recent marriage start month"
local l_rms_y1979 "Most recent marriage start year"
local l_rme_m1979 "Most recent marriage end month"
local l_rme_y1979 "Most recent marriage end year"
local l_race      "Race" 
local l_sex       "Sex"
local l_id        "Identification code"


* Typical variables post 1979 for education and marital status

local l_chm "Change in Marital Status since DLI"

local l_Fchm "First Change in Marital Status since DLI"
local l_Schm "Second Change in Marital Status since DLI"
local l_Tchm "Third Change in Marital Status since DLI"

local l_Fchm_m "Month of First change in MS"
local l_Fchm_y "Year of First change in MS"

local l_Schm_m "Month of Second change in MS"
local l_Schm_y "Year of Second change in MS"

local l_Tchm_m "Month of Third change in MS"
local l_Tchm_y "Year of Third change in MS"

local l_chs "Change in schooling since DLI"

local l_hg "Highest grade completed"

local l_hsd "High school diploma"


///////////////////////////////////////////////////////////////

* Reordering data

// Moving race and sex and age to the top of the list 
order R0214700 R0214800 R0650100, after(R0000100) 

// Moving XRND variables after demographics 
order H0001101-H0015900, after(R0650100) 



// Moving the available weights after XRND health variables 
order R0481700 R0779900 R2141300 R2711500 R2959600 ///
R3271000 R3886400 R4284800 R4962000 R5617500 R6344500 R6888100 ///
R7598500 R8298300 T0897300 T2053800 T3024700 T3955000, after(H0015900)


// Moving 2010 Health behavior and health outcome variables 
// after weight2012
order T3027300 T3955100 T3955200 T3973800 T3975100, after(T3955000)


// moving education variables to the ususal order for 1998
order R5821100 R5821800 R5822200, after(R6467501)

//////////////////////////////////////////////////////////////
* Renaming 1979 and XRND variables 

rename R0000100 id
rename R0650100 age82
rename R0214700 race
rename R0214800 sex
rename R0010600 ms1979
lab var ms1979 "marital status"
rename R0010700 num_m1979
lab var num_m1979 "Number of marriages"
rename R0010800 fms_m
lab var fms_m "Month of First marriage"
rename R0010900 fms_y
lab var fms_y "Year of First marriage"
rename R0011000 fme_m 
lab var fme_m "Month of First marriage end"
rename R0011100 fme_y 
lab var fme_y  "Year of first marriage end"
rename R0011200 rms_m
lab var rms_m  "Most Recent marriage start month"
rename R0011300 rms_y 
lab var rms_y "Most recent marriage start year"
rename R0012500 rme_m 
lab var rme_m  "Most recent marriage end month"
rename R0012600 rme_y
lab var rme_y "Most recent marraige end year"
rename R0017300 hg1979
lab var hg1979 "Highest grade completed by 1979"
rename R0018200 hsd1979
lab var hsd1979 "High school diploma"

* Renaming 40+ and 50+ health module variables 
rename H0001101 cesd7_c
lab var cesd7_c "7-Item CES-D score categorized"
rename H0001102 cesd7
lab var cesd7  "7-Item CES-D score"
rename H0003200 sf_12_phs_40
lab var sf_12_phs_40 "SF-12 Score Physical at age 40"
rename H0003300 sf_12_mnt_40
lab var sf_12_mnt_40 "SF-12 Score Mental at age 40"
rename H0003400 sf_slf_hlt_40
lab var sf_slf_hlt_40 "SF-12 self assessed and reported health at age 40"
rename H0004600 ccr_bp_40
lab var ccr_bp_40 "CCR- Doctor ever disgnosed High Blood Pressure at 40"
rename H0004900 ccr_db_40
lab var ccr_db_40 "CCR Doctor ever disgnosed Diabetes at 40"
rename H0005100 ccr_cr_40
lab var ccr_cr_40 "CCR Doctor ever disgnosed cancer at 40"
rename H0006000 ccr_hp_40
lab var ccr_hp_40 "CCR Doctor ever disgnosed Heart problems at 40"
rename H0007200 ccr_ar_40
lab var ccr_ar_40 "CCR Doctor ever disgnosed Arithritis at 40"
rename H0013201 year_50
lab var year_50 "Source year for 50+ module"
rename H0015801 sf_12_phs_50
lab var sf_12_phs_50 "SF-12 Score Physical at age 50"
rename H0015802 sf_12_mnt_50
lab var sf_12_mnt_50 "SF-12 Score Mental at age 50"
rename H0015900 sf_slf_hlt_50
lab var sf_slf_hlt_50 "SF-12 self assessed and reported health at age 50"

* H0007600-H0010800 CCR health problems 

* Renaming and labeling of weight variables

numlist "1981 1982 1986 1988 1989 1990 1992/1994 1996(2)2012" 
local iw "`r(numlist)'"
local wt "R0481700 R0779900 R2141300 R2711500 R2959600 R3271000 R3886400 R4284800 R4962000 R5617500 R6344500 R6888100 R7598500 R8298300 T0897300 T2053800 T3024700 T3955000"
local wt_n: word count of `wt'
local i 1
foreach var of local wt {
rename `var' wt`i'
local i = `i' +1
}

local i 1
foreach year of local iw{
rename wt`i' wt`year'
local i = `i' +1
}


* Renaming and labeling of late health variables
rename T3027300 rnf2010
lab var rnf2010 "Reading Nutritional Facts Shopping Food"
rename T3955100 htf2012
lab var htf2012 "Height in feet at 2012"
rename T3955200 htin2012
lab var htin2012 "Height in in at 2012"
rename T3973800  chlt2012
lab var chlt2012 "Self assessed childhood health"
rename T3975100 smel2012
lab var smel2012 "Quality of sense of smell"


////////////////////////////////////////////////////////////////

* Renaming education and marital history variables 


*Tokenizing the dataset
qui ds  R0223800-T3213400
local vars "`r(varlist)'"
local n = 13 // number of variables whithin each year 
local T = 24 // number of rounds after 1979
local nT = `n'*`T'
forvalues i = 1/`nT' {
local v: word `i' of `vars'
rename `v' m`i'
}



*Renaming the variables 

numlist "1980/1994 1996(2)2012" 
local iyear "`r(numlist)'"



local iname_b_84 chm Fchm Schm Tchm Fchm_m Fchm_y ///
Schm_m Schm_y Tchm_m Tchm_y chs hg hsd

local iname_84 chm Fchm Fchm_m Fchm_y Schm Schm_m Schm_y Tchm  ///
Tchm_m Tchm_y chs hg hsd

local i 0


foreach var of local iyear {
local lb = `i'*13+1
local ub = (`i'+1)*13
if `var' < 1984 {
renvars m`lb'-m`ub'/ `iname_b_84'
renvars `iname_b_84', postfix(`var')
}
else {
renvars m`lb'-m`ub'/ `iname_84'
renvars `iname_84', postfix(`var')
}
local i = `i' +1
}



* Dealing with missing variables
// XRND and 1979 variables 
recode race-hsd1979 (-1 -2 -3 -4 -5 = .)
recode hg1979 (95 =. )

//Later years variables 
foreach var of local iyear {
recode chm`var' Fchm`var' Schm`var' Tchm`var' Fchm_m`var' Fchm_y`var' ///
Schm_m`var' Schm_y`var' Tchm_m`var' Tchm_y`var' chs`var' hg`var' hsd`var' (-1 -2 -3 -4 -5 = .)
//Ungraded as 95 in hg`var'. So I recode it as missing
recode hg`var' (95 = .)
}


foreach y of local iyear{
foreach var of newlist F S T {
su `var'chm_y`y'
if `r(mean)' < 100{
replace `var'chm_y`y' = 1900 + `var'chm_y`y'
}
}
}

/*
An Alternative way of renaming and labeling variables

local iyear = 1980
local i = 0 
foreach var of varlist R0223800-R0229900 {
local i = `i'+1

if `i' == 1 {
label variable `var' "`l_chs'"
rename `var' chm`iyear'
}
else if `i' == 2 {
label variable `var' "`l_Fchm'"
rename `var' Fchm`iyear'
}
else if `i' == 3 {
label variable `var' "`l_Schm'"
rename `var' Schm`iyear'
}
else if `i' == 4 {
label variable `var' "`l_Tchm'"
rename `var' Tchm`iyear'
}
else if `i' == 5 {
label variable `var' "`l_Fchm_m'"
rename `var' Fchm_m`iyear'
}
else if `i' == 6 {
label variable `var' "`l_Fchm_y'"
rename `var' Fchm_y`iyear'
}
else if `i' == 7 {
label variable `var' "`l_Schm_m'"
rename `var' Schm_m`iyear'
}

else if `i' == 8 {
label variable `var' "`l_Schm_y'"
rename `var' Schm_y`iyear'
}

else if `i' == 9 {
label variable `var' "`l_Tchm_m'"
rename `var' Tchm_m`iyear'
}

else if `i' == 10 {
label variable `var' "`l_Tchm_y'"
rename `var' Tchm_y`iyear'
}

else if `i' == 11 {
label variable `var' "`l_chs'"
rename `var' chs`iyear'
}

else if `i' == 12 {
label variable `var' "`l_hsd'"
rename `var' hsd`iyear'
}


else if `i' == 13 {
label variable `var' "`l_hg'"
rename `var' hg`iyear'
}
}


*/

save hm-data01.dta, replace 
log close 
exit
