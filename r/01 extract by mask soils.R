

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(raster, rgdal, rgeos, stringr, glue, tidyverse, gtools, terra, fs)

g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999)

# Load data ---------------------------------------------------------------
mexc <- raster::getData(name = 'GADM', country = 'MEX', level = 0)
mexc <- vect(mexc)
root <- '//Moringa/cl17$/GLOBAL/Biofisico/SoilGrids250m'
dirs <- dir_ls(root, type = 'dir')

# Chemical soil properties ------------------------------------------------
chmc <- dirs[1]
chmc <- dir_ls(chmc)

map(.x = 1:length(chmc), .f = function(i){
  
  cat(chmc[i], '\n')
  rst <- chmc[i] %>% 
    dir_ls(., regexp = '.tif$') %>% 
    terra::rast() %>% 
    terra::crop(., mexc) %>% 
    terra::mask(., mexc)
  
  out <- '../tif/soils/chemical'
  nms <- chmc[i] %>% dir_ls(., regexp = '.tif$') %>% basename()
  out <- glue('{out}/{nms}')
  Map('writeRaster', x = rst, filename = out)
  cat('Done!\n')
  
})

# Physical soil properties ------------------------------------------------
phys <- dirs[3]
phys <- dir_ls(phys)

map(.x = 2:length(phys), .f = function(i){
  
  cat(phys[i], '\n')
  rst <- phys[i] %>% 
    dir_ls(., regexp = '.tif$') %>% 
    terra::rast() %>% 
    terra::crop(., mexc) %>% 
    terra::mask(., mexc)
  out <- '../tif/soils/physical'
  nms <- phys[i] %>% dir_ls(., regexp = '.tif$') %>% basename()
  out <- glue('{out}/{nms}')
  Map('writeRaster', x = rst, filename = out)
  
})

# Soil organic carbon stock -----------------------------------------------
fles <- '//Moringa/cl17$/GLOBAL/Biofisico/SoilGrids250m/Site characteristics/Soil organic carbon stock'
socs <- dir_ls(fles, regexp = '.tif')

map(.x = 1:length(socs), .f = function(i){
  
  cat(socs[i], '\n')
  rst <- socs[1] %>% 
    terra::rast() %>% 
    terra::crop(., mexc) %>% 
    terra::mask(., mexc)
  out <- '../tif/soils/socs'
  nms <- socs[i] %>% basename()
  out <- glue('{out}/{nms}')
  Map('writeRaster', x = rst, filename = out)
  
})
