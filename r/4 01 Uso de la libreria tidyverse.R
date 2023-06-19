
# Instalacion de librerias
install.packages('tidyverse')
library(tidyverse)
library(readxl)

# Lectura de tablas dentro de R
fles <- list.files('../datos/tbl/cultivos', full.names = TRUE)

# Uso de un ciclo basico para la lectura de todas las tablas 
tbls <- list()
for(i in 1:length(fles)){
  tbls[[i]] <- read_excel(fles[i])
}

# Ahora bien si quisieramos usar menos cantidad de carácteres y hacer un poco más corto 
# el proceso de lectura de estas tablas, podemos usar la función map de la libreria 
# purrr, la cual hacer parte del entorno de tidyverse

tbls <- map(.x = fles, .f = read_excel)
tbls[[1]]
# Como podemos ver, aquí se tiene una visualización previa de las primeras 10 filas 

class(tbls[[1]])

# El tipo de objeto es tbl_df, basicámente es un dataframe con el concepto de solo 
# permitirnos visualizar las primeras 10 filas, esto para hacernos la visualización 
# fácil, y además permitiéndonos ver el tipo de columna de cada una de ellas

# Para crear un dataframe usamos la función data.frame, y para crear un tibble se usa la función 
# tibble
data.frame(meses = month.abb, valores = 1:12)
dfm <- data.frame(x = 1:5, y = 1)
dfm$z <- dfm$x ^ 2

tibble(x = 1:5, y = 1, z = x^2 + y)
enframe(c(a = 5, b = 10))

# Ejemplo, usar la tabla de banano y seleccionar únicamente el año 2016

# Sin uso de la libreria 
bnno <- tbls[[1]]
bnno <- bnno[which(bnno$Año == 2016),]
bnno

# Pero con el uso de la libreria tidyverse, propiamente la función filter
bnno <- tbls[[1]]
bnno <- filter(bnno, Año == 2016)

# AQUI VAMOS --------------------------------------------------------------


# Ahora si quisieramos por ejemplo agregar cambiar a minúscula la columna Producto
# Uso de la librería base
bnno$Producto <- tolower(bnno$Producto)

# Ahora bien usando la librería dplyr del entorno tidyverse
bnno <- mutate(bnno, Producto = tolower(Producto))

# Ahora queremos agregar el porcentaje de contribución de cada departamento al área cosechada 
# Con el uso de la librería base
colnames(bnno) <- c('year', 'dpto', 'producto', 'area', 'prod', 'rdto', 'prod_ncnl', 'area_ncnl')
bnno$porc_area <- bnno$area / sum(bnno$area) * 100
head(bnno)
sum(bnno$porc_area)

# Con el uso de la libreria tidyverse
bnno <- mutate(bnno, porc_area = area / sum(area) * 100)
bnno

# Ahora si vemos hay una columan duplicda, propiamente area_ncnl y la que acabamos
# de crear que es porc_area
bnn2 <- bnno
bnn2 <- bnno[,-8]

# Con el uso de la libreria dplyr, función select
bnn2 <- bnno
bnn2 <- dplyr::select(bnn2, -porc_area)

# Ahora bien si quisieramos una unión entre las funciones select y muate
bnno <- tbls[[1]]
colnames(bnno) <- c('year', 'dpto', 'producto', 'area', 'prod', 'rdto', 'prod_ncnl', 'area_ncnl')
bnno <- filter(bnno, year == 2016)
bnno <- transmute(bnno, 
                  year, dpto, area, prod, rdto, 
                  area_porc = area/sum(area) * 100)

# Paso seguido, si vamos a crear por ejemplo un resumen del promedio de todo el periodo 
# de tiempo para todos y cada uno de los departamentos.

# Con la librería base
bnno <- tbls[[1]]
colnames(bnno) <- c('year', 'dpto', 'producto', 'area', 'prod', 'rdto', 'prod_ncnl', 'area_ncnl')
dpts <- unique(bnno$dpto)
unique(bnno$year)
vles <- NA

for(i in 1:length(dpts)){
  sub <- bnno[which(bnno$dpto == dpts[i]),]
  vles[[i]] <- mean(sub$area)
}

rslt <- data.frame(dpto = dpts, area = round(vles, 1))

# Ahora bien con el uso de la libreria dplyr
bnno <- tbls[[1]]
colnames(bnno) <- c('year', 'dpto', 'producto', 'area', 'prod', 'rdto', 'prod_ncnl', 'area_ncnl')
bnno

# Aquí se introduce el concepto del pipe (%>%)
# Este operador pipe es util para concatenar múltiples dplyr operaciones. 
# Ctrl + Shift + m
bnno %>% 
  group_by(dpto) %>% 
  dplyr::summarise(area = mean(area)) %>% 
  ungroup() %>% 
  arrange(dpto)

bnno %>% mutate_at(4:8, round, 0)
bnno %>% mutate_if(is.numeric, round, 0)

# Ahora bien si quisieramos pasar la tabla de wide (ancha) a long (larga) hacemos uso de la función gather

bnno <- bnno %>% gather(var, value, -c(year, dpto, producto))

# De otro lado, si quisieramos regrsar a la anterior organización, hacemos uso de la función spread
bnno %>% spread(var, value)


