********************************************************************************
********************************************************************************

* NAME:		Daily Positivity, CFR, Duration to Death for COVID19 Mexico
* AUTHOR: 	Alberto Diaz-Cayeros, Stanford University
* DATE:		29_AUG_2020
* MODIFIED: 7_SEP_2020
* VERSION: 	Stata 14.2

* SUMMARY

	* 1. CALCULATE MATCHING
	* 2. COLLAPSE DAILY DATA
	* 3. COLLAPSE ZMCM MONTHLY DATA
	* 4. COLLAPSE MUNICIPAL MONTHLY DATA


********************************************************************************
********************************************************************************

* This version uses data with n=1,319,957 released August 28

********************************************************************************
* 							PART 1. CALCULATE MATCHING
********************************************************************************


clear
* cd "C:\Users\Alberto Diaz-Cayeros\Box\COVID19\Databases Mexico\"
* cd "/Users/diazmagaloni/Box/COVID19/Databases Mexico/"
cd "/Users/albertodiaz/Box/COVID19/Databases Mexico/"
set more off
use "covidmexico24.dta", clear

* these take a long time to run...

* nnmatch daystodeath intubate edad onset, exact(male icu pneumonia hospital usmer hipertension obesidad diabetes epoc)
* nnmatch daydead icu edad onset, exact(male intubate pneumonia hospital usmer hipertension obesidad diabetes epoc)
* nnmatch daydead imss edad onset, exact(male icu intubate pneumonia hospital usmer hipertension obesidad diabetes epoc)
* nnmatch daydead ssa edad onset, exact(male icu intubate pneumonia hospital usmer hipertension obesidad diabetes epoc)
* nnmatch daydead privada edad onset, exact(male icu intubate pneumonia hospital usmer hipertension obesidad diabetes epoc)
* nnmatch daydead indigenous edad onset, exact(male icu intubate pneumonia hospital usmer hipertension obesidad diabetes epoc)
* nnmatch daydead pendingtest edad onset, exact(male icu intubate pneumonia hospital usmer hipertension obesidad diabetes epoc)
* nnmatch daydead covid19 edad onset, exact(male icu intubate pneumonia hospital usmer hipertension obesidad diabetes epoc)
* nnmatch daydead pneumonia edad onset, exact(male icu intubate pneumonia hospital usmer hipertension obesidad diabetes epoc)

********************************************************************************
* 							PART 2. COLLAPSE DAILY DATA
********************************************************************************

clear
* cd "C:\Users\Alberto Diaz-Cayeros\Box\COVID19\Databases Mexico\"
* cd "/Users/diazmagaloni/Box/COVID19/Databases Mexico/"
cd "/Users/albertodiaz/Box/COVID19/Databases Mexico/"
set more off
use "covidmexico24.dta", clear

sort ingresodate



collapse (sum) covid19 death YLLe (mean) positivity=covid19 cfr=death edad daystodeath (count) count=covid19, by(ingresodate)
export excel dailycovidtotal0907.xlsx, firstrow(variables) replace
clear

use "covidmexico24.dta", clear
collapse (sum) death YLLe (mean) cfr=death edad daystodeath (count) count=male, by(ingresodate covid19)
reshape wide death cfr edad daystodeath YLLe count, i(ingresodate) j(covid19)
export excel dailycovidbyresult0907.xlsx, firstrow(variables) replace
clear

use "covidmexico24.dta", clear
drop if sector3==.
collapse (sum) covid19 death YLLe (mean) positivity=covid19 cfr=death edad daystodeath (count) count=male, by(ingresodate sector3)
reshape wide covid19 death positivity cfr edad daystodeath YLLe count, i(ingresodate) j(sector3)
export excel dailycovidbysector0907.xlsx, firstrow(variables) replace
clear

use "covidmexico24.dta", clear
collapse (sum) covid19 death YLLe (mean) positivity=covid19 cfr=death edad daystodeath (count) count=male, by(ingresodate usmer)
reshape wide covid19 death positivity cfr edad daystodeath YLLe count, i(ingresodate) j(usmer)
export excel dailycovidbyusmer0907.xlsx, firstrow(variables) replace
clear

use "covidmexico24.dta", clear
collapse (sum) covid19 YLLe (mean) positivity=covid19 edad daystodeath (count) count=male, by(ingresodate death)
reshape wide covid19 positivity edad daystodeath YLLe count, i(ingresodate) j(death)
export excel dailycovidbydeath0907.xlsx, firstrow(variables) replace
clear

********************************************************************************
* 							PART 3. COLLAPSE ZMCM MONTHLY DATA
********************************************************************************

gen zmcm=alcaldia
recode zmcm 1/27=1 28/30=0
tab zmcm

table ingresodate zmcm, c(mean death)
table ingresodate zmcm, c(count death)


********************************************************************************
* 							PART 4. COLLAPSE MUNICIPAL MONTHLY DATA
********************************************************************************

set more off
use "covidmexico24.dta", clear

collapse (count) tests=sexo (sum) coviddeath YLLe death covid19 (mean) male indigenous hospital usmer imss bienestar issste municipal pemex privada sedena semar ssa universitario edad, by(st_mun_id mes)
drop if mes==.
sort st_mun_id
merge m:1 st_mun_id using "/Users/albertodiaz/Box/COVID19/deciles_rezago_poblacion.dta"
drop if _merge==1
drop _merge
mvencode _all, mv(0) override
reshape wide coviddeath YLLe death covid19 male indigenous hospital usmer imss bienestar issste municipal pemex privada sedena semar ssa universitario edad  tests, i(st_mun_id) j(mes)
mvencode _all, mv(0) override
reshape long
sort st_mun_id
drop if mes==0
drop if mes==1
drop if mes==2
drop if mes==3
drop if mes==8
gen class=1
replace class=2 if death>0
replace class=3 if coviddeath>0
reshape wide class coviddeath YLLe death covid19 male indigenous hospital usmer imss bienestar issste municipal pemex privada sedena semar ssa universitario edad  tests, i(st_mun_id) j(mes)
putexcel set /Users/albertodiaz/Box/COVID19/monthcovidbymunSept7.xlsx, replace
