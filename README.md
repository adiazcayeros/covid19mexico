# covid19mexico
Analysis of covid19 individual level cases and tested patients 

Since April 14 I have been keeping track of the data released by the Federal Government of Mexico of
information regarding COVID-19 tests for patients seeking care in the national health system, including
both public and private hospitals and clinics. The database has been growing very quickly, as the 
testing capacity of the Mexican government has been ramped up. 

As or May 23 the data includes almost 216 thousand cases that form the basis of study for the federal 
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

![CFR Age and Gender](/Demography11.png)

Files labeled with no.11 have the updated information from May 23 with more than 215,656 patients

En un importante ejercicio de transparencia, esencial en la actual crisis, las autoridades 
sanitarias del Gobierno Federal en México liberaron el 14 de abril una base de datos llamada 
“Información referente a casos COVID-19 en México”. (1) Esta información es presumiblemente la 
base de datos más completa de las pruebas de COVID19 realizadas hasta ese momento, misma 
que utiliza el gobierno para entender el proceso epidemiológico que nos aqueja. En ese 
momento la información actualizada tenía, según las autoridades, 5,014 casos identificados 
como positivos, 332 defunciones atribuibles a esta enfermedad, y las “más de 37 mil personas 
que hasta el momento han sido ya estudiadas y entradas a un protocolo de investigación de 
todos estos casos en relación a COVID-19 en México”. (2) 


![CFR por Comorbilidad](/Comorbilidad11.png)

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

![CFR by Sector Grave](/SectorGrave11.png)
![CFR by Sector No Grave](/SectorNoGrave11.png)

No existe una manera contundente pare resolver el problema de variables omitidas. Pero se 
pueden realizar algunos procesos estadísticos, siempre sujetos a error, que permitan atenuar 
este problema mejorando el diseño de un estudio estadístico, buscando restringir la 
comparación entre casos dentro de la base de datos. Por ejemplo, se podrían utilizar sólo los 
datos de pacientes especialmente enfermos, o se puede realizar un ejercicio de matching, que 
se puede traducir como un apareamiento, en que se busca comparar sólo casos de 
entubamiento que sean una especie de experimento natural, a saber, casos que podrían haber 
sido entubados en un escenario contra-factual, pero que no fueron entubados, por razones 
exógenas al padecimiento. 

![Residual CFR by Entidad Grave](/EntidadGrave11.png)
![Residual CFR by Entidad No Grave](/EntidadNoGrave11.png)

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
