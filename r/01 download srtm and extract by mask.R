

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(raster, glue, fs, rgdal, readxl, rgeos, stringr, sf, tidyverse, gtools, terra)

g <- gc(reset = TRUE)
rm(list = ls())

# Functions ---------------------------------------------------------------
cut_stack <- function(vrb){
  
  cat('Start ', vrb, '\n')
  rstr <- grep(vrb, fles, value = TRUE)
  rstr <- as.character(rstr)
  rstr <- raster::stack(rstr)
  rstr <- raster::crop(rstr, shpf)
  rstr <- raster::mask(rstr, shpf)
  cat('Done!\n')
  return(rstr)
  
}

# Load data ---------------------------------------------------------------
shpf <- shapefile('../shp/base/sierra_madre_occidental/SMO.shp')
pnts <- read_excel('../table/points/durangensis.xlsx')

crs(shpf)

# Project to geographic ---------------------------------------------------
shpf <- spTransform(x = shpf, CRSobj = '+proj=longlat +datum=WGS84 +no_defs')

pnts
coordinates(pnts) <- ~ X + Y

plot(pnts)
plot(shpf, add = TRUE, border = 'blue')

# Intersection between the shapefile and the points -----------------------
pnts_shpf <- raster::intersect(pnts, shpf)
nrow(pnts@data) - nrow(pnts_shpf@data)

plot(shpf)
plot(pnts_shpf, add = TRUE, col = 'red', pch = 16)

# Extract by mask ---------------------------------------------------------
path <- 'D:/data/WORLDCLIM/Version20'
fles <- dir_ls(path, regexp = '.tif$')
fles <- fles[-grep('col', fles)]
length(fles)

# Read as a raster --------------------------------------------------------
prec <- cut_stack(vrb = 'prec')
tmax <- cut_stack(vrb = 'tmax')
tmin <- cut_stack(vrb = 'tmin')
tavg <- cut_stack(vrb = 'tavg')

# Write the raster --------------------------------------------------------
prec[[2]]

# Way 1
for(i in 1:12){
  writeRaster(prec[[i]], filename = glue('../raster/worldclim/v20/1km/smo/prec_{i}.tif'))
}

# Way 2
Map('writeRaster', x = unstack(prec), filename = glue('../raster/worldclim/v20/1km/smo/prec_{1:12}.tif'))
Map('writeRaster', x = unstack(tmax), filename = glue('../raster/worldclim/v20/1km/smo/tmax_{1:12}.tif'))
Map('writeRaster', x = unstack(tmin), filename = glue('../raster/worldclim/v20/1km/smo/tmin_{1:12}.tif'))
Map('writeRaster', x = unstack(tavg), filename = glue('../raster/worldclim/v20/1km/smo/tavg_{1:12}.tif'))

# Just one stack file
writeRaster(x = prec, filename = './prec.nc')

# Create bioclimatic 20 ---------------------------------------------------
precbin <- reclassify(prec, c(-Inf, 40, 1, 40, Inf, NA))
prectwo <- addLayer(precbin, precbin)
allp <- stack()
for(i in 1:12){
  
  oney <- prectwo[[i:(i + 11)]]
  drym <- cumsum(oney)
  maxn <- max(drym, na.rm = TRUE)
  allp <- addLayer(allp, maxn)
  
}

bio_20 <- max(allp, na.rm = TRUE)
writeRaster(x = bio_20, filename = '../raster/worldclim/v20/1km/smo/bio_20.tif')

# Download SRTM  ----------------------------------------------------------
shpf
plot(shpf)
cntr <- coordinates(shpf)
points(cntr[,1], cntr[,2], col = 'red')
srt1 <- raster::getData(name = 'SRTM', lon = cntr[,1], lat = cntr[,2])
plot(srt1)
plot(shpf, add = TRUE, border = 'blue')
plot(shpf)
plot(srt1, add = TRUE)
srt2 <- raster::getData(name = 'SRTM', lon = cntr[,1], lat = cntr[,2] - 5)
plot(shpf)
plot(srt1, add = TRUE)
plot(srt2, add = TRUE)
srt3 <- raster::getData(name = 'SRTM', lon = cntr[,1], lat = cntr[,2] + 5)
plot(srt3, add = TRUE)
srt4 <- raster::getData(name = 'SRTM', lon = cntr[,1] + 5, lat = cntr[,2])
plot(srt4, add = TRUE)
srt5 <- raster::getData(name = 'SRTM', lon = cntr[,1] + 5, lat = cntr[,2] - 5)
plot(srt5, add = TRUE)
srt6 <- raster::getData(name = 'SRTM', lon = cntr[,1] - 5, lat = cntr[,2])
plot(srt6, add = TRUE)
srt7 <- raster::getData(name = 'SRTM', lon = cntr[,1] - 5, lat = cntr[,2] + 5)
plot(srt7, add = TRUE)
plot(shpf, add = TRUE)

# Mosaic  -----------------------------------------------------------------
test <- mosaic(srt1, srt2, fun = 'mean')
srt8 <- list(srt1, srt2, srt3, srt4, srt5, srt6, srt7)
srt8$fun <- mean
srt8$na.rm <- TRUE
srtm <- do.call(mosaic, srt8)
srtm <- raster::crop(srtm, shpf)
srtm <- raster::mask(srtm, shpf)
dir_create('../raster/srtm/90m')
writeRaster(x = srtm, filename = '../raster/srtm/90m/srtm_smo.tif')

# Load DEM ----------------------------------------------------------------
srtm <- raster('../raster/srtm/90m/srtm_smo.tif')

