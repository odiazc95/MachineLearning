
# Cargamos librerias -----------------------------------------
library(pacman)
pacman::p_load(raster, rgdal, ncdf4, rgeos, stringr, glue, foreign, sf, tidyverse, gtools, rgeos, ncdf4)

g <- gc(reset = TRUE)
rm(list = ls())

# Listamos datos climaticos de CHIRPS -------------------------------------
fls <- fs::dir_ls('D:/data/CHIRPS',regexp = '.tif$')
per <- raster::getData(name = 'GADM', country = 'PER', level = 0)
length(fls)

# Grep 2017 a 2019
yrs <- 2017:2019
fls <- grep(paste0(yrs, collapse = '|'), fls, value = TRUE)

# Creamos una funcion, en esta función haremos uso tanto de un ciclo como de un condicional.
summarise_month <- function(yr){
  cat(yr, '\n')
  rst <- grep(yr, fls, value = TRUE)
  rst <- map(.x = 1:12, .f = function(i){
    cat(i, '\n')
    mn <- ifelse(i < 10, glue('0{i}'), i)
    rs <- grep(glue('{yr}.{mn}.'), rst, value = TRUE)
    rs <- raster::stack(rs)
    rs <- raster::crop(rs, per) 
    rs <- raster::mask(rs, per)
    rs <- rs/10
    rs <- sum(rs)
    return(rs)
  })  
  rst <- raster::stack(rst)
  rst <- sum(rst)
  cat('Done\n')
  return(rst)
}

# Aplicamos la funcion para calcular la precpitacion acumulada para los tres distintos anios
rst_17 <- summarise_month(yr = 2017)
rst_18 <- summarise_month(yr = 2018)
rst_19 <- summarise_month(yr = 2019)

writeRaster(rst_17, filename = '../output/raster/tif/prec_2017_per.tif')
writeRaster(rst_18, filename = '../output/raster/tif/prec_2018_per.tif')
writeRaster(rst_19, filename = '../output/raster/tif/prec_2019_per.tif')

