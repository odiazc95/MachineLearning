

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(raster, rgdal, rgeos, stringr, sf, tidyverse, gtools, fs, RSAGA)

g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999)

# Load data ---------------------------------------------------------------
file_srtm <- '../raster/srtm/90m/srtm_smo.tif'
file_vrbl <- '../raster/worldclim/v20/1km/smo/tmin_2.tif'

# Environmental SAGA 
env <- rsaga.env(path = 'C:/saga-8.0.0_x64')

# Downscaling -------------------------------------------------------------
rsl <- rsaga.geoprocessor(lib = 'statistics_regression', 
                          module = 'GWR for Grid Downscaling', 
                          param = list(PREDICTORS = file_srtm,
                                       REGRESSION = paste0(dirname(file_vrbl), '/', 'tmin_2_gwr.tif'),
                                       DEPENDENT = file_vrbl),
                          env = env)

raw <- raster(file_vrbl)
rsl <- raster('../raster/worldclim/v20/1km/smo/tmin_2_gwr.tif')
res(rsl)
res(raster(file_srtm))
res(raster(file_vrbl))

par(mfrow = c(1, 2))
plot(raw, main = 'Res: 1km')
plot(rsl, main = 'Res: 90m')
par(mfrow = c(1, 1))

# Function ----------------------------------------------------------------
make_gwr <- function(file){

  cat('Start ', file, '\n')
  vrb <- basename(file)
  vrb <- str_split(vrb, '_')
  vrb <- vrb[[1]][1]
  mnt <- parse_number(basename(file))
  
  rsl <- rsaga.geoprocessor(lib = 'statistics_regression', 
                            module = 'GWR for Grid Downscaling', 
                            param = list(PREDICTORS = file_srtm,
                                         REGRESSION = paste0(dirname(file), '/', vrb, '_', mnt, '_gwr.tif'),
                                         DEPENDENT = file),
                            env = env)
  
  cat('Done\n')
  
}

# List files --------------------------------------------------------------
fles <- dir_ls('../raster/worldclim/v20/1km/smo', regexp = '.tif$')
fles <- fles[-grep('gwr', fles)]
temp <- grep('tm', fles, value = TRUE)
temp <- as.character(temp)

# Apply the function ------------------------------------------------------
map(.x = temp, .f = make_gwr)

