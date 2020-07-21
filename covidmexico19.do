********************************************************************************
********************************************************************************

* NAME:		Analysis Case Fatality Rate logit models COVID19 Mexico
* AUTHOR: 	Alberto Diaz-Cayeros, Stanford University
* DATE:		17_APR_2020
* MODIFIED: 19_JUL_2020
* VERSION: 	Stata 14.2

* SUMMARY
	* 1. CONVERT DATA
	* 2. INSTITUTIONAL VARIABLES
	* 3. LABELS AND RECODING IN SPANISH
	* 4. MUNICIPAL ID FOR MERGES
	* 5. LOGIT MODELS

********************************************************************************
********************************************************************************

* This version uses data with n=814,653 released July 18

********************************************************************************
* 							PART 1. CONVERT DATA
********************************************************************************
clear
set more off
* cd "C:\Users\Alberto Diaz-Cayeros\Box\COVID19\Databases Mexico\"
* cd "/Users/diazmagaloni/Box/COVID19/Databases Mexico/"
cd "/Users/albertodiaz/Box/COVID19/Databases Mexico/"
* Or whichever is your root directory and OS
import delimited "200718COVID19MEXICO.csv", encoding(ISO-8859-1)
* change the code of date and residence to get rid of missing values quickly
recode edad 99=199 98=198
recode municipio_res 99=599 98=598
* removing MV
mvdecode _all, mv(98)
mvdecode _all, mv(99)
mvdecode municipio_res, mv(999)
* returning the municipal and age 99 and 98 values
recode edad 198=98 199=99
recode municipio_res 598=98 599=99
* change dates from string to numeric values
gen reportdate=date(fecha_actualizacion, "YMD")
gen ingresodate=date(fecha_ingreso, "YMD")
gen sympthomsdate=date(fecha_sintomas, "YMD")
gen deathdate=date(fecha_def, "YMD")
* generate a categorical variable of death outcome
gen death=0
replace death=1 if deathdate~=.
* recode comorbidity conditions
recode diabetes 2=0
recode epoc 2=0
* Enfermedad pulmonar obstructiva crónica (EPOC)
recode asma 2=0
recode inmusupr 2=0
recode hipertension 2=0
recode otra_com 2=0
recode cardiovascular 2=0
recode obesidad 2=0
recode renal_cronica 2=0
recode tabaquismo 2=0



********************************************************************************
* 							PART 2. INSTITUTIONAL VARIABLES
********************************************************************************


* recode institution treating patient
gen cruzroja=0
replace cruzroja=1 if sector==1 
gen dif=0
replace dif=1 if sector==2 
gen estatal=0
replace estatal=1 if sector==3 
gen imss=0
replace imss=1 if sector==4
gen bienestar=0
replace bienestar=1 if sector==5
gen issste=0
replace issste=1 if sector==6
gen municipal=0
replace municipal=1 if sector==7
gen pemex=0
replace pemex=1 if sector==8
gen privada=0
replace privada=1 if sector==9
gen sedena=0
replace sedena=1 if sector==10
gen semar=0
replace semar=1 if sector==11
gen ssa=0
replace ssa=1 if sector==12
gen universitario=0
replace universitario=1 if sector==13
* make a sector variable that has ssa clinics and hospitals as base category
gen sector2=sector
recode sector2 12=0
label define sector 1 "Cruz Roja" 2 "DIF" 3 "Estatal" 4 "IMSS" 5 "Bienestar" 6 "ISSSTE" 7 "Municipal" 8 "PEMEX" 9 "Privada" 10 "SEDENA" 11 "SEMAR" 12 "SSA" 13 "Universitario" 0 "SSA"
label values sector sector
label values sector2 sector
gen sector3=sector2
recode sector3 2/3=1 5=4 7/8=1 10/11=1 13=1
label define sector3 1 "Otra" 4 "IMSS" 6 "ISSSTE" 9 "Privada" 12 "SSA" 13 "Universitario" 0 "SSA"
label values sector3 sector3



********************************************************************************
* 							PART 3. LABELS AND RECODING IN SPANISH
********************************************************************************


* create labels for nicer graphs
label define sexo 1 "Femenino" 2 "Masculino"
label values sexo sexo
* recode organizational, diagnostic and intervention variables
*
* USMER refers to:
* "La vigilancia centinela se realiza a través del sistema de unidades de salud monitoras 
* de enfermedades respiratorias (USMER). Las USMER incluyen unidades médicas del primer, 
* segundo o tercer nivel de atención y también participan como USMER las unidades de 
* tercer nivel que por sus características contribuyen a ampliar el panorama de información 
* epidemiológica, entre ellas las que cuenten con especialidad de neumología, infectología 
* o pediatría. (Categorías en Catalógo Anexo)."
gen usmer=0
replace usmer=1 if origen==1
* type of patient, ambulatorio o hospitalario, refering to how they arrive to seek health
gen hospital=0
replace hospital=1 if tipo_paciente==2
* these refer to the intervention and the diagnosis, including COVID19 testing
gen intubate=0
replace intubate=1 if intubado==1
gen icu=0
replace icu=1 if uci==1
gen pneumonia=0
replace pneumonia=1 if neumonia==1
gen covid19=0
replace covid19=1 if resultado==1
gen pendingtest=0
replace pendingtest=1 if resultado==3
label define covid19 0 "Negativo o pendiente" 1 "Positivo COVID19"
label value covid19 covid19
* these are some additional individual level characteristics
gen pregnant=0
replace pregnant=1 if embarazo==1
gen indigenous=0
replace indigenous=1 if habla_lengua_indi==1
gen travel=1
replace travel=0 if pais_origen=="97"
gen migrant=0
replace migrant=1 if migrante==1
gen foreigner=1
replace foreigner=0 if pais_nacionalidad=="México"
replace foreigner=0 if pais_nacionalidad=="99"
* this refers to whether patient is linked to a known case
gen contagion=0
replace contagion=1 if otro_caso==1
* recodify gender to male (highlighing higher risk)
gen male=sexo
recode male 2=1 1=0
* lag in days between initial symptoms and arrival to health care
gen onset= ingresodate-sympthomsdate
* there is an additional indicator regarding the state where clinic is located. We use the residence
* standardizing to CDMX being 0 in order to make the i.state command easier to interpret (ie. fixed effects)
gen state= entidad_res
recode state 9=0
label define state 1 "AGS" 2 "BC" 3 "BCS" 4 "CAM" 5 "COA" 6 "COL" 7 "CHIS" 8 "CHIH" 9 "CDMX" 0 "CDMX" 10 "DGO" 11 "GTO" 12 "GRO" 13 "HGO" 14 "JAL" 15 "MEX" 16 "MICH" 17 "MOR" 18 "NAY" 19 "NL" 20 "OAX" 21 "PUE" 22 "QRO" 23 "QR" 24 "SLP" 25 "SIN" 26 "SON" 27 "TAB" 28 "TAM" 29 "TLA" 30 "VER" 31 "YUC" 32 "ZAC"
label values state state



********************************************************************************
* 							PART 4. MUNICIPAL IDS FOR MERGES
********************************************************************************


* inegi code for municipality in order to merge with aggregate data
gen st_mun_id=entidad_res*1000+municipio_res
gen coviddeath=0
replace coviddeath=1 if resultado==1 & death==1
gen deathcat=death
replace deathcat=2 if coviddeath==1
gen resultado2=resultado
recode resultado2 2=0 3=2

*** correct typo in otra_com
rename otra_com otra_con

********************************************************************************
* 							PART 5. LOGIT MODELS
********************************************************************************
set more off

* models incorporating incremental variables
logit death i.sexo##i.covid19 c.edad##i.covid19, or vce(cluster st_mun_id)
outreg2 using covidmex19, tex replace
#delimit ;
logit death i.sexo##i.covid19 c.edad##i.covid19  
	i.state, or vce(cluster st_mun_id); 
outreg2 using covidmex19, append tex;
logit death i.sexo##i.covid19 c.edad##i.covid19  
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo  
	i.state, or vce(cluster st_mun_id); 
outreg2 using covidmex19, append tex;

* I do not understand why, but syntax crashes here
* but you can just run the rest and it works...

set more off
#delimit ;
logit death i.sexo##i.covid19 c.edad##i.covid19 
	pregnant indigenous contagion 
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo  
	i.state, or vce(cluster st_mun_id);
outreg2 using covidmex19, append tex;
logit death i.sexo##i.covid19 c.edad##i.covid19 
	pregnant indigenous contagion 
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo 
	hospital usmer ingresodate onset pneumonia icu intubate 
	i.state, or vce(cluster st_mun_id); 
outreg2 using covidmex19, append tex;
logit death i.sexo##i.covid19 c.edad##i.covid19 
	pregnant indigenous contagion 
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo 
	hospital usmer ingresodate onset pneumonia icu intubate 
	i.state 
	i.sector3##i.covid19, or vce(cluster st_mun_id);
outreg2 using covidmex19, append tex;

* table only for usmer
set more off
#delimit ;
logit death i.sexo##i.covid19 c.edad##i.covid19   
	if usmer==1 , or vce(cluster st_mun_id);
outreg2 using covidusmer19, replace tex;
logit death i.sexo##i.covid19 c.edad##i.covid19  
	i.state  
	if usmer==1 , or vce(cluster st_mun_id);
outreg2 using covidusmer19, append tex;
logit death i.sexo##i.covid19 c.edad##i.covid19  
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo  
	i.state  
	if usmer==1 , or vce(cluster st_mun_id);
outreg2 using covidusmer19, append tex;
logit death i.sexo##i.covid19 c.edad##i.covid19 
	pregnant indigenous travel contagion 
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo  
	i.state  
	if usmer==1 , or vce(cluster st_mun_id);
outreg2 using covidusmer19, append tex;
logit death i.sexo##i.covid19 c.edad##i.covid19 
	pregnant indigenous contagion 
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo 
	hospital ingresodate onset pneumonia icu intubate 
	i.state  
	if usmer==1 , or vce(cluster st_mun_id);
outreg2 using covidusmer19, append tex;
logit death i.sexo##i.covid19 c.edad##i.covid19 
	pregnant indigenous contagion 
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo 
	hospital ingresodate onset pneumonia icu intubate 
	i.state 
	i.sector3##i.covid19 
	if usmer==1 , or vce(cluster st_mun_id);
outreg2 using covidusmer19, append tex;



* graph for demography in unconditional model
* had to redo this graph that was not calculated with all the data
logit death i.sexo##i.covid19 c.edad##i.covid19 , or vce(cluster st_mun_id);
margins covid19 , over(sexo) at(edad = (20 30 40 50 60 70 80 90)) ;
marginsplot , bydimension(covid19) byopt(ti("Defunción por Edad y Género") 
	subti("Estimación sin variables condicionales de intervención o contexto")) 
	xti("Edad") yti("Probabilidad Estimada") ;
graph save Graph "Demography19.gph", replace ;

* Graphs for institutional variables
#delimit ;
logit death i.sexo##i.covid19 c.edad##i.covid19 
	pregnant indigenous contagion 
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo 
	hospital usmer ingresodate onset pneumonia icu intubate 
	i.state i.sector3##i.covid19 , or vce(cluster st_mun_id);
margins sector3, over(covid19) at(edad = (20 30 40 50 60 70 80 90) ) ;
marginsplot , bydimension(covid19) byopt(ti("Defunción de Paciente Promedio") 
	subti("Paciente en valores promedio")) 
	xti("Edad") yti("Probabilidad Estimada") ;
graph save Graph "SectorPromedio19.gph", replace ;
margins sector3, over(covid19) at(edad = (20 30 40 50 60 70 80 90) sexo=2 intubate=1 icu=1 hospital=1 pneumonia=1) ;
marginsplot , bydimension(covid19) byopt(ti("Defunción de Paciente Grave") 
	subti("Hombre con pneumonía intubado en UCI de hospital")) 
	xti("Edad") yti("Probabilidad Estimada") ;
graph save Graph "SectorGrave19.gph", replace ;
margins sector3, over(covid19) at(edad = (20 30 40 50 60 70 80 90) sexo=1 intubate=0 icu=0 hospital=0 pneumonia=0) ;
marginsplot , bydimension(covid19) byopt(ti("Defunción de Paciente No Grave") 
	subti("Mujer sin pneumonía, ambulatoria, sin intervenciones")) 
	xti("Edad") yti("Probabilidad Estimada") ;
graph save Graph "SectorNoGrave19.gph", replace ;



* Graphs for state level variables

#delimit ;
margins state, over(covid19) at(sexo=1 intubate=0 icu=0 hospital=0 pneumonia=0) ;
marginsplot , bydimension(covid19) allx  xlabel(1(1)32, angle(45) labs(tiny))  byopt(ti("Defunción de Paciente No Grave") 
	subti("Mujer sin pneumonía, ambulatoria, sin intervenciones")) 
	xti("Entidad") yti("Probabilidad Estimada") 
	plotopts( connect(i) pstyle(p1) )
	scheme(s1mono);
graph save Graph "EntidadNoGrave19.gph", replace ;
graph export "EntidadNoGrave19.png", as(png) replace ;
#delimit ;
margins state, over(covid19) at(sexo=2 intubate=1 icu=1 hospital=1 pneumonia=1) ;
marginsplot , bydimension(covid19) allx  xlabel(1(1)32, angle(45) labs(tiny))  byopt(ti("Defunción de Paciente Grave") 
	subti("Hombre con pneumonía intubado en UCI de Hospital")) 
	xti("Entidad") yti("Probabilidad Estimada") 
	plotopts( connect(i) pstyle(p1) )
	scheme(s1mono) ;
graph save Graph "EntidadGrave19.gph", replace ;
graph export "EntidadGrave19.png", as(png) replace ;


graph use "SectorPromedio19.gph", scheme(s1color) ;
graph export "SectorPromedio19.png", as(png) replace ;

graph use "SectorGrave19.gph", scheme(s1color) ;
graph export "SectorGrave19.png", as(png) replace ;

graph use "SectorNoGrave19.gph", scheme(s1color) ;
graph export "SectorNoGrave19.png", as(png) replace ;

graph use "Demography19.gph", scheme(s1mono) ;
graph export "Demography19.png", as(png) replace ;



set more off

* reminder of coding of sector3
*  1 "Otra" 4 "IMSS" 6 "ISSSTE" 9 "Privada" 0 "SSA"
* code got interrupted here, but then it ran ok

#delimit ;
logit death 
	male edad 
	pregnant indigenous 
	ingresodate onset
	diabetes
	epoc
	asma 
	inmusupr 
	hipertension 
	otra_con 
	cardiovascular 
	obesidad 
	renal_cronica 
	tabaquismo 
	hospital pneumonia icu intubate
	if sector3==1 & covid19==1, or vce(cluster st_mun_id);
outreg2 using comorbidity18, replace tex;	


#delimit ;
coefplot, eform 
	drop(edad male hospital pneumonia icu intubate usmer pregnant indigenous contagion 
	ingresodate onset _cons) xline(1) 
xtitle(Razón de Momios de Co-morbilidad Otro Establecimiento, size(medium)) 
xlabel( , labsize(small))
coeflabels(, labcolor(black) labsize(small))
mlabel format(%3.2f) mlabposition(12) msize(small) mlabcolor(dkgreen) mcolor(maroon) mlabsize(small)
ciopts(lcolor(dkgreen))
graphregion(fcolor(white) lcolor(none) ifcolor(none) ilcolor(none))
plotregion(fcolor(white) ifcolor(none))
;

graph save Graph "ComorbOtro19.gph", replace ;


#delimit ;
logit death 
	male edad 
	pregnant indigenous 
	ingresodate onset
	diabetes
	epoc
	asma 
	inmusupr 
	hipertension 
	otra_con 
	cardiovascular 
	obesidad 
	renal_cronica 
	tabaquismo 
	hospital pneumonia icu intubate
	if sector3==4 & covid19==1, or vce(cluster st_mun_id);
outreg2 using comorbidity18, append tex;	


#delimit ;
coefplot, eform 
	drop(edad male hospital pneumonia icu intubate usmer pregnant indigenous contagion 
	ingresodate onset _cons) xline(1) 
xtitle(Razón de Momios de Co-morbilidad IMSS, size(medium)) 
xlabel( , labsize(small))
coeflabels(, labcolor(black) labsize(small))
mlabel format(%3.2f) mlabposition(12) msize(small) mlabcolor(dkgreen) mcolor(maroon) mlabsize(small)
ciopts(lcolor(dkgreen))
graphregion(fcolor(white) lcolor(none) ifcolor(none) ilcolor(none))
plotregion(fcolor(white) ifcolor(none))
;

graph save Graph "ComorbIMSS19.gph", replace ;


#delimit ;
logit death 
	male edad 
	pregnant indigenous 
	ingresodate onset
	diabetes
	epoc
	asma 
	inmusupr 
	hipertension 
	otra_con 
	cardiovascular 
	obesidad 
	renal_cronica 
	tabaquismo 
	hospital pneumonia icu intubate
	if sector3==6 & covid19==1, or vce(cluster st_mun_id);
outreg2 using comorbidity18, append tex;	


#delimit ;
coefplot, eform 
	drop(edad male hospital pneumonia icu intubate usmer pregnant indigenous contagion 
	ingresodate onset _cons) xline(1) 
xtitle(Razón de Momios de Co-morbilidad ISSSTE, size(medium)) 
xlabel( , labsize(small))
coeflabels(, labcolor(black) labsize(small))
mlabel format(%3.2f) mlabposition(12) msize(small) mlabcolor(dkgreen) mcolor(maroon) mlabsize(small)
ciopts(lcolor(dkgreen))
graphregion(fcolor(white) lcolor(none) ifcolor(none) ilcolor(none))
plotregion(fcolor(white) ifcolor(none))
;

graph save Graph "ComorbISSSTE19.gph", replace ;

#delimit ;
logit death 
	male edad 
	pregnant indigenous 
	ingresodate onset
	diabetes
	epoc
	asma 
	inmusupr 
	hipertension 
	otra_con 
	cardiovascular 
	obesidad 
	renal_cronica 
	tabaquismo 
	hospital pneumonia icu intubate
	if sector3==9 & covid19==1, or vce(cluster st_mun_id);
outreg2 using comorbidity18, append tex;	


#delimit ;
coefplot, eform 
	drop(edad male hospital pneumonia icu intubate usmer pregnant indigenous contagion 
	ingresodate onset _cons) xline(1) 
xtitle(Razón de Momios de Co-morbilidad Establecimiento Privado, size(medium)) 
xlabel( , labsize(small))
coeflabels(, labcolor(black) labsize(small))
mlabel format(%3.2f) mlabposition(12) msize(small) mlabcolor(dkgreen) mcolor(maroon) mlabsize(small)
ciopts(lcolor(dkgreen))
graphregion(fcolor(white) lcolor(none) ifcolor(none) ilcolor(none))
plotregion(fcolor(white) ifcolor(none))
;

graph save Graph "ComorbPrivado19.gph", replace ;

#delimit ;
logit death 
	male edad 
	pregnant indigenous 
	ingresodate onset
	diabetes
	epoc
	asma 
	inmusupr 
	hipertension 
	otra_con 
	cardiovascular 
	obesidad 
	renal_cronica 
	tabaquismo 
	hospital pneumonia icu intubate
	if sector3==0 & covid19==1, or vce(cluster st_mun_id);
outreg2 using comorbidity18, append tex;	


#delimit ;
coefplot, eform 
	drop(edad male hospital pneumonia icu intubate usmer pregnant indigenous contagion 
	ingresodate onset _cons) xline(1) 
xtitle(Razón de Momios de Co-morbilidad SSA (INSABI), size(medium)) 
xlabel( , labsize(small))
coeflabels(, labcolor(black) labsize(small))
mlabel format(%3.2f) mlabposition(12) msize(small) mlabcolor(dkgreen) mcolor(maroon) mlabsize(small)
ciopts(lcolor(dkgreen))
graphregion(fcolor(white) lcolor(none) ifcolor(none) ilcolor(none))
plotregion(fcolor(white) ifcolor(none))
;

graph save Graph "ComorbSSA19.gph", replace ;

#delimit ;
logit death 
	male edad 
	pregnant indigenous 
	ingresodate onset
	diabetes
	epoc
	asma 
	inmusupr 
	hipertension 
	otra_con 
	cardiovascular 
	obesidad 
	renal_cronica 
	tabaquismo 
	hospital pneumonia icu intubate
	if usmer==1 & covid19==1, or vce(cluster st_mun_id);
outreg2 using comorbidity18, append tex;	


#delimit ;
coefplot, eform 
	drop(edad male hospital pneumonia icu intubate usmer pregnant indigenous contagion 
	ingresodate onset _cons) xline(1) 
xtitle(Razón de Momios de Co-morbilidad USMER, size(medium)) 
xlabel( , labsize(small))
coeflabels(, labcolor(black) labsize(small))
mlabel format(%3.2f) mlabposition(12) msize(small) mlabcolor(dkgreen) mcolor(maroon) mlabsize(small)
ciopts(lcolor(dkgreen))
graphregion(fcolor(white) lcolor(none) ifcolor(none) ilcolor(none))
plotregion(fcolor(white) ifcolor(none))
;

graph save Graph "ComorbUSMER19.gph", replace ;

* export as png in monochrome scheme
#delimit ;
graph use "ComorbOtro19.gph", scheme(s1mono) ;
graph export "ComorbOtro19.png", as(png) replace ;
graph use "ComorbIMSS19.gph", scheme(s1mono) ;
graph export "ComorbIMSS19.png", as(png) replace ;
graph use "ComorbISSSTE19.gph", scheme(s1mono) ;
graph export "ComorbISSSTE19.png", as(png) replace ;
graph use "ComorbPrivado19.gph", scheme(s1mono) ;
graph export "ComorbPrivado19.png", as(png) replace ;
graph use "ComorbSSA19.gph", scheme(s1mono) ;
graph export "ComorbSSA19.png", as(png) replace ;
graph use "ComorbUSMER19.gph", scheme(s1mono) ;
graph export "ComorbUSMER19.png", as(png) replace ;

#delimit ;
graph combine "ComorbIMSS19.gph" 
	"ComorbISSSTE19.gph" 
	"ComorbSSA19.gph"
	"ComorbUSMER19.gph" ,  scheme(s1color)
	ycommon xcommon title(Condiciones Epidemiológicas de Co-morbilidad por Tipo de Establecimiento) 
	caption(Estimado modelo Logit con Base de Datos COVID19 Mexico) scale(.8)
	;
graph save Graph "ComorbEstab19.gph", replace ;
graph export "ComorbEstab19.png", as(png) replace ;



* estimation by usmer data only (systematic sample)
#delimit ;
logit death i.sexo##i.covid19 c.edad##i.covid19 
	pregnant indigenous contagion 
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo 
	hospital ingresodate onset pneumonia icu intubate 
	i.state i.sector3##i.covid19 
	if usmer==1, or vce(cluster st_mun_id);
margins sector3, over(covid19) at(edad = (20 30 40 50 60 70 80 90) sexo=2 intubate=1 icu=1 hospital=1 pneumonia=1) ;
marginsplot , bydimension(covid19) byopt(ti("Defunción de Paciente Grave en USMER") 
	subti("Hombre con pneumonía intubado en UCI de hospital")) 
	xti("Edad") yti("Probabilidad Estimada") ;
graph save Graph "usmer19.gph", replace ;
graph export "usmer19.png", as(png) replace ;


#delimit ;
logit death i.sexo##i.covid19 c.edad##i.covid19 
	pregnant indigenous contagion 
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo 
	hospital ingresodate onset pneumonia icu intubate 
	i.state i.sector3##i.covid19 
	if usmer==1, or vce(cluster st_mun_id);
margins sector3, over(covid19) at(edad = (20 30 40 50 60 70 80 90) sexo=1 intubate=0 icu=0 hospital=0 pneumonia=0) ;
marginsplot , bydimension(covid19) byopt(ti("Defunción de Paciente No Grave en USMER") 
	subti("Mujer Ambulatoria Sin Pneumonía")) 
	xti("Edad") yti("Probabilidad Estimada") ;
graph save Graph "usmernograve19.gph", replace ;
graph export "usmer19nograve.png", as(png) replace ;

#delimit cr	
table sector3 covid19 if usmer==1, c(mean death count death) 
table sector3 covid19 if usmer==0, c(mean death count death) 

* estimation for treatment in CDMX


gen alcaldia=0
replace alcaldia=st_mun_id if st_mun_id>9000 & st_mun_id <10000
recode alcaldia 9002=2 9003=3 9004=4 9005=5 9006=6 9007=7 9008=8 9009=9 9010=10 9011=11 9012=12 9013=13 9014=14 9015=15 9016=16 9017=17
replace alcaldia=30 if state==15
replace alcaldia=19 if st_mun_id==15013
replace alcaldia=20 if st_mun_id==15025
replace alcaldia=21 if st_mun_id==15031
replace alcaldia=22 if st_mun_id==15033
replace alcaldia=23 if st_mun_id==15037
replace alcaldia=24 if st_mun_id==15039
replace alcaldia=25 if st_mun_id==15057
replace alcaldia=26 if st_mun_id==15058
replace alcaldia=27 if st_mun_id==15104
replace alcaldia=28 if st_mun_id==15106
drop if st_mun_id==9106


#delimit ;
label define alcaldia
0 "Otros Municipios"
1 " "
2 "Azcapotzalco"
3 "Coyoacán"
4 "Cuajimalpa"
5 "Gustavo A. Madero"
6 "Iztacalco"
7 "Iztapalapa"
8 "Magdalena Contreras"
9 "Milpa Alta"
10 "Alvaro Obregón"
11 "Tláhuac"
12 "Tlalpan"
13 "Xochimilco"
14 "Benito Juárez"
15 "Cuauhtémoc"
16 "Miguel Hidalgo"
17 "Venustiano Carranza"
18 " "
19 "Atizapán de Zaragoza"
20 "Chalco"
21 "Chimalhuacán"
22 "Ecatepec"
23 "Huixquilucan"
24 "Ixtapaluca"
25 "Naucalpan"
26 "Nezahualcóyotl"
27 "Tlanepantla"
28 "Toluca"
29 " "
30 "Otros Mun EDOMEX"
 ;
label values alcaldia alcaldia ;

#delimit ;
logit death i.sexo##i.covid19 c.edad##i.covid19 
	i.alcaldia entidad_um
	if entidad_um==9 | entidad_um==15, or vce(cluster st_mun_id);

margins covid19 , over(sexo) at(edad = (20 30 40 50 60 70 80 90)) ;

marginsplot ,  bydimension(covid19) byopt(ti("Defunción por Edad y Género Pacientes CDMX") 
	subti("Estimación sin variables condicionales de intervención o contexto excepto residencia")) 
	xti("Edad") yti("Probabilidad Estimada") ;
	graph save Graph "DemographyCDMX19.gph",  replace ;


logit death i.sexo##i.covid19 c.edad##i.covid19 
	pregnant indigenous contagion 
	diabetes epoc asma inmusupr hipertension otra_con cardiovascular obesidad renal_cronica tabaquismo 
	hospital ingresodate onset pneumonia icu intubate 
	i.sector3##i.covid19 
	i.alcaldia entidad_um
	if entidad_um==9 | entidad_um==15, or vce(cluster st_mun_id);

margins alcaldia , over(covid19) at(sexo=2 entidad_um=9) ;

marginsplot , xdimension(alcaldia) allx  xlabel(1(1)30, angle(45)) byopt(ti("Defunción de Paciente en CDMX") 
	subti("Hombre residente CDMX sin especificar condición de salud")) 
	xti("Alcaldía o Municipio") yti("Probabilidad Estimada") 
	plotopts( connect(i) pstyle(p1) );
	graph save Graph "AlcaldiaCDMX19.gph",  replace ;



graph use "DemographyCDMX19.gph", scheme(s1mono) ;
graph export "DemographyCDMX19.png", as(png) replace ;

graph use "AlcaldiaCDMX19.gph", scheme(s1mono) ;
graph export "AlcaldiaCDMX19.png", as(png) replace ;




#delimit cr
save "covidmexico19.dta", replace
