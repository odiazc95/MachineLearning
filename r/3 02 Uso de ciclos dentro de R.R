

rm(list = ls()) # Borro el ambiente de trabajo

# Uso de los ciclos dentro de R
# For y lapply
library(readxl)

# Listar los archivos
fles <- list.files('../datos/tbl/cultivos', full.names = TRUE, pattern = '.xlsx$')
# fles <- list.files('../datos/tbl/cultivos', full.names = TRUE, pattern = '^caf')

fles

# Leer los archivos
banano <- read_excel(fles[1])
cacao <- read_excel(fles[2])
cafe <- read_excel(fles[3])
frijol <- read_excel(fles[4])
lulo <- read_excel(fles[5])
tomate <- read_excel(fles[6])

# Como hacer un filtro para un objeto tipo vector
grep('banano', fles)
banano <- grep('banano', fles, value = TRUE)
banano <- read_excel(banano)

# Uso de ciclo basico 
for(i in 1:10){
  print(i)
}

for(i in 1:20){
  print(i + 1)
}

for(i in seq(0, 80, 20)){
  print(i)
}
                                                                

# Aplicacion de un for para la lectura de las tablas
tablas <- list()

for(i in 1:length(fles)){
  tablas[[i]] <- read_excel(fles[i])
}

fles
basename(fles)
tablas

colnames(tablas[[1]])
colnames(tablas[[2]])
colnames(tablas[[3]])

# Revisar los nombres de las columnas, usando el for 
for(j in 1:length(tablas)){
  print(j) 
  print(colnames(tablas[[j]]))
}

# Los nombrs de las columas son los mismos para todas las tablas, con lo cual 
# podremos cambiarlas de manera automatica mediante un for, 
# recordemos que los nombre de las columnas no deben tener caracteres espaciales
# como espacios, slash y parentesis

tablas
nmes <- colnames(tablas[[1]])
# nmes <- gsub('(', '', nmes)
nmes <- gsub('\\(', '', nmes)
nmes <- gsub(')', '', nmes)
nmes <- gsub(' ', '_', nmes)
nmes <- gsub('/', '_', nmes)

# Ahora bien cambiar los nombre de las columnas
# Aqui veremos el concepto del lapply, funciona algo similar a un for 

# colnames(tablas[[1]]) <- nmes
# colnames(tablas[[2]]) <- nmes
# colnames(tablas[[3]]) <- nmes


tablas_2 <- lapply(tablas, function(x){colnames(x) <- nmes; return(x)})

# Otra posible opcion
tablas_2 <- lapply(1:length(tablas), function(x){
  colnames(tablas[[x]]) <- nmes
  return(tablas[[x]])
})

# Ahora nos planteamos la pregunta, cómo conocer la cantidad de años que hay dentro de cada tabla

tablas_2
anios <- list()
for(i in 1:length(tablas)){
  anios[[i]] <- unique(tablas_2[[i]]$Año)
}

# Ahora crear un dataframe con el nombre del cultivo de cada tabla y la cantidad de anios 
dfrm <- list()

for(i in 1:length(tablas)){
  
  print(i)
  crop <- unique(tablas_2[[i]]$Producto)
  year <- unique(tablas_2[[i]]$Año)
  dfrm[[i]] <- data.frame(cultivo = crop, anios = year)
  
}

# Ahora si quisieramos tener estas tablas aunadas en una unica tabla podemos hacer uso de la
# funcion rbind

tbls <- rbind(dfrm[[1]], dfrm[[2]])
tbls <- rbind(tbls, dfrm[[3]])
tbls <- rbind(tbls, dfrm[[4]])
tbls <- rbind(tbls, dfrm[[5]])
tbls <- rbind(tbls, dfrm[[6]])

# Pero bien, ahora la cuestion es que si fueran unas 100 tablas, seria algo no muy optimo
# hacer el uso de rbind con muchas lineas, con lo cual se puede esto automatizar de la siguiente manera
# La funcion do.call, permite aplicar una misma funcion a un listado de objetos
tbls <- do.call(what = rbind, args = dfrm)

# ¿Cuál es el departamento que mayor área cultiva de cada producto, esto para el año más 
# reciente, de los cuales se tienen datos?

tablas_2
tablas_smm <- list()

for(i in 1:length(tablas_2)){
  
  print(i)
  tablas_smm[[i]] <- tablas_2[[i]]
  yr_max <- max(tablas_smm[[i]]$Año)
  tablas_smm[[i]] <- tablas_smm[[i]][which(tablas_smm[[i]]$Año == yr_max),]
  tablas_smm[[i]] <- tablas_smm[[i]][order(-tablas_smm[[i]]$Area_hec),]
  tablas_smm[[i]] <- tablas_smm[[i]][1,]
  
}

# Ahora unir este objeto de tablas_smm que es tipo lista, 
# en un único objeto que sea tipo dataframe

tablas_smm <- do.call(what = rbind, args = tablas_smm)
write.csv(tablas_smm, '../output/tbl/dptos_major_area_crops.csv', row.names = FALSE)




