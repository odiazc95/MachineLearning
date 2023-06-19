

# Conociendo objetos dentro de R
v_number <- c(1, 2.4, 4.5, 10)
v_character <- 'Curso SIG con R'
v_vector <- c('Arroz', 'Papa', 'Cebolla', 'Tomate', 'Lulo')
v_vector[2]
v_integer <- c(1L, 6L, 10L) # La L se utiliza para indicar que el elemento es un entero
class(v_integer)
v_integer <- c(1, 6, 10) 
class(v_integer)
v_boolean <- c(TRUE, FALSE, T, F) # Estos objetos son lógicos

# Acceder a posiciones dentro de Vectores 
position <- 5
v_vector[position] # Position sería un número entre 
v_vector[3]

# Manipulación de vectores 
v_vector[1] # extrae el primer elemento 
v_vector[length(v_vector)] # extrae el último 
v_vector[i] # extrae el elemento que está en la posicion i 
v_vector[-i] # extrae todos menos el elemento en posición i
v_vector[c(1, 3, 4)] # extrae los elementos en las posiciones 1, 3 y 4
v_vector[-c(1, 3, 4)] # Extrae todos menos los elementos en la posicion 1, 3, y 4
v_vector[grep('Cebolla', v_vector)] # extrae el elemento cuyo nombre coincide con 'Cebolla'
v_vector[i] <- 'Pepino' # Cambio el valor del elemento en posicion i por la palabra pepino 
v_vector[c(3, 4)] <- c(1, 2) # Los elementos en posicion 3 y 4 cambiarn a 1 y 2
which(v_vector == 'Tomate') # Pregunta que elmeento cumple con la condicion de igual a tomate

# Funcion grep
v_vector
grep('Papa', v_vector)
grep('Papa', v_vector, value = TRUE)

# Function which
which(v_vector == 'Lulo')
which(v_vector %in% c('Papa', 'Tomate'))

# Creacion de listas con distintos tipos de elementos - Listas no nombradas
x <- list(1:5, 
          "Mauricio", 
          c(TRUE, FALSE, TRUE), 
          c(1.5, 2.23), 
          list(1, "a"))

length(x)

x

str(x)

x[[5]][[2]]

# Listas nombradas
x <- list(elem_1 = 1:5, 
          elem_2 = "Mauricio", 
          elem_3 = c(TRUE, FALSE, TRUE), 
          elem_4 = c(1.5, 2.23), 
          elem_5 = list(1, "a")) 

# Acceder a las posiciones dentro de una lista 
x[[2]] # A diferencia del vector, para acceder a una ubicacion dentro de la lista se usan dos corchetes [[]]

# Creacion de dataframe 
ventas <- data.frame(meses = c('Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'),
                     ventas_a = rnorm(12, mean = 300, sd = 23), 
                     ventas_b = rnorm(12, mean = 340, sd = 34),
                     ventas_c = rnorm(12, mean = 400, sd = 20))

dim(ventas)
ncol(ventas)
nrow(ventas)

ventas[,3]
ventas[,c(1, 2)]
ventas[3:4,1:2]
ventas[c(1, 3, 5), 1:3]

# Creacion de matrix 
m_matrix <- matrix(c(0.2, 0.3, 0.5, 0.2, 0.6, 0.7, 0.9, 1.1, 1.4), byrow = 3, nrow = 3, ncol = 3)
