
# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(raster, rgdal, rgeos, glue, stringr, sf, tidyverse, gtools, fs, spatialEco)

g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999)

# Load data ---------------------------------------------------------------
fles <- dir_ls('../raster/worldclim/v20/1km/smo', regexp = '.tif')
srtm <- raster('../raster/srtm/90m/srtm_smo.tif')

# Downscaling testing -----------------------------------------------------
tmax <- grep('tmax', fles, value = TRUE)
tmax <- mixedsort(tmax)
tmax <- as.character(tmax)
tmax <- map(.x = tmax, .f = raster)

tmax_down <- raster.downscale(x = srtm, y = tmax[[1]])
tmax_down <- tmax_down$downscale
plot(tmax_down$downscale)

par(mfrow = c(1, 2))
plot(tmax[[1]], main = 'Raw')
plot(tmax_down$downscale, main = 'Downscaling')
par(mfrow = c(1, 1))

dir_create('../raster/worldclim/v20/90m/smo')

make_downscaling <- function(rst){
  
  # rst <- tmax[[2]]
  
  cat('Start\n')
  nme <- names(rst)
  cat(nme, '\n')
  rsl <- raster.downscale(x = srtm, y = rst)
  rsl <- rsl$downscale
  writeRaster(x = rsl, filename = glue('../raster/worldclim/v20/90m/smo/{nme}.tif'))
  cat('Done\n')
  
}

map(.x = tmax, .f = make_downscaling)
