********************************************************************************
********************************************************************************

* NAME:		Daily Positivity, CFR, Duration to Death for COVID19 Mexico
* AUTHOR: 	Alberto Diaz-Cayeros, Stanford University
* DATE:		29_AUG_2020
* MODIFIED: 29_AUG_2020
* VERSION: 	Stata 14.2

* SUMMARY
    * 1. CALCULATE YLL
	* 2. ANALYSIS DURATION DEATH
	* 3. COLLAPSE DAILY DATA
	* 4. COLLAPSE MUNICIPAL MONTHLY DATA


********************************************************************************
********************************************************************************

* This version uses data with n=1,319,957 released August 28

********************************************************************************
* 							PART 1. CALCULATE YLL
********************************************************************************


clear
* cd "C:\Users\Alberto Diaz-Cayeros\Box\COVID19\Databases Mexico\"
* cd "/Users/diazmagaloni/Box/COVID19/Databases Mexico/"
cd "/Users/albertodiaz/Box/COVID19/Databases Mexico/"
set more off
use "covidmexico23.dta", clear


gen YLLg = .
replace YLLg = 72.4 - edad if male == 1 & death==1
replace YLLg = 78.1 - edad if male == 0 & death==1

* de acuerdo con los indicadores demograficos CONAPO http://www.conapo.gob.mx/work/models/CONAPO/Mapa_Ind_Dem18/index_2.html

* this includes negative YLLs; we only take positive ones, representing
* premature deaths
gen cohort=edad
recode cohort 0/1=1 1/5=2 5/10=3 10/15=4 15/20=5 20/25=6 25/30=7 30/35=8 35/40=9 40/45=10 45/50=11 50/55=12 55/60=13 60/65=14 65/70=15 70/75=16 75/80=17 80/85=18 85/max=19

gen extralife=.
replace extralife=0 if cohort==1
replace extralife=2 if cohort==2 & male==1
replace extralife=3.5 if cohort==3 & male==1
replace extralife=3.5 if cohort==4 & male==1
replace extralife=3.5 if cohort==5 & male==1
replace extralife=4 if cohort==6 & male==1
replace extralife=4.5 if cohort==7 & male==1
replace extralife=5 if cohort==8 & male==1
replace extralife=5.5 if cohort==9 & male==1
replace extralife=6 if cohort==10 & male==1
replace extralife=7 if cohort==11 & male==1
replace extralife=7.5 if cohort==12 & male==1
replace extralife=8.5 if cohort==13 & male==1
replace extralife=10 if cohort==14 & male==1
replace extralife=11.5 if cohort==15 & male==1
replace extralife=13.5 if cohort==16 & male==1
replace extralife=15.5 if cohort==17 & male==1
replace extralife=18 if cohort==18 & male==1
replace extralife=21 if cohort==19 & male==1

* women
replace extralife=2.5 if cohort==2 & male==0
replace extralife=3.5 if cohort==3 & male==0
replace extralife=3.5 if cohort==4 & male==0
replace extralife=3.5 if cohort==5 & male==0
replace extralife=3.5 if cohort==6 & male==0
replace extralife=3.5 if cohort==7 & male==0
replace extralife=4 if cohort==8 & male==0
replace extralife=4.5 if cohort==9 & male==0
replace extralife=4.5 if cohort==10 & male==0
replace extralife=4.5 if cohort==11 & male==0
replace extralife=5.5 if cohort==12 & male==0
replace extralife=6 if cohort==13 & male==0
replace extralife=7 if cohort==14 & male==0
replace extralife=8 if cohort==15 & male==0
replace extralife=10 if cohort==16 & male==0
replace extralife=11.5 if cohort==17 & male==0
replace extralife=13.5 if cohort==18 & male==0
replace extralife=16.5 if cohort==19 & male==0

*create a corrected YLL measure with the extra years
gen YLLe=YLLg+extralife
recode YLLe min/0=0

* and we add an extended measure which counts every death occuring at
* or after life expectancy as 1

gen YLLp=YLLe
recode YLLp 0=1 

save "covidmexico23_2.dta", replace


********************************************************************************
* 							PART 2. ANALYSIS DURATION DEATH
********************************************************************************

clear
* cd "C:\Users\Alberto Diaz-Cayeros\Box\COVID19\Databases Mexico\"
* cd "/Users/diazmagaloni/Box/COVID19/Databases Mexico/"
cd "/Users/albertodiaz/Box/COVID19/Databases Mexico/"
set more off
use "covidmexico23_2.dta", clear

gen daystodeath= deathdate-ingresodate
replace daystodeath=0 if daystodeath<0
gen dayweekdead=dow(deathdate)
gen dayweeksymptom=dow(sympthomsdate)
gen dayweekingreso=dow(ingresodate)
gen mes=month(ingresodate)

format %td ingresodate
format %td sympthomsdate
format %td reportdate


label define imss 0 "Otro establecimiento" 1 "IMSS"
label value imss imss
label define hospital 0 "Ambulatorio" 1 "Hospital"
label value hospital hospital
histogram daystodeath if daystodeath<30 & covid19==1, discrete frequency ytitle(Frecuencia (muertes)) xtitle(Días desde ingreso (al 28 de agosto)) by(, title(Dias transcurridos hasta defunción por COVID19)) scheme(s2mono) by(imss sex)
graph save Graph "diastranscurridosimss23.gph", replace
histogram daystodeath if daystodeath<30, discrete frequency ytitle(Frecuencia (muertes)) xtitle(Días desde ingreso (al 28 de agosto)) by(, title(Dias transcurridos hasta defunción por IRAG)) scheme(s2mono) by(hospital sex)
graph save Graph "diastranscurridoshospital23.gph", replace
histogram daystodeath if daystodeath<30, discrete frequency ytitle(Frecuencia (muertes)) xtitle(Días desde ingreso (al 28 de agosto)) by(, title(Dias transcurridos hasta defunción por IRAG)) scheme(s2mono) by(covid19 sex)
graph save Graph "diastranscurridosirag23.gph", replace

table covid19 sex, c(count daystodeath)
table covid19 sex, c(p25 daystodeath)
table covid19 sex, c(p75 daystodeath)
table covid19 sex, c(median daystodeath)
table covid19 sex, c(mean daystodeath)

table covid19 icu, c(count daystodeath)
table covid19 icu, c(p25 daystodeath)
table covid19 icu, c(p75 daystodeath)
table covid19 icu, c(mean daystodeath)
table covid19 icu, c(median daystodeath)


table sector3 covid19 if hospital==1, c(count daystodeath)
table sector3 covid19 if hospital==1, c(p25 daystodeath)
table sector3 covid19 if hospital==1, c(median daystodeath)
table sector3 covid19 if hospital==1, c(p75 daystodeath)
table sector3 covid19 if hospital==1, c(mean daystodeath)


stset daystodeath, failure(death) scale(1)
* stset daytodeath, failure(coviddeath) scale(1)
* must decide which graph to include...
sts graph if _t<=30, hazard by(sector3) scheme(s2color)
sts graph if _t<=30, hazard ci by(dayweekingreso)
sts graph if _t<=30, hazard ci by(intubate)
sts graph if _t<=30, hazard ci by(hospital)
sts graph if _t<=30, hazard ci by(icu)
sts graph if _t<=30, hazard ci by(male)
sts graph if _t<=30, hazard ci by(indigenous)
sts graph if _t<=30, hazard ci by(covid19)
sts graph if _t<=30 & mes>=4 & mes<8, hazard ci by(mes)
sts graph if _t<=30, hazard ci by(usmer)

save "covidmexico23_3.dta", replace
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
* 							PART 3. COLLAPSE DAILY DATA
********************************************************************************

clear
* cd "C:\Users\Alberto Diaz-Cayeros\Box\COVID19\Databases Mexico\"
* cd "/Users/diazmagaloni/Box/COVID19/Databases Mexico/"
cd "/Users/albertodiaz/Box/COVID19/Databases Mexico/"
set more off
use "covidmexico23_3.dta", clear

sort ingresodate



collapse (sum) covid19 death YLLe (mean) positivity=covid19 cfr=death edad daystodeath (count) count=covid19, by(ingresodate)
export excel dailycovidtotal.xlsx, firstrow(variables) replace
clear

use "covidmexico23_3.dta", clear
collapse (sum) death YLLe (mean) cfr=death edad daystodeath (count) count=male, by(ingresodate covid19)
reshape wide death cfr edad daystodeath YLLe count, i(ingresodate) j(covid19)
export excel dailycovidbyresult.xlsx, firstrow(variables) replace
clear

use "covidmexico23_3.dta", clear
drop if sector3==.
collapse (sum) covid19 death YLLe (mean) positivity=covid19 cfr=death edad daystodeath (count) count=male, by(ingresodate sector3)
reshape wide covid19 death positivity cfr edad daystodeath YLLe count, i(ingresodate) j(sector3)
export excel dailycovidbysector.xlsx, firstrow(variables) replace
clear

use "covidmexico23_3.dta", clear
collapse (sum) covid19 death YLLe (mean) positivity=covid19 cfr=death edad daystodeath (count) count=male, by(ingresodate usmer)
reshape wide covid19 death positivity cfr edad daystodeath YLLe count, i(ingresodate) j(usmer)
export excel dailycovidbyusmer.xlsx, firstrow(variables) replace
clear

use "covidmexico23_3.dta", clear
collapse (sum) covid19 YLLe (mean) positivity=covid19 edad daystodeath (count) count=male, by(ingresodate death)
reshape wide covid19 positivity edad daystodeath YLLe count, i(ingresodate) j(death)
export excel dailycovidbydeath.xlsx, firstrow(variables) replace
clear



gen zmcm=alcaldia
recode zmcm 1/27=1 28/30=0
tab zmcm
table ingresodate zmcm, c(summ death)
table ingresodate zmcm, c(mean death)
table ingresodate zmcm, c(count death)


********************************************************************************
* 							PART 4. COLLAPSE MUNICIPAL MONTHLY DATA
********************************************************************************

set more off
use "covidmexico23_3.dta", clear

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
putexcel set /Users/albertodiaz/Box/COVID19/monthcovidbymunAug28.xlsx, replace
