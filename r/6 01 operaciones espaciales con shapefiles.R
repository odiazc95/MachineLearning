

# Carga de librerias 
# install.packages('pacman')
library(pacman)
pacman::p_load(raster, rgdal, rgeos, stringr, sf, tidyverse, gtools)

# install.packages("remotes")
library(remotes)
# remotes::install_github("gsk3/taRifx.geo")
library(taRifx)
library(taRifx.geo)

# Primero haremos operaciones con el uso de la libreria raster, el tipo de objeto 
# Spatial 

colm <- raster::shapefile('../datos/shapefile/valle/LIMITE_DEPARTAMENTAL.shp')

# Seleccion unicamente del dpto de Valle del Cauca
vlle <- colm[colm@data$NOMBRE_DEP == 'VALLE DEL CAUCA',]
asn1 <- raster::shapefile('../datos/shapefile/valle/ASENTAMIENTOS_FV.shp')
asn2 <- raster::shapefile('../datos/shapefile/valle/ASENTAMIENTOS_VALLE.shp')

plot(asn1, col = 'red')
plot(asn2, col = 'green', add = TRUE)
plot(vlle, add = TRUE)

# Vemos que tenemos asentamientos tanto del Valle del Cauca, como de los alrededores
# Con lo cual podemos hacer la union de ambos shapefile para tener un unico shape 
# con los cascos asentamientos 

asn3 <- rbind(asn1, asn2)

colnames(asn1@data)
colnames(asn2@data)
head(asn1@data)
head(asn2@data)

colnames(asn2@data)[2] <- 'NOMBRE'

asn1 <- asn1[,c('NOMBRE', 'CATEGORIA')]
asn2 <- asn2[,c('NOMBRE', 'CATEGORIA')]
asn3 <- rbind(asn1, asn2)

plot(asn3)

asn1

# Ahora si queremos agregarle el nombre del municipio a cada centro poblado, hacemos
# un intersect 
mpios <- raster::shapefile('../datos/shapefile/admon/MGN_MPIO_POLITICO.shp')
crs(mpios)
crs(asn3)

# Ahora como realizar un dissolver de los municipios, obteniendo solo el limite departamental
dptos <- aggregate(mpios, 'DPTO_CNMBR')
dptos@data$DPTO_CNMBR
dptos@data$DPTO_CNMBR <- iconv(dptos@data$DPTO_CNMBR, from = 'UTF-8', to = 'latin1')

# Hacemos la proyección espacial
asn3 <- spTransform(x = asn3, CRSobj = crs(mpios))
asn3 <- raster::intersect(asn3, mpios)
asn3@data %>% head()

# Rios ----
rios <- raster::shapefile('../datos/shapefile/valle/DRENAJE_SENCILLO.shp')
plot(rios)

rios
crs(rios)
rios.bffr <- raster::buffer(x = rios, width = 30, dissolve = FALSE) #Diferencia entre dissolve = TRUE & dissolve = FALSE
plot(rios)
plot(rios.bffr)

rios.bffr

# Calculo de la longitud de estos ríos
rios
rios.dist <- taRifx.geo::lineDist(rios, varname = 'distance')
head(rios.dist@data)
rios.dist@data$dist_km <- round(rios.dist@data$distance / 1000, 1)

# Cálculo de la distancia total del os rios 
sum(rios.dist@data$dist_km) # 20390 km

# Ahora calcularemos el area de los asentamientos del Valle del Cauca
head(asn3@data)

asn2@data$area_mt <- raster::area(asn2)
head(asn2@data)
asn2@data$area_ha <- asn2@data$area_mt / 10000
plot(asn2)

sum(asn2@data$area_ha)
raster::shapefile(rios.bffr, '../output/shp/rios_bffr_sp.shp')

# Incendios forestales para Chile 
library(foreign)
fire <- read.dbf('../datos/tbl/fire/coordinates_fire.dbf')
fire <- as_tibble(fire)

# Tabla a shapefile
coordinates(fire) <- ~ lon + lat
plot(fire)
crs(fire) <- crs(mpios)

# Descarga de los limites politico administrativos de Chile
chle <- raster::getData(name = 'GADM', country = 'CHL', level = 1)
plot(chle, add = TRUE)

# Ahora queremos conocer cuál es el nombre de cada departamento en el que se encuentra cada inendio 
chle
fire_chle <- raster::intersect(fire, chle)
fire_chle
fire_chle@data$NAME_1

# Ahora realizemos el conteo 
count <- table(fire_chle@data$NAME_1)
count <- as.data.frame(count)
names(count) <- c('NAME_1', 'Freq_fire')
  
chle <- sp::merge(x = chle, y = count, by = 'NAME_1')
spplot(chle, 'Freq_fire')

# Guardemos este shapefile, y luego lo utilizaremos para realizar un mapa 
shapefile(chle, '../output/shp/fire_count.shp')

# Ahora haremos todo esto mismo con la libreria sf ------------------------
rm(list = ls())

colm <- sf::st_read('../datos/shapefile/valle/LIMITE_DEPARTAMENTAL.shp')
vlle <- dplyr::filter(colm, NOMBRE_DEP == 'VALLE DEL CAUCA')
plot(st_geometry(vlle))

asn1 <- sf::st_read('../datos/shapefile/valle/ASENTAMIENTOS_FV.shp')
asn2 <- sf::st_read('../datos/shapefile/valle/ASENTAMIENTOS_VALLE.shp')

plot(st_geometry(asn1))
plot(st_geometry(asn2))

plot(st_geometry(asn1), col = 'red', border = 'red')
plot(st_geometry(asn2), col = 'green', border = 'green', add = TRUE)

colnames(asn2)[2] <- 'NOMBRE'

asn1 <- dplyr::select(asn1, NOMBRE, CATEGORIA)
asn2 <- dplyr::select(asn2, NOMBRE, CATEGORIA)
asn3 <- rbind(asn1, asn2)

mpios <- st_read('../datos/shapefile/admon/MGN_MPIO_POLITICO.shp')

# Ahora como realizar un dissolver de los municipios, obteniendo solo el limite departamental
mpios <- mpios %>% filter(DPTO_CNMBR %in% c('VALLE DEL CAUCA', 'CAUCA', 'HUILA', 'TOLIMA', 'RISARALDA', 'QUINDIO', 'CHOCÓ'))
dptos <- mpios %>% group_by(DPTO_CNMBR) %>% dplyr::summarise(count = n()) %>% ungroup()
dptos

rios <- sf::st_read('../datos/shapefile/valle/DRENAJE_SENCILLO.shp')
rios.bffr <- sf::st_buffer(x = rios, dist = 30)
plot(st_geometry(rios.bffr))

st_length(rios.bffr) %>% max()
rios <- mutate(rios, length = as.numeric(st_length(rios)))
rios <- mutate(rios, length = length / 1000)
rios <- mutate(rios, length = round(length, 1))

rios

rios.bffr <- mutate(rios.bffr, area = as.numeric(st_area(rios.bffr)))
rios.bffr <- mutate(rios.bffr, area = area / 10000)
rios.bffr <- mutate(rios.bffr, area = round(area, 1))

st_write(obj = rios.bffr, dsn = '../output/shp', layer = 'rios_bffr_sf', driver = 'ESRI Shapefile')

fire <- read.dbf('../datos/tbl/fire/coordinates_fire.dbf')
fire <- as_tibble(fire)
fire <- st_as_sf(x = fire, coords = c('lon', 'lat'), crs = st_crs(4326))

fire
plot(st_geometry(fire))

chle <- raster::getData(name = 'GADM', country = 'CHL', level = 1)
chle <- st_as_sf(chle)

# Interseccion
fire2 <- st_intersection(fire, chle)
count <- fire2 %>% pull(NAME_1) %>% table() %>% as.data.frame() %>% setNames(c('NAME_1', 'Freq_fire'))
chle <- inner_join(chle, count, by = 'NAME_1')
chle %>% dplyr::select(Freq_fire) %>% plot()
st_write(chle, '../output/shp/fire_count_sf.shp')








