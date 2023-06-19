
# Load libraries
require(pacman)
pacman::p_load(raster, rgdal, rgeos, stringr, sf, tidyverse, 
               gtools, dismo, fs, glue)

# Load data
prsn <- read_csv('../table/points/durangensis_rmvOtl_vars.csv')
mask <- raster('../raster/worldclim/v20/1km/smo/bio_1.tif')
mask <- mask * 0 + 1
vars <- readRDS(file = '../rds/vars_vif.rds')

# Get the coordinates where we have presences -----------------------------
clls <- raster::extract(mask, prsn[,2:3], cellnumber = TRUE)
mask[clls[,1]] <- NA
writeRaster(mask, './bck.tif')

tble <- rasterToPoints(mask, spatial = FALSE)
tble <- as_tibble(tble)

bckn <- sample_n(tbl = tble, size = nrow(prsn), replace = TRUE)
bckn <- bckn[,1:2]

# Load climate ------------------------------------------------------------
fles <- dir_ls('../raster/worldclim/v20/1km/smo', regexp = '.tif')
fles <- fles[-grep('gwr', fles, value = FALSE)]
fles <- mixedsort(fles)
fles <- grep('bio', fles, value = TRUE)
fles <- fles[1:19]
stck <- raster::stack(fles)
names(stck) <- glue('bio_{1:19}')

# Get the values for the backrground --------------------------------------
bckn_swdt <- raster::extract(stck, bckn[,1:2])
bckn_swdt <- cbind(bckn, bckn_swdt)
bckn_swdt <- bckn_swdt %>% dplyr::select(x, y, vars)

# Prepare the tables ------------------------------------------------------

# Presences
prsn <- prsn[,2:ncol(prsn)]
prsn <- mutate(prsn, species = 'durangensis')
prsn <- prsn %>% dplyr::select(species, X, Y, everything())
names(prsn)[2:3] <- c('longitude', 'latitude') 

# Pseudoabsences
bckn_swdt <- bckn_swdt %>% as_tibble() 
bckn_swdt <- bckn_swdt %>% mutate(species = 'background')
bckn_swdt <- bckn_swdt %>% dplyr::select(species, x, y, everything())

write.csv(prsn, '../table/points/occ_v1.csv', row.names = FALSE)
write.csv(bckn_swdt, '../table/points/bck_v1.csv', row.names = FALSE)

# Write the files



