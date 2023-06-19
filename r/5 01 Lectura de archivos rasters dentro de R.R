

# Instalación de librerías 
install.packages('raster')
install.packages('rgeos')
install.packages('rgdal')
install.packages('gtools')

# Cargar las librerías
require(raster)
require(rgeos)
require(gtools)
require(rgdal)
require(fs) # Utilizada en una práctica anterior

# Leer el raster de bosque y no bosque para Colombia
bsq <- raster('../datos/raster/bosque/Bosque_NoBosque_2013/Geotiff/SBQ_SMBYC_BQNBQ_V5_2013.tif')
bsq

# Ver propiedades básicas de todo raster
extent(bsq)
crs(bsq)
res(bsq)

col <- raster::getData(name = 'GADM', country = 'COL', level = 1)
plot(bsq)
plot(col, add = TRUE)

bsq

# Listamos archivos raster de temperatura máxima, media y mínima para el pais de Colombia 
fls <- fs::dir_ls('../datos/raster/climate/worldclim_current/peru')
fls
 
# Precipitación 
fls <- grep('prec', fls, value = TRUE)

# Ordenar los datos
fls <- mixedsort(fls)

# Crear un ciclo para leer todos los raster dentro de un objeto tipo lista
prc <- list()
for(i in 1:length(fls)){
  prc[[i]] <- raster(fls[i])
}

plot(prc[[1]], main = 'Enero')
plot(prc[[2]], main = 'Febrero')

prc

# Otro posible camino de leer todos los raster dento de un listado
prc <- lapply(1:length(fls), function(k){raster(fls[k])})
prc
prc <- lapply(fls, raster)

# O usando la libreria tidyverse
library(tidyverse)
prc <- map(fls, raster)

prc
names(prc) <- paste0('prec_', 1:12)

plot(prc$prec_1)

par(mfrow = c(3, 4))
for(i in 1:12){
  plot(prc[[i]])
}

writeRaster(prc[[1]], '../output/raster/tif/prc_ene.tif', overwrite = TRUE) 

# Ahora si quisieramos escribir en un ciclo, hacemos lo siguiente DW
for(i in 1:12){
  writeRaster(prc[[i]], paste0('../output/raster/tif/prc_', i, '.tif'), overwrite = TRUE)
}

