

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(raster, rgdal, outliers, rgeos, hrbrthemes, readxl, stringr, sf, tidyverse, gtools)

g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999)

# Load data ---------------------------------------------------------------
pnts <- read_excel('../table/points/durangensis.xlsx')
pnts <- dplyr::select(pnts, X, Y, Altitud)
smoc <- shapefile('../shp/base/sierra_madre_occidental/SMO.shp')

# Project -----------------------------------------------------------------
smoc <- spTransform(x = smoc, CRSobj = '+proj=longlat +datum=WGS84 +no_defs')

# Cut points --------------------------------------------------------------
class(pnts)
coordinates(pnts) <- ~ X + Y
pnts_smoc <- raster::intersect(x = pnts, y = smoc)

# Worldclim ---------------------------------------------------------------
fles <- '../raster/worldclim/v20/1km'
fles <- list.files(fles, full.names = TRUE, pattern = '.tif$')
fles <- grep('bio', fles, value = TRUE)
fles <- mixedsort(fles)
stck <- raster::stack(fles)
stck <- raster::crop(stck, smoc)
stck <- raster::mask(stck, smoc)
mask <- stck[[1]] * 0 + 1

# Remove duplicated by cell -----------------------------------------------
# mask <- raster('../raster/srtm/90m/srtm_smo.tif')
mask <- stck[[1]] * 0
clls <- raster::extract(mask, pnts_smoc, cellnumber = TRUE)
clls <- xyFromCell(mask, clls[,'cells'])
dupv <- duplicated(clls[,c('x', 'y')])
table(dupv)
pnts <- coordinates(pnts_smoc)
head(pnts)
occr <- pnts_smoc[!dupv,]

# Remove outliers ---------------------------------------------------------
vles <- raster::extract(stck, pnts[,1:2])
class(vles)
vles <- as.data.frame(vles)
vles <- cbind(pnts, vles)
vles <- vles %>% mutate(gid = 1:nrow(.))
vles <- vles %>% dplyr::select(gid, X, Y, everything())

boxplot(vles$bio_1)
vles <- vles %>% gather(variable, valor)
vles <- as_tibble(vles)
unique(vles$variable)
vles <- mutate(vles, variable = factor(variable, levels = paste0('bio_', 1:19)))

# Make a simple boxplot ---------------------------------------------------
gbox <- ggplot(data = vles, aes(x = 1, y = valor)) + 
  geom_boxplot() + 
  facet_wrap(.~variable, scales = 'free_y') + 
  theme_ipsum_es()

# Possible outliers -------------------------------------------------------
vles <- vles %>% mutate(variable = as.character(variable))
norm <- scores(vles[,4:ncol(vles)], 'z')
norm_na <- norm
norm_na[abs(norm_na) > 3.5] <- NA
normpoints <- cbind(pnts[,c('X', 'Y')], norm_na) %>% 
  na.omit() %>% 
  as_tibble()

nrow(normpoints) -nrow(vles)
head(vles)

normpoints <- normpoints[,1:2]

# Extract the values ------------------------------------------------------
pnts_vles <- raster::extract(stck, normpoints[,1:2])
pnts_vles <- cbind(normpoints[,1:2], pnts_vles)

write.csv(pnts_vles, '../table/points/durangensis_rmvOtl.csv', row.names = FALSE)


# Correlacion simple ------------------------------------------------------
library(corrplot)

m <- cor(pnts_vles[,3:ncol(pnts_vles)])

png(filename = '../png/corplot.png', width = 9, height = 6, units = 'in', res = 300)
corrplot(m, method = 'circle')
dev.off()

# Analisis de multicolinealidad -------------------------------------------
library(usdm)
vif.res <- vif(x = pnts_vles[,4:ncol(pnts_vles)])
vif.stp <- vifstep(x = pnts_vles[,4:ncol(pnts_vles)], th = 10)
vrs <- vif.stp@results$Variables %>% as.character()
saveRDS(object = vrs, file = '../rds/vars_vif.rds')

