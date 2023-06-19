

# Load libaries -----------------------------------------------------------
require(pacman)
pacman::p_load(raster, rgdal, rgeos, stringr, hrbrthemes, sf, colorspace, cartography,ghibli, tidyverse)

g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999)

# Leer los archivos ------------------------------------------------------
cbrt <- raster('../datos/raster/cover/cobertura_2017_putumayo.tif')

# Tabla de atributos del shapefile
lbls <- cbrt@data@attributes[[1]]
lbls <- as_tibble(lbls)
lbls <- lbls %>% dplyr::select(Cobertura = COBERTURA, Value, Count)

# Rectify the raster -----------------------------------------------------
cbrt <- cbrt * 1
plot(cbrt)

# Shapefile de municipios -------------------------------------------------
mpios <- raster::shapefile('../datos/shapefile/admon/MGN_MPIO_POLITICO.shp')
mpios <- mpios[mpios@data$DPTO_CNMBR == 'PUTUMAYO',]

# Ejemplo de rasterizacion
# Rasterizamos el shapefile
mpios@data$gid <- 1:nrow(mpios@data)
mpios
# system.time(expr = {mpios_rstr <- raster::rasterize(mpios, cbrt, field = 'gid')}) # Results: 44.23 

# Rasterizar de manera mas rapida y eficiente
library(fasterize)
system.time(expr = {mpios_rstr <- fasterize::fasterize(sf = st_as_sf(mpios), raster = cbrt, field = 'gid')}) # 2.82, es mucho mas rapido

# Hacer estadistica zonal -------------------------------------------------
# Queremos saber cuanto es el area de cada zona de cobertura para cada mpio

cbrt_shpf <- raster::shapefile('../datos/shapefile/coberturas/coberturas_put.shp')
nmes <- mpios@data$MPIO_CNMBR
cbrt_shpf <- sp::spTransform(x = cbrt_shpf, CRSobj = crs(mpios))

mpios
tble_smmr <- map(.x = 1:length(nmes), .f = function(i){
  
  cat(nmes[i], '\n')
  mpio <- mpios[mpios@data$MPIO_CNMBR == nmes[i],]
  cver <- raster::crop(cbrt_shpf, mpio)
  
  cat('To project\n')
  cver <- spTransform(x = cver, CRSobj = '+proj=tmerc +lat_0=4.596200416666666 +lon_0=-74.07750791666666 +k=1 +x_0=1000000 +y_0=1000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
  cver@data$area <- raster::area(cver)
  cver@data$hctr <- cver@data$area / 10000
  cver@data$hctr <- round(cver@data$hctr, 1)
  head(cver@data)
  
  cat('To make the summarise\n')
  cver_tble <- cver@data %>% as_tibble()
  cver_tble <- cver_tble %>% dplyr::select(COBERTURA, hctr) %>% mutate(mpio = nmes[i])
  cver_tble <- cver_tble %>% group_by(COBERTURA, mpio) %>% dplyr::summarise(hctr = sum(hctr, na.rm = TRUE)) %>% ungroup()
  cat('Done\n')
  return(cver_tble)
  
})

tble_smmr <- bind_rows(tble_smmr)
tble_smmr <- tble_smmr %>% mutate(mpio = iconv(mpio, from = 'UTF-8', to = 'latin1'))

write.csv(tble_smmr, '../output/tbl/coberturas_count_has_putumayo.csv', row.names = FALSE)

# Estadistica zonal promedio ----------------------------------------------
ecdr <- raster::getData(name = 'GADM', country = 'ECU', level = 1)
tav1 <- raster::getData(name = 'worldclim', var = 'tmean', lon = coordinates(ecdr)[1,1], lat = coordinates(ecdr)[1,2], res = 0.5)
tav2 <- raster::getData(name = 'worldclim', var = 'tmean', lon = coordinates(ecdr)[1,1], lat = coordinates(ecdr)[1,2] + 3, res = 0.5)
tav1 <- raster::crop(tav1, ecdr) %>% raster::mask(., ecdr)
tav2 <- raster::crop(tav2, ecdr) %>% raster::mask(., ecdr)

tavg <- list()

for(i in 1:12){
  cat(i, '\n')
  tavg[[i]] <- raster::mosaic(tav1[[i]], tav2[[i]], fun = 'mean')
}

tavg <- raster::stack(tavg)
tavg <- raster::crop(tavg, c(-82, extent(tavg)[2:4]))
tavg <- mean(tavg)

ecdr@data$gid <- 1:nrow(ecdr@data)
ecdr.rstr <- raster::rasterize(ecdr, tavg, field = 'gid')

znal <- raster::zonal(x = tavg, z = ecdr.rstr, fun = 'mean')
znal <- as_tibble(znal) %>% inner_join(., ecdr@data, by = c('zone' = 'gid'))
znal <- znal %>% dplyr::select(zone, NAME_0, NAME_1, mean)
znal <- znal %>% mutate(mean = mean / 10)

tavg <- tavg / 10
writeRaster(tavg, filename = '../datos/raster/climate/ecdr/tmean_ecdr.tif', overwrite = TRUE)

write.csv(znal, '../output/tbl/tmean_zonal_ecdr.csv', row.names = FALSE)

ppt1 <- raster::getData(name = 'worldclim', var = 'prec', lon = coordinates(ecdr)[1,1], lat = coordinates(ecdr)[1,2], res = 0.5)
ppt2 <- raster::getData(name = 'worldclim', var = 'prec', lon = coordinates(ecdr)[1,1], lat = coordinates(ecdr)[1,2] + 7, res = 0.5)
ppt1 <- raster::crop(ppt1, ecdr) %>% raster::mask(., ecdr)
ppt2 <- raster::crop(ppt2, ecdr) %>% raster::mask(., ecdr)

pptn <- list()

for(i in 1:12){
  cat(i, '\n')
  pptn[[i]] <- raster::mosaic(ppt1[[i]], ppt2[[i]], fun = 'mean')
}

pptn <- raster::stack(pptn)
pptn <- sum(pptn)
pptn <- raster::crop(pptn, c(-82, extent(tavg)[2:4]))
plot(pptn)

writeRaster(pptn, filename = '../datos/raster/climate/ecdr/prec_ecdr.tif', overwrite = TRUE)

znal <- raster::zonal(x = pptn, z = ecdr.rstr, fun = 'mean')
znal <- as_tibble(znal) %>% inner_join(., ecdr@data, by = c('zone' = 'gid'))
znal <- znal %>% dplyr::select(zone, NAME_0, NAME_1, mean)
znal <- znal %>% mutate(mean = mean / 10)

write.csv(znal, '../output/tbl/prec_zonal_ecdr.csv', row.names = FALSE)
