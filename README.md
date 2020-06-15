# Case Mortality of COVID-19 patients in Mexico 

Since April 14 I have been keeping track of the data released by the Federal Government of Mexico of
information regarding COVID-19 tests for patients seeking care in the national health system, including
both public and private hospitals and clinics. The database has been growing very quickly, as the 
testing capacity of the Mexican government has been ramped up. 

As or June 11 the data includes more than 381 thousand cases that form the basis of study for the federal 
strategy. It is important to note that this data has been readily released by the federal government 
updated every day, and there is no reason to believe it is any different from the data they have been
using to build their epidemiological models.

The graphs are the estimated CFR for both positive and negative (or pending) test patients, according to 
various correlates also included in the dataset. It is very important to note that finding a correlation
in this type of data is no evidence of a causal relationship. This should be particularly clear when 
considering that intubation, hospital care in an ICU or having an initial diagnosis of pneumonia are all 
positively correlated with death, but that cannot be interpreted as meaning that urgent care interventions
increase the likelihood of dying: the relationship reveals the very strong selection effects that prevail
throughout all this data: a patient only enters the sample if she is seeking care, and more seriously ill
patients are more likely to require extraordinary measures, but they may still die, notwithstanding the care
they receive.

I am not particularly interested or competent to analyze the medical aspects of the comorbidity factors. However, 
including them in a statistical model is important because they are a large part of what accounts for an
eventual fatality. What interests me are the differences in institutional performance as exhibited by state
level fixed effects and the institutional makeup of health institutions in Mexico.

Although more sophisticated modelling choices are possible, the simple logits allow for a clear visualization of 
the main patterns and some indication of strong differential institutional performance.

![CFR Age and Gender](/Demography14.png)

The simplest estimation only uses two sociodemographic variables, namely age and gender, as determinants of the CFR. The simulation of those coefficients is presented in the first graph, which presents the predicted value of the probability of death depending on whether the COVID19 test result was negative (or pending) or positive. In the update of the dataset until June 11 there were 15,944 deaths of positive cases, but there were an additional 6,419 deaths of patients seeking care for serious acute respiratory infections (Infeccion Respiratoria Aguda Grave, IRAG) which are part of the dataset. It is important to include those negative (or pending cases) given that they are potentially false negatives or deaths that occured too soon (often on the day of admission) to register test results. 

In a more complete model the co-morbidity factors play an important role as a risk factor or a conditining variable that may increase the likelihood of death. The models that include those individual level correlates are simulated in the next set of graphs. Those co-morbidities are by now rather well know, not just from the case of Mexico but since the first analysis of data coming from China and Italy were done. It is clear that renal chronic conditions, inmunosupression and diabetes might play an important role in how the disease affects different patients. Smoking does not show up in the Mexican data as a significant factor afecting the risk of the death. Ths risk is not any different for preganant women (unreported in the graphs). 

![CFR por Comorbilidad](/Comorbilidad14.png)

I also present a set of models that include institutional variables related to the state where the patient has reported his or her residence, and the type of health establishment where the patient receives treatment. The image below presents the basic layout of the logit models, but please consult the full table in the pdf included in the repository. 

![CFR Logit Estimates](/covidmexJune11.jpg)

Many health interventions save lives. It is imporant to note that while the inclusion of hospitalization (instead of ambulatory care), being admitted in the ICU or intubation and having a clinical diagnosis of pneumonia all ara associated with a larger CFR, this does not mean that there is a causal relationship. More likelty these are selection effects. Intubation and ICU care are not very common in the dataset. Hence the extreme example of a seriously ill patient may not be estimated with as much precision as the other correlates. 

Death	Negativo   Positivo	Total
		
0	    722       533	        1,255 
1	    260       612	        872 
		
Total	982       1,145	      2,127 

![CFR by Sector Grave](/SectorGrave14.png)

Institutional differences among the various health establishments in Mexico are rather strong, particularly for IMSS and Private hospitals. These may be completely driven by selection effects, given that the characteristics of patients being admitted into each type of health establishment may be quite different: richer, healtheir and less serious cases may be arriving to private hospitals, while much more seriously ill, including uninsured patients may be treated in IMSS hospitals and clinics. But it is possible that some of the differences among institutions are driven by the quality of care and the resources available in each type of institution. There seem to be also some differences in the quality of care among ISSSTE and other hospitals depending on whether the patient has tested positive to COVID19, and the degree of seriousness of the case. 

![CFR by Sector No Grave](/SectorNoGrave14.png)

The estimation also includes variables (for which I do not provide graphical visualizations) that may relate to learning to treat the disease and how seriously ill patients arrive to seek care. There is a small trend in which patients admitted at later dates are less likely to die, although this could be an effect of the way in which testing has increased the size of the denominator; and there is no evidence suggesting that patients with longer periods since the onset of their sympthoms are more likelty to die.   

![Fixed Effect CFR by Entidad Grave](/EntidadGrave14.png)
![Fixed Effect CFR by Entidad No Grave](/EntidadNoGrave14.png)

The models can also include a fixed effect by state.

Finally, in this update I am able to provide, given that a third of the dataset comes from the metropolitan area of Mexico City, municipal level fixed effects for the Alcaldias and Municipalities in the metropolitan area of Mexico City. Those estimates only include patients admitted into the hospitals and clinics in Estado de Mexico and CDMX, and providing municipal fixed effects according to their place of residence.

![Fixed Effect CFR by Alcaldia](/AlcadldiaCDMX14.png)

Files labeled with no.14 have the updated information from June 11 with 381,129 patients

Files labeled with no.11 have the updated information from May 23 with 215,656 patients

En un importante ejercicio de transparencia, esencial en la actual crisis, las autoridades 
sanitarias del Gobierno Federal en México liberaron el 14 de abril una base de datos llamada 
“Información referente a casos COVID-19 en México”. (1) Esta información es presumiblemente la 
base de datos más completa de las pruebas de COVID19 realizadas hasta ese momento, misma 
que utiliza el gobierno para entender el proceso epidemiológico que nos aqueja. En ese 
momento la información actualizada tenía, según las autoridades, 5,014 casos identificados 
como positivos, 332 defunciones atribuibles a esta enfermedad, y las “más de 37 mil personas 
que hasta el momento han sido ya estudiadas y entradas a un protocolo de investigación de 
todos estos casos en relación a COVID-19 en México”. (2) 

Los investigadores rápidamente aprovecharon la nueva información para ofrecer 
visualizaciones de diversos tipos, mostrando los patrones de dispersión territorial. Se puede 
estudiar uno de los principales retos que se enfrentará durante las próximas semanas por 
motivo de la fragmentación del sistema de salud. Posiblemente la reticencia más grande de las 
autoridades de salud pública para liberar esta información de los casos individuales de pruebas 
de COVID19 que se han realizado tiene que ver con la posibilidad de una interpretación o uso 
poco cuidadoso de la información por analistas que no son expertos en epidemiología.

Es importante aclarar que el ejercicio estadístico no permite conocer la causalidad de los 
procesos de salud pública involucrados en esta epidemia, pues como se repite con frecuencia, 
una correlación no es evidencia de causación. El ejemplo más claro es pensar en el coeficiente 
estadístico que se obtiene en una estimación que incluya la mortalidad como variable 
dependiente y el uso de entubamiento o el ingreso a las unidades de terapia intensiva: esas 
variables si se colocan como variables independientes se correlacionan con la muerte en forma 
positiva, pero claramente no son una CAUSA que aumente la probabilidad de una defunción. 
La razón por la que aparecen correlacionadas con la muerte es porque reflejan una variable 
omitida en el modelo, a saber, la gravedad del padecimiento de la paciente, que si se encuentra 
muy enferma, requiere de intervenciones más radicales. Dado que los pacientes más graves 
tienen una mayor probabilidad de morir, el entubamiento o la unidad de terapia intensiva 
capturan estadísticamente esa relación, pero no son en sí mismas causas de muerte. Si se 
realizara un experimento controlado, con un grupo de control, y uno de tratamiento asignado 
aleatoriamente, que recibiera la intervención médica, se demostraría contundentemente que la 
intervención médica salva vidas y se podría estimar la magnitud del efecto. Por lo tanto aunque 
la relación entre intubación o terapia intensiva debería ser negativa en un modelo causalmente 
identificado, este es exactamente el signo contrario que el que arroja una estimación simplista 
de carácter más bien inductivo. 

No existe una manera contundente pare resolver el problema de variables omitidas. Pero se 
pueden realizar algunos procesos estadísticos, siempre sujetos a error, que permitan atenuar 
este problema mejorando el diseño de un estudio estadístico, buscando restringir la 
comparación entre casos dentro de la base de datos. Por ejemplo, se podrían utilizar sólo los 
datos de pacientes especialmente enfermos, o se puede realizar un ejercicio de matching, que 
se puede traducir como un apareamiento, en que se busca comparar sólo casos de 
entubamiento que sean una especie de experimento natural, a saber, casos que podrían haber 
sido entubados en un escenario contra-factual, pero que no fueron entubados, por razones 
exógenas al padecimiento. 

(1) La base está disponible en la siguiente liga (consultada el 17 de abril): 
https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico
Las características y fuente de la información según el portal de datos abiertos:
Información del Sistema de Vigilancia Epidemiológica de Enfermedades Respiratoria Viral, que informan 
las 475 unidades monitoras de enfermedad respiratoria viral (USMER) en todo el país de todo el sector 
salud (IMSS, ISSSTE, SEDENA, SEMAR, ETC).
Nota: Datos preliminares sujetos a validación por la Secretaría de Salud a través de la Dirección General 
de Epidemiología. La información contenida corresponde únicamente a los datos que se obtienen del 
estudio epidemiológico de caso sospechoso de enfermedad respiratoria viral al momento que se 
identifica en las unidades médicas del Sector Salud.
De acuerdo al diagnóstico clínico de ingreso, se considera como un paciente ambulatorio u hospitalizado. 
La base no incluye la evolución durante su estancia en las unidades médicas, a excepción de las 
actualizaciones a su egreso por parte de las unidades de vigilancia epidemiológica hospitalaria o de 
jurisdicciones sanitarias en el caso de defunciones.

(2) José Luis Alomía Zegarra, Director General de Epidemiología, versión esteneográfica de la conferencia de prensa 
del 13 de abril (https://www.gob.mx/presidencia/es/articulos/version-estenografica-conferencia-de-prensa-
informe-diario-sobre-coronavirus-covid-19-en-mexico-240239?idiom=es).

Latest commit
523a0c7
3 minutes ago
