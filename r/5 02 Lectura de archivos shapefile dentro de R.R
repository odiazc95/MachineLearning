
# Cargar las librerías
require(raster)
require(rgeos)
require(gtools)
require(rgdal)
require(fs)
require(tidyverse)
# install.packages('sf')
require(sf)

# Cargar los datos
znfc <- raster::shapefile('../datos/shapefile/zonificacion/Zonificacion_hidrografica_2013.shp')
adm1 <- raster::shapefile('../datos/shapefile/admon/MGN_DPTO_POLITICO.shp')

# Plotting 
windows()
par(mfrow = c(1, 2))
plot(znfc, main = 'Cuencas hidrograficas')
plot(adm1, main = 'Limite administrativo')
par(mfrow = c(1, 1))

# Listar una carpeta con varios archivos shapefile - Estos son datos de cartografia base del Valle del Cauca
fles <- fs::dir_ls('../datos/shapefile/valle', regexp = '.shp$')

# Camino 1
for(i in 1:length(fles)){
  print(i)
  plot(shapefile(fles[i]), main = i)
}

# Camino 2
shpf <- purrr::map(.x = fles, .f = shapefile)

# Camino 3
shpf <- lapply(fles, shapefile)

# Otra libreria que es mas reciente y mejora un poco el manejo de los atributos dentro de R, es la libreria SF 
# install.packages('sf')
library(sf)

fles
znfc <- sf::st_read('../datos/shapefile/zonificacion/Zonificacion_hidrografica_2013.shp')
adm1 <- sf::st_read('../datos/shapefile/admon/MGN_DPTO_POLITICO.shp')

plot(znfc)
plot(st_geometry(znfc))

plot(adm1)
plot(st_geometry(adm1))

# install.packages('mapsf')
library(mapsf)
mapsf::mf_map(adm1)
mf_map(znfc)

fles
shpf <- map(fles, st_read)


