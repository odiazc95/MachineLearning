
# Load libraries
require(pacman)
pacman::p_load(raster, rgdal, rgeos, stringr, sf, tidyverse, 
               gtools, dismo, fs, glue)

# Listamos archivos 
fles <- dir_ls('../raster/worldclim/v20/1km/smo')
fles <- fles[-grep('gwr.tif', fles, value = FALSE)]

# Read as stack
tmax <- grep('tmax', fles, value = TRUE)
tmax <- mixedsort(tmax)
tmax <- raster::stack(tmax)

tmin <- grep('tmin', fles, value = TRUE)
tmin <- mixedsort(tmin)
tmin <- raster::stack(tmin)

prec <- grep('prec', fles, value = TRUE)
prec <- mixedsort(prec)
prec <- raster::stack(prec)


# Create the bioclimatic variables
bclm <- dismo::biovars(prec = prec, tmin = tmin, tmax = tmax)
dout <- '../raster/worldclim/v20/1km/smo'
Map('writeRaster', x = unstack(bclm), filename = glue('{dout}/bio_{1:19}.tif'))


# Read the vars
vars <- readRDS(file = '../rds/vars_vif.rds')
prsn <- read.csv('../table/points/durangensis_rmvOtl.csv')
mask <- bclm[[1]] * 0 + 1

head(prsn)

vars
prsn <- prsn %>% dplyr::select(X, Y, vars)
write.csv(prsn, '../table/points/durangensis_rmvOtl_vars.csv')


