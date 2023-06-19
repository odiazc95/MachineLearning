
# Componentes de una funciones
# Las funciones en R tienen un comportamiento similar a las funciones en Matemáticas, 
# en que toman uno o más argumentos (inputs) y producen uno o más resultados (outputs). 
# Segun Chambers: Writing fucntions is the natural way to expand what you can do with the system.

# Una función se compone de tres partes: 
# 1. Argumentos 
# 2. Cuerpo
# 3. Environment 

# 1. Argumentos
# Son la lista de argumentos que controlan como se puede llamar a la función. 
# Explora la función formals, la cual devuelve una lista con todos los argumentos que utiliza
# la función. ¿Cuáles son los arguementos de la función list.files? 

formals(list.files)

list.files(path = '../datos/tbl/cultivos', 
           pattern = '.xlsx$', #'.tif$' 
           all.files = FALSE, 
           full.names = TRUE)
 
# 2. Cuerpo 
# El cuerpo de una función es el código que hay dentro de la función, es decir, todo lo encerrado entre
# las dos llaves. Este se explora con la función body. ¿Cuál es el cuerpo de la función shapiro.test
# Esta función shapiro.test pertenece a la prueba estadística shapiro wilk,
# la cual esc omunmente utilizada para identificar si un set de datos se comporta bajo una distribución normal
body(shapiro.test)
body(list.files)

# 3. Environment (Entorno)
# Es el mapa que indica donde estan ubicadas las variables de la función. Se explora fon la función 
# environment
environment(shapiro.test)

library(raster)
environment(raster)

extract_by_mask <- function(rst, lim){
  
  # Crop, corte del extent para el limite
  rsl <- raster::crop(rst, lim)
  
  # Mask, corta la geometria del limite
  rsl <- raster::mask(rsl, lim)
  return(rsl)
  
}
extractMask <- function(){}
  
# Escritura de funciones
# Para crear una función debera tener en cuenta 10 aspectos. 
# 1. Nombre de la función
# 2. Operador de la asignación <- / =
# 3. La declaración function
# 4. Argumentos
# 5. Llave de aperturas
# 6. Comprobación de condiciones
# 7. Cuerpo de la función
# 8. Resultado de la función
# 9. Llave de cierre
# 10. Documentación

# Creación de una función que eleve al cuadraro un número y lo imprima en pantalla 

square <- function(x){
  
  print(x)
  y <- x ^ 2
  print(y)
  return(y)
}


two <- square(2)
four <- square(4)
twenyfive <- square(25)

# Crecion de funcion para convertir de grados fahrenheit a celcius
frg_cls <- function(x){
  y <- x - 32 * (5/9)
  return(y)
} 

test_conversion <- frg_cls(58)

# Ahora vamos a optimizar ciertos procesos realizados en codigos anterior, incluyendo 
# varios procesos dentro de una unica funcion 
# esto hara un poco mas legible el codigo 

library(readxl)

# Listar los archivos
fles <- list.files('../datos/tbl/cultivos', full.names = TRUE, pattern = '.xlsx')
fles

tbls <- list()
for(i in 1:length(fles)){
  tbls[[i]] <- read_excel(fles[i])
}

# Creacion de funcion para cambiarle el nombre de las columnas a todas y cada una de las tablas
change_colnames <- function(tbl){
  
  print('Inicio funcion')
  nmes <- colnames(tbl)
  nmes <- gsub('\\(', '', nmes)
  nmes <- gsub(')', '', nmes)
  nmes <- gsub(' ', '_', nmes)
  nmes <- gsub('/', '_', nmes)
  colnames(tbl) <- nmes
  return(tbl)
  
}

formals(change_colnames)
body(change_colnames)
environment(change_colnames)

for(i in 1:length(tbls)){
  tbls[[i]] <- change_colnames(tbl = tbls[[i]])
}

tbls

# Ahora crear una función que genere el resumen de la tabla para todos los años
# Se recomienda, como se había mencionado antes, incluir el nombre del cultivo

get_summary <- function(tbl){
  
  # tbl <- tbls[[1]]
  
  dpt <- unique(tbl$Departamento)
  smm <- list()
  
  for(i in 1:length(dpt)){
    
    sub <- tbl[which(tbl$Departamento == dpt[i]),]
    are <- mean(sub$Area_hec)
    prd <- mean(sub$Produccion_ton)
    rdt <- mean(sub$Rendimiento_hec_ton)
    smm[[i]] <- data.frame(dpto = dpt[i], producto = unique(sub$Producto),
                           area = are, produccion = prd, rdto = prd)
    
  }
  
  smm <- do.call(what = rbind, args = smm)
  
  # Redondear a cero digitos
  smm$area <- round(smm$area, digits = 0)
  smm$produccion <- round(smm$produccion, digits = 0)
  smm$rdto <- round(smm$rdto, digits = 0)
  
  print('Fin de la función')
  return(smm)
  
}

smmr <- list()

for(i in 1:length(tbls)){
  smmr[[i]] <- get_summary(tbl = tbls[[i]])
}

smmr <- do.call(what = rbind, args = smmr)
write.csv(smmr, '../output/tbl/smmr_dpto_cultivos.csv', row.names = FALSE)

# Hacer una funcion que exporte un gráfico que ilustre el top 5 de los departamentos 
# con mayor área cosechada de cada cultivo 

cultivos <- unique(smmr$producto)

make_graph <- function(cultivo){
  
  # cultivo <- cultivos[1]
  
  sub <- smmr[which(smmr$producto == cultivo),]
  sub <- sub[order(-sub$area),]
  sub <- sub[1:5,]
  
  library(stringr)
  
  png(filename = paste0('../png/graphs/area_top_', tolower(cultivo), '.png'),
      units = 'in', width = 14, height = 9, res = 300)
  barplot(sub$area, 
          names.arg = sub$dpto,
          main = paste0('Área cosechada - ', str_to_title(cultivo)), 
          las = 1)
  dev.off()
  print('Hecho!')
  
}

# Aplicación de la función lapply
lapply(X = cultivos, FUN = make_graph)





