*------------------------------------------------------
* AUTHORS: A. Diaz-Cayeros
* PURPOSE: Calculate YLLs with life expectancy beyond birth for COVID19 deaths
*          and cases of IRAG and tests
* DATA IN: .dta
* 
* DATA OUT: .dta
* DATE BEGAN: June 18, 2020
*------------------------------------------------------

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





sort st_mun_id
merge m:1 st_mun_id using "/Users/albertodiaz/Box/COVID19/deciles_rezago_poblacion.dta"
