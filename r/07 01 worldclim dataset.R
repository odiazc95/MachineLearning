

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(raster, glue, rgdal, rgeos, fs, stringr, sf, tidyverse, terra)

options(scipen = 999)
g <- gc(reset = TRUE)
rm(list = ls())

# Load data ---------------------------------------------------------------
path <- 'D:/data/WORLDCLIM/Version20'
fles <- fs::dir_ls(path, regexp = '.tif$')
limt <- terra::vect('E:/asesorias/SDM/shp/Export_Output.shp')

# Grepping data ----------------------------------------------------------
prec <- grep('prec', fles, value = TRUE)
prec <- as.character(prec)
prec <- prec[-grep('col', prec, value = FALSE)]
tmax <- grep('tmax', fles, value = TRUE)
tmax <- as.character(tmax)
tmin <- grep('tmin', fles, value = TRUE)
tmin <- as.character(tmin)

# Read as raster ----------------------------------------------------------
prec <- terra::rast(prec)
tmax <- terra::rast(tmax)
tmin <- terra::rast(tmin)

# Extract by mask  --------------------------------------------------------
prec <- terra::crop(prec, limt)
prec <- terra::mask(prec, limt)
tmax <- terra::crop(tmax, limt)
tmax <- terra::mask(tmax, limt)
tmin <- terra::crop(tmin, limt)
tmin <- terra::mask(tmin, limt)

# Write these raster ------------------------------------------------------
dout <- 'E:/asesorias/SDM/raster/worldclim/v20/1km'
dir_create(dout)

Map('writeRaster', 
    x = prec, 
    filename = glue('{dout}/prec_{1:12}.tif'))

Map('writeRaster', 
    x = tmax, 
    filename = glue('{dout}/tmax_{1:12}.tif'))

Map('writeRaster', 
    x = tmin, 
    filename = glue('{dout}/tmin_{1:12}.tif'))

# To create bioclimatic variables -----------------------------------------
library(dismo)

prec <- raster::stack(prec)
tmax <- raster::stack(tmax)
tmin <- raster::stack(tmin)

bclm <- dismo::biovars(prec = prec, tmin = tmin, tmax = tmax)


# Write just one raster
writeRaster(x = prec[[1]], 
            filename = './prec_01.tif')

# Write 12 rasters in a for
for(i in 1:12){
  writeRaster(x = prec[[1]], 
              filename = glue('./prec_{1:12}.tif'))
}

# Write 19 raster witn a only function
Map('writeRaster', 
    x = unstack(bclm), 
    filename = glue('{dout}/bio_{1:19}.tif'))



