
# Los nombres de los objetos tienen mucha  importancia en R, por lo que se deberán aplicar las siguientes reglas 

# Ficheros

# Los nombres de los ficheros deben ser autoexplicativos, es decir que deben indicar que hacen 
# Lectura_datos.R # Está bien escrito, se sabe lo que hace
# LecturaDatos.R # Está bien escrito, se sabe lo que hace

# leer.R # Es muy genérico
# algo.R # No es autoexplicativo

# El nombre debe estar formado por una única cadena: si están formados por varias 
# palabras, únalas con un signo de subrayado como el guión bajo.

# Lectura_datos.R # Está bien escrito, dos palabras, incluyen un guión bajo
# Lectura datos.R # Está mal escrito, dos palabras, incluye un espacio

# Algo a tener en cuenta es que siempre el código que se guarde debe tener la extensión .R

# ---------------------------------------------------
# Objetos 
# ----------------------------------------------------

# Los nombres deben ser informativos y concisos
# Ej

abbreviate('frutas', 3)

frt <- c('manzana', 'cereza', 'papaya', 'melon')
prc <- c(2, 5, 4, 8)

# Con el objeto anterior se abrevio la palabra frutas a tres letras con consonantes, esto es lo más sugerido para poder tener un orden y entender lo que guardan todos los objetos a utilizar

# Los nombres para variables deben ser sustantivos, como las frutas, y para las  funcioens a crear deben ser verbos.

# Los nombres de las variables deben ir en minúsculas. Se pueden unir varias palabras con el signo del subrayado "_" o ocn notaicon húngara (palabraPalabra). 

# Los nombres de las variables no deben llevar "."

# COnveiene evitar nombres delas funciones y palabrasreservadas de R

# ---------------------------------------------------
# Sintaxis
# ----------------------------------------------------

# Bien: 
a = 7
a <- 7

dplyr::select()

# Mal 
a<-7
dplyr :: select ()

# La coma nunca lleva un espacio delante y siempre lleva un espacio detrás
x <- c(10, 20, 32, 22, 28, 69) # Bien
c(10,20,32,22,28,69) # Mal

# Bien
mean(x, na.rm = TRUE)

# Mal 
mean(x,na.rm=TRUE)
mean(x , na.rm = TRUE)

# ---------------------------------------------------
# Comandos
# ---------------------------------------------------

# Funciona
m <- mean(x); s <- sd(x)

# Más elegante 
m <- mean(x)
s <- sd(x)

# En la consola se comienza a escribir despues del prompt (">"), que es una invitación a
# escribir. El simbolo del apuntador es > y cuando se acaba la línea y no se ha completa
# do la expresión el prompt cambia a "+", indicando que algo falta 

sum(
  12,13
  )

# ---------------------------------------------------
# Expresiones
# ---------------------------------------------------

# Calcule la longitud de una circunferencia de radio 7 cm 
2 * pi * 7
# El objeto pi ya esta guardado de manera predeterminada

# Asignaciones
# Un comando de asignación, que utiliza el operador <- (asignment operator) es una orden
# que se le da a R, para evaluar una expresión y pasar su valor a una variable, pero no
# no la imprime. Por ejemplo:

x <- 2

# Para que el codigo sea más legible se aconseja dejar un espacio antes y después del op# erador de asignación. No puede haber ning[un espacio entre el signo menor (<) y el 
# signo menos (-)

x > x
print(x)
x <- 2 
show(x)

# Se pueden utilizar asignaciones múltiples, que se van evaluando y ejecutando de 
# derecha a izquierda, como por ejemplo:

x <- y <- z <- 2
x
y
z

# En general, las asignaciones múltiples no deben utilizarse, ya que complican la 
# legibilidad del código 

# Otro comando que puede ser útil en alguna ocasión es el que permite recuperar el
# último valor de una expresión: tecleando ".Last.value", se obtiene el valor de la 
# expresión evaluada en el último lugar. Por ejemplo

7 + 435.36 ^ 2
a <- .Last.value
a <- 7 + 435.36 ^ 2 # Es igual a la linea 126

# ---------------------------------------------------
# Objetos
# ---------------------------------------------------

# Los objetos en R pueden ser nombrados por palabras formados por
# (1) Letras (mayúsculas, minúsculas e incluso acentuadas
# (2) Digitos del 0 al 9 (pero no en posición inicial)
# (3) El . que se suele utilizar para separar palabras compuestas, pero que no debiera
# estar en posición inicial ya que las variables combienan con un . suelen ser palabras
# utilizadas internamente en el programa 
# (4) El signo de subrayado _ se puede utilizar para separar palabras

# Algunos ejemplos
IMC <- 23.45
Imc <- 24.00
imc <- 24.56
a3 <- 7
a3.inicio <- 2
IndiceMasaCorporal <- 23.76
indice_masa_corporal <- 23.76

# Son incorrectas
.IMC <- 23.45
3a <- 24.00
indice masa corporal <- 23.76
indice-masa-corporal <- 23.76
indice#masa#coporal <- 23.76
indice-masa!coporal <- 23.76

# Existen algunas palabras reservadas las cuales no pueden ser usadas como nombres
# de objetos
break 
else 
FALSE
for
function
if
in
Inf
NA
NaN
next
NULL
repeat
TRUE
while

# Palabras que deben evitarse 
c
I
range
t
C
length
rank
T
D
mean
return
time
diff
pi
month.abb
s
tree
F
q
sd
var

# Segun Chambers, "To understan computations in R, two slogans are helpul:
# (1) Everything that exists is an objetoc
# (2) Everything that happens is a function call
