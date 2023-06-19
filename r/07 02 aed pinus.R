
# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(raster, glue, readxl, rgdal, rgeos, fs, stringr, sf, tidyverse, terra)

options(scipen = 999)
g <- gc(reset = TRUE)
rm(list = ls())


# Load dataset ------------------------------------------------------------
tble <- read_excel('E:/asesorias/SDM/table/points/durangensis.xlsx')

# Table to shapefile ------------------------------------------------------
shpf <- tble
coordinates(shpf) <- ~ X + Y

crs(shpf)
crs(shpf) <- '+proj=longlat +datum=WGS84 +no_defs'

dir_create('E:/asesorias/SDM/shp/points')
shapefile(shpf, 'E:/asesorias/SDM/shp/points/durangensis.shp')

