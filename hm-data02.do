
capture log close
cd /Users/Mohsen/Desktop/HM
log using hm_data02, replace text 

//Mohsen Mirtaher March 15 2015 

version 13
clear all
macro drop _all
set linesize 80
use hm-data01.dta, clear

numlist "1980/1994 1996(2)2012" 
local iy "`r(numlist)'"



//////////////////////////////////////////////////
// Creating race dummies 

tabulate race, gen (gr)
rename gr1 hispanic 
rename gr2 black 
drop gr3 

// Creating Male dummy

recode sex (2 = 0)
rename sex male 

// Age at 2012 

gen age2012 = age82 + 30 


///////////////////////////////////////////////////
// Creating Health Categories 
tabulate sf_slf_hlt_40, gen(sffo)
rename sffo1 slfH40E
rename sffo2 slfH40V
rename sffo3 slfH40G 
rename sffo4 slfH40F 
rename sffo5 slfH40P

tabulate sf_slf_hlt_50, gen(sffi)  
rename sffi1 slfH50E
rename sffi2 slfH50V
rename sffi3 slfH50G
rename sffi4 slfH50F
rename sffi5 slfH50P


// Creating the number of chronic health problems from 40+ health modules 


* CRC module outcome variables 
local hp H0007600
foreach var of varlist H0007700-H0010800 {
local hp `hp' `var'
}

gen num_chp = 0
lab var num_chp "Number of chronic health problems"
foreach var of local hp {
replace num_chp = num_chp + `var' if !missing(`var')
}

* Common chronic health problems 

local cd  ccr_bp_40
foreach var of varlist ccr_bp_40-ccr_ar_40{
local cd `cd' `var'
}

gen num_cd = 0
lab var num_cd "Number of commom chronic diseases"
foreach var of local cd {
replace num_cd = num_cd + `var' if !missing(`var')
}

* Total number of chronic problems 

gen num_c = num_chp + num_cd 

//////////////////////////////////////////////////////////////
//Creating the education categories 

* First approach: The latest available data

numlist " 2012(-2)1996 1994(-1)1980" 
local iyr "`r(numlist)'"
display `iyr'

local ii 0
gen hgc = . 
foreach y of local iyr {
replace  hgc = hg`y' if  !missing(hg`y') & `ii' == 0 
local ii = `ii' + 1 
}


/* An alternative way of constructing schooling: The maximum expressed data

local hg_ag hg1979
foreach var of local iy {
local hg_ag `hg_ag' hg`var'
}
egen hgc = rowmax(`hg_ag')  

*/


local hsd_ag hsd1979
foreach var of local iy {
local hsd_ag `hsd_ag' hsd`var'
}

egen hsDp = rowmax(`hsd_ag') 


gen col = 1 if hgc > = 16 & !missing(hgc)
replace col = 0 if hgc<16 & !missing(hgc)

gen scl = 0 if !missing(hgc)
replace scl = 1 if (hgc>12) & (hgc<16) & !missing(hgc)

gen hs = hsDp
replace hs = 0 if hsDp==1 & (col ==1 | scl ==1) & !missing(hgc)



///////////////////////////////////////////////////////////////////////
// Calculation of marital state variables: instanteneous and cumulative 


tabulate ms1979, gen(g)
rename g1 mr1979
rename g2 wd1979
gen dv1979 = g3 + g4
rename g5 sg1979
drop g3 g4

** The initial values (1979) of marital stock state variables

* For singles in 1979
foreach var in mr dv wd sg{
gen `var'S1979 = 0
}
replace sgS1979 = 1


* For the continuously married
replace mrS1979 = 1  if missing(fme_y) & ms1979 == 1


* For divorced people 
replace dvS1979 = 1 if num_m1979 == 1 & (ms1979 == 3 |ms1979 == 4) 

* For the remmarried
replace mrS1979 = 2 if num_m1979 == 2 & ms1979 == 1

* For the people with two divorces 
replace dvS1979 = 2 if num_m1979 == 2 & (ms1979 == 3 |ms1979 == 4)

* For people with the third marriage 
replace mrS1979 = 3 if num_m1979 == 3 & ms1979 == 1


foreach var of newlist mr wd dv sg{
gen `var'1978 = . 
gen `var'S1978 = 0
gen `var'S1977 = 0
}

foreach y of local iy{

foreach var of newlist mr wd dv sg{

if `y' <= 1994{
gen `var'`y' = `var'`=`y' - 1'
gen `var'S`y' = `var'S`=`y' - 1'
}
if `y' > 1994 {
gen `var'`y' = `var'`=`y' - 2'
gen `var'`=`y' - 1' = `var'`=`y' - 2'

gen `var'S`y' = `var'S`=`y' - 2'
gen `var'S`=`y' - 1' = `var'S`=`y' - 2'
}

}


foreach round of newlist F S T {

gen `round'diff`y' = `y' - `round'chm_y`y'
local truncation = 2
replace `round'diff`y' = `truncation' if `round'diff`y' > `truncation' & !missing(`round'diff`y')
replace `round'diff`y' = 0 if `round'diff`y' < 0 & !missing(`round'diff`y')

forvalues i = 0/`truncation' { 
forvalues j = 0/`i' {
replace mr`=`y' - `j''  = 1 if `round'diff`y' == `i' & (`round'chm`y' == 1 | `round'chm`y' == 5 | `round'chm`y' == 4)
replace mrS`=`y' - `j''  = mrS`=`y' - `j' - 1' + 1 if `round'diff`y' == `i' & (`round'chm`y' == 1 | `round'chm`y' == 5 | `round'chm`y' == 4)

foreach var of newlist dv wd sg {
replace `var'`=`y' - `j'' = 0 if `round'diff`y' == `i' & (`round'chm`y' == 1 | `round'chm`y' == 5 | `round'chm`y' == 4) 
}

replace wd`=`y' - `j'' = 1 if `round'diff`y' == `i' & `round'chm`y' == 6
replace wdS`=`y' - `j'' = wdS`=`y' - `j' - 1' + 1 if `round'diff`y' == `i' & `round'chm`y' == 6

foreach var of newlist dv mr sg {
replace `var'`=`y' - `j'' = 0 if `round'diff`y' == `i' & `round'chm`y' == 6
}

replace dv`=`y' - `j'' = 1 if `round'diff`y' == `i' & (`round'chm`y' == 2 | `round'chm`y' == 3)


foreach var of newlist mr wd sg {
replace `var'`=`y' - `j'' = 0 if `round'diff`y' == `i' & (`round'chm`y' == 2 | `round'chm`y' == 3)
}

}
}
}  


assert mr`y' + dv`y' + wd`y' + sg`y' == 1 if !missing(mr`y') & !missing(dv`y') & !missing(wd`y') & !missing(sg`y')

}

* Taking into acount the fact that the divorce that happens after separation is considered as one divorce 
forvalues y = 1980/2012{
replace dvS`y' = dvS`= `y' - 1' + 1 if dv`y' - dv`= `y' - 1' == 1
replace dvS`y' = dvS`= `y' - 1'     if dv`y' - dv`= `y' - 1' != 1 
}

//////////////////////////////////////////////////////////////////////
// Calculating marital categories and number of marriages, divorces, and widowhoods

** Number of marriages, divorces, and widowhoods 
local num_year: word count of `iy' 
display `num_year'
tokenize `iy'
* It's wierd that the count command, counts one more extra
local last = `= `num_year' - 1' 

* Initial levels of Marriage, Divorce, Widowhood, and Reunion 
gen M = 0 
replace M = num_m1979 if !missing(num_m1979)
replace M = 1 if ms1979 == 1 & missing(num_m1979)
replace M = M + mrS``last''

gen D = 0 
replace  D = 1 if (ms1979 == 3 | ms1979 == 4) & num_m1979 == 1 
replace D = 2 if ms1979 == 3 & num_m1979==2
replace D = D + dvS``last''

gen W = 0 
replace W = 1 if ms1979 == 2 
replace W = W + wdS``last''


* Creating marriage categories 
gen Mrd = 0 
replace Mrd = 1 if M > D + W  

gen cMrd = 0
replace cMrd = 1 if M ==1 & D + W == 0 

gen rMrd = 0 
replace rMrd = 1 if Mrd == 1 & cMrd == 0 

gen pMrd = 0 
replace pMrd = 1 if M <= D + W & M > 0 

gen nMrd =0
replace nMrd = 1 if M == 0 & D == 0 & W == 0 

gen rMrdD = 0
replace rMrdD = 1 if M > D + W & M ==2 & D == 1

gen rMrdW = 0 
replace rMrdW = 1 if M > D + W & M ==2 & W == 1

gen rMrdT = 0 
replace rMrdT = 1 if M >= 3 & D + W >= 2 

gen pMrdD = 0 
replace pMrdD = 1 if M == 1 & D == 1 & W == 0 

gen pMrdW = 0 
replace pMrdW = 1 if M == 1 & D == 0 & W == 1

gen pMrdT = 0
replace pMrdT = 1 if M >= 2 & M <= D + W  



//////////////////////////////////////////////////////////////////////
// Calculating durations of marriage, Divorce, widowhood, and singlehood 
gen dumr = mr1979
gen dusg = sg1979
gen duwd = wd1979
gen dudv = dv1979
forvalues y = 1980/2012{
foreach var of newlist mr sg wd dv{
replace du`var' = du`var' + `var'`y'
}
}

// Adding the initial years of marriage and divorce durations. 

* For continuously married couples 
gen duBmr = 1979 - fms_y if fms_y < 1978 & missing(fme_y)


* Duration of marriage for disrupted unions 
replace duBmr = (1900 + fme_y) - fms_y + 1 if fms_y < 1978 & missing(duBmr)

* Duration of divorce for remarried  
gen duBdv = rms_y - (1900 + fme_y) + 1 

* Adding the second marriage durations 
gen duBmr2 =  1979 - rms_y if rms_y != fms_y & !missing(fms_y)

* Adding up the years of being married 
replace duBmr = duBmr + duBmr2 if !missing(duBmr2)

* Correcting for dumr dudv
replace dumr = dumr + duBmr if !missing(duBmr)
replace dudv = dudv + duBdv if !missing(duBdv)


/////////////////////////////////////////////////////////////////////
* Age at first marriage 

forvalues var = 71/79{
recode fms_y (`var'  = `= 1900 + `var'')
recode rms_y (`var'  = `= 1900 + `var'')
}

replace fms_y = rms_y if missing(fms_y)

foreach var of local iy {
foreach round of newlist F S T{
replace fms_y = `var' if chm`var' == 1 &   (`round'chm`var' == 1)  & missing(fms_y) 
}
replace fms_y = .a if nMrd == 1 
}

gen afm = age82 + (fms_y - 1982) if fms_y != 0 
replace afm = .a if fms_y == .a
lab var afm "Age at first marriage"



/////////////////////////////////////////////////////////////////////////////
// Constructing BMI

numlist "1981 1982 1986 1988 1990 1992 1993 1994(2)2012"
local wy "`r(numlist)'"
local duration mr dv wd sg

foreach var of local wy{
gen bmi`var' = (wt`var' * 703) / (htf2012 * 12 + htin2012)^2
}

foreach y of local wy{
foreach ms of local duration{
gen `ms'bmi`y' = .
}
foreach ms of local duration{
replace `ms'bmi`y' = bmi`y' if `ms'`y' == 1
}
}


foreach ms of local duration{
local l`ms' 
foreach y of local wy{
local l`ms' `l`ms'' `ms'bmi`y'
}
egen `ms'bmi =  rowmean(`l`ms'')
gen `ms'bmiH = cond(18.5 <= `ms'bmi & `ms'bmi < 25 , 1, 0)
replace `ms'bmiH = . if missing(`ms'bmi)
}


// BMI in each rank of marriage and divorce 

local  rnk_m_spel = 3

forvalues i = 1/`rnk_m_spel'{
foreach ms in mr dv{
local l`ms'`i'
foreach y of local wy{
gen `ms'mrk`y'_`i' = .
replace `ms'mrk`y'_`i' = 1 if `ms'S`y' == `i'
gen `ms'prdct`y'_`i' = `ms'mrk`y'_`i' * `ms'bmi`y' 
local l`ms'`i' `l`ms'`i'' `ms'prdct`y'_`i'
}
egen `ms'bmi_S`i' = rowmean(`l`ms'`i'')
gen `ms'bmiH_S`i' = cond(18.5 <= `ms'bmi_S`i' & `ms'bmi _S`i'< 25 , 1, 0)
replace `ms'bmiH_S`i' = . if missing(`ms'bmi_S`i')
}
}




save hm-data02, replace 
log close 
exit
