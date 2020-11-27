********************************************************************************
********************************************************************************

* NAME:		Daily Positivity, CFR, Duration to Death for COVID19 Mexico
* AUTHOR: 	Alberto Diaz-Cayeros, Stanford University
* DATE:		29_AUG_2020
* MODIFIED: 23_NOV_2020
* VERSION: 	Stata 14.2

* SUMMARY

	* 1. CALCULATE MATCHING
	* 2. COLLAPSE DAILY DATA
	* 3. COLLAPSE MUNICIPAL MONTHLY DATA
	* 4. COLLAPSE ZMCM MONTHLY DATA

********************************************************************************
********************************************************************************

* This version uses data with n=2,716,315 released November 23

********************************************************************************
* 							PART 1. CALCULATE MATCHING
********************************************************************************


* clear
* cd "C:\Users\Alberto Diaz-Cayeros\Box\COVID19\Databases Mexico\"
* cd "/Users/diazmagaloni/Box/COVID19/Databases Mexico/"
* cd "/Users/albertodiaz/Box/COVID19/Databases Mexico/"
* set more off
* use "covidmexico31.dta", clear

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
use "covidmexico31.dta", clear
set more off
sort ingresodate



collapse (sum) covid19 death YLLe (mean) positivity=covid19 cfr=death edad daystodeath (count) count=covid19, by(ingresodate)
export excel dailycovidtotal1123.xlsx, firstrow(variables) replace
clear

use "covidmexico31.dta", clear
collapse (sum) death YLLe (mean) cfr=death edad daystodeath (count) count=male, by(ingresodate covid19)
reshape wide death cfr edad daystodeath YLLe count, i(ingresodate) j(covid19)
export excel dailycovidbyresult1123.xlsx, firstrow(variables) replace
clear

use "covidmexico31.dta", clear
drop if sector3==.
collapse (sum) covid19 death YLLe (mean) positivity=covid19 cfr=death edad daystodeath (count) count=male, by(ingresodate sector3)
reshape wide covid19 death positivity cfr edad daystodeath YLLe count, i(ingresodate) j(sector3)
export excel dailycovidbysector1123.xlsx, firstrow(variables) replace
clear

use "covidmexico31.dta", clear
collapse (sum) covid19 death YLLe (mean) positivity=covid19 cfr=death edad daystodeath (count) count=male, by(ingresodate usmer)
reshape wide covid19 death positivity cfr edad daystodeath YLLe count, i(ingresodate) j(usmer)
export excel dailycovidbyusmer1123.xlsx, firstrow(variables) replace
clear

use "covidmexico31.dta", clear
collapse (sum) covid19 YLLe (mean) positivity=covid19 edad daystodeath (count) count=male, by(ingresodate death)
reshape wide covid19 positivity edad daystodeath YLLe count, i(ingresodate) j(death)
export excel dailycovidbydeath1123.xlsx, firstrow(variables) replace
clear



********************************************************************************
* 							PART 3. COLLAPSE MUNICIPAL MONTHLY DATA
********************************************************************************

set more off
use "covidmexico31.dta", clear

collapse (count) tests=sexo (sum) coviddeath YLLe death covid19 (mean) male indigenous hospital usmer  edad, by(st_mun_id mes)
drop if mes==.
sort st_mun_id
merge m:1 st_mun_id using "/Users/albertodiaz/Box/COVID19/deciles_rezago_poblacion.dta"
* merge m:1 st_mun_id using "C:\Users\Alberto Diaz-Cayeros\Box\COVID19\deciles_rezago_poblacion.dta"
drop if _merge==1
drop _merge
mvencode _all, mv(0) override
reshape wide coviddeath YLLe death covid19 male indigenous hospital usmer edad  tests, i(st_mun_id) j(mes)
mvencode _all, mv(0) override
reshape long
sort st_mun_id
drop if mes<=3

drop if mes==11
gen class=1
replace class=2 if death>0
replace class=3 if coviddeath>0
reshape wide class coviddeath YLLe death covid19 male indigenous hospital usmer edad  tests, i(st_mun_id) j(mes)
export delimited using "/Users/albertodiaz/Box/COVID19/monthcovidbymunNov23.csv", replace


********************************************************************************
* 							PART 4. COLLAPSE MUNICIPAL WEEKLY DATA
********************************************************************************

set more off
use "covidmexico31.dta", clear

gen semana=week(ingresodate)
collapse (count) tests=sexo (sum) coviddeath YLLe death covid19 (mean) male indigenous hospital usmer  edad, by(st_mun_id semana)
drop if semana==.
sort st_mun_id
merge m:1 st_mun_id using "/Users/albertodiaz/Box/COVID19/deciles_rezago_poblacion.dta"
* merge m:1 st_mun_id using "C:\Users\Alberto Diaz-Cayeros\Box\COVID19\deciles_rezago_poblacion.dta"
drop if _merge==1
drop _merge
mvencode _all, mv(0) override
reshape wide coviddeath YLLe death covid19 male indigenous hospital usmer  edad  tests, i(st_mun_id) j(semana)
mvencode _all, mv(0) override
reshape long
sort st_mun_id
drop if semana<18
drop if semana>45
gen class=1
replace class=2 if death>0
replace class=3 if coviddeath>0
reshape wide class coviddeath YLLe death covid19 male indigenous hospital usmer  edad  tests, i(st_mun_id) j(semana)
reshape long
tsset st_mun_id semana
by st_mun_id: gen ctests=sum(tests)
by st_mun_id: gen ccoviddeath=sum(coviddeath)
by st_mun_id: gen cYLLe=sum(YLLe)
by st_mun_id: gen cdeath=sum(death)
by st_mun_id: gen ccovid19=sum(covid19)
gen cpositivity=ccovid19/ctests
gen ccfrirag=cdeath/ctests
gen ccfrcovid=ccoviddeath/ccovid19
reshape wide class coviddeath YLLe death covid19 male indigenous hospital usmer  edad  tests ctests ccoviddeath cYLLe cdeath ccovid19 cpositivity ccfrirag ccfrcovid, i(st_mun_id) j(semana)


export delimited using "/Users/albertodiaz/Box/COVID19/weekcovidbymunNov23.csv", replace

********************************************************************************
* 							PART 5. COLLAPSE ZMCM MONTHLY DATA
********************************************************************************
use "covidmexico31.dta", clear
set more off
gen zmcm=alcaldia
recode zmcm 1/27=1 28/30=0
tab zmcm

table ingresodate zmcm, c(mean death)
table ingresodate zmcm, c(count death)
