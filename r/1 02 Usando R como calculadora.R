
g <- gc(reset = TRUE)
rm(list = ls())

# Suma
1 + 13
# Resta 
16 - 7
# Multiplicación 
14.0056 * 3.25
# División
16 / 2
# Potencia
7 ^ 3 

# Recorderis
# Dividiendo (D) partido por el vidisor (d) es igual al cociente (C) más el resto (R)
# D / d = C + R
11 / 4 # Division
11 %/% 4 # Cociente # Cociente parte entera
11 %% 4 # Resto (módulo)

# Ejercicio,  Calcule el índice de masa corporal (IMC) de un sujeto que pesa 78 kg y mide 173 cm. Como el 
# IMC es el cociente entre el peso (en kg) y el cuadrado de la talla (en m), se teclean estos
# y se obtieen que el IMPC es 26.06168 kg m^-2
78 / 1.73 * 2 # Potencia y división

# El cálculo del módulo tiene utilidad para saber si un número es par (módulo 0 al dividir el número por dos) 
# o impar (módulo 1 al dividir por 2); también para conocer si un númeo x es multiplo de otro y, en cuyo
# caso el módulo valdrá 0

# Ejemplo, ¿Es 54967 múltiplo de 11?
54967 %% 11 
# Sí, puesto que el módulo al dividir 54967 entre 11 es 0.

# Ejemplo aplicativo. 
# La clasificación de Berlín de la hipoxemia (2022) estableció tres categorías en base al cociente PaO2/FiO2;
# severa (min,100], (100,200] (200, 300]. Recientemente se ha publicado un trabajo [140] en el que 
# demuestran que el cociente en el día 1 respecto del cociente en el día 0 tiene mejor valor predictivo
# que la mortalidad a los 30 días de un síndrome de distrés respiratorio agudo. Con lo cual
# clasifique a un sujeto con PaO2 = 60 y FiO2 = 21%

# PaO2 es la presión arterios del oígeno
# FiO2 es la fracción inspirada de oxigeno

# R/ 
60/0.21 # Hipoxemia Leve

# ------------------------------------
# Funciones un poco mas avanzadas
# -------------------------------------

# celing(a) # Menor entero mayor que a
# floor(a) # Mayor entero menos que a
# round(a, d) # Redondeo a con d decimales 
# signif(a, d) # Presenta a con d digitos en notación científica 
# trunc(a) # Elimina los decimales de (a) hacia 0

# El redondeo puede ser hacia el menor entero superior con ceiling(), hacia el mayor entero inferior con floor(),
# ir eliminando decimales parcialmente con round(), o totalmente con trunc(). También se puede
# dejar un número de cifras significativas con signif(). La que más utilizaremos, sin ninguna duda, será la de redondeo.

# Ejemplo de aplicabilidad de esto 
# Dato un resultado x = 7.6459871, se pide
# a) Redondear x a tres decimales
# b) Calcular el menor entero superior a x
# c) Calcular el mayuor entero menor que x
# d) Eliminar todos los decimales de x 
# e) Presentar x con dos cifras significativas 

x <- 7.6459871
round(x, 3)
ceiling(x)
floor(x)
trunc(x)
round(x, 0)
signif(x, 2)

# En un ejercicio de cálculo del tamaño muestral se obtiene n = 127.13, ¿cuántos sujetos se necesitan?
# Como el número de sujetos no puede tener decimales, el resultado debe redondearse menor entero superior a n, 
# por tanto, utilizando la función ceiling. 

ceiling(127.13)

# Matemáticas generales

# El sistema R tiene implementada bastantes funciones matemáticas. 
# Ejemplo, para x = 7.6459871, calcule.
# a) ln de x
# b) raiz cuadrada de x 
# c) exponencia de x
# d) valor absoluto de x

# Solución:
log(x)
sqrt(x)
exp(x)
abs(x)

abs(-3.2)
