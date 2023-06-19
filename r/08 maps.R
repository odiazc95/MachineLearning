

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(raster, rgdal, rgeos, stringr, sf, tidyverse, 
               dismo, usdm, ENMeval, ecospat, rJava, gtools, 
               glue, fs, RColorBrewer, colorspace)

g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999)


# Load data ---------------------------------------------------------------
fles <- dir_ls(path = '../maxent/run_2', regexp = '.tif$')
avrg <- raster(fles[1])
binr <- raster(fles[2])
stdv <- raster(fles[3])
smoc <- st_read('../shp/base/sierra_madre_occidental/SMO.shp')

# Project shapefile -------------------------------------------------------
smoc <- st_transform(x = smoc, crs = st_crs(4326))

# Raster to Points --------------------------------------------------------
avrg.tble <- rasterToPoints(avrg, spatial = FALSE)
avrg.tble <- as_tibble(avrg.tble)
names(avrg.tble) <- c('lon', 'lat', 'value')

# Colors 
RColorBrewer::display.brewer.all()
hcl_palettes(plot = TRUE)

# Map


gavg <- ggplot() + 
  geom_tile(data = avrg.tble, aes(x = lon, y = lat, fill = value)) +
  geom_sf(data = smoc, fill = NA) + 
  coord_sf() +
  scale_fill_gradientn(colors = RColorBrewer::brewer.pal(name = 'RdYlGn', n = 9)) +
  # scale_fill_binned_diverging(palette = 'Red-Green') + 
  ggtitle(label = 'Idoneidad línea base\n(Pinus durangensis)') +
  theme(legend.position = 'bottom', 
        legend.key.width = unit(2, 'line'), 
        plot.title = element_text(hjust = 0.5, face = 'bold')) +
  labs(x = 'Longitud', y = 'Latitud', fill = 'Idoneidad')

ggsave(plot = gavg, filename = '../png/maps/pinus_avrg_crnt.jpg',
       units = 'in', width = 7, height = 10, dpi = 300)

# expression('No. of'~italic(bacteria X)~'isolates with corresponding types')

# Binary map
binr.tble <- rasterToPoints(binr, spatial = FALSE) %>% as_tibble()
colnames(binr.tble) <- c('lon', 'lat', 'value')
binr.tble <- mutate(binr.tble, class = ifelse(value == 0, 'Idoneo', 'No idoneo'))
binr.tble <- mutate(binr.tble, class = factor(binr.tble, levels = c('No idoneo', 'Idoneo')))

gbin <- ggplot() + 
  geom_tile(data = binr.tble, aes(x = lon, y = lat, fill = class)) +
  geom_sf(data = smoc, fill = NA) + 
  coord_sf() +
  scale_fill_manual(values = c('grey', 'green')) +
  # scale_fill_binned_diverging(palette = 'Red-Green') + 
  ggtitle(label = 'Idoneidad línea base\n(Pinus durangensis)') +
  theme(legend.position = 'bottom', 
        legend.key.width = unit(2, 'line'), 
        plot.title = element_text(hjust = 0.5, face = 'bold')) +
  labs(x = 'Longitud', y = 'Latitud', fill = 'Idoneidad')

ggsave(plot = gbin, filename = '../png/maps/pinus_binr_crnt.jpg',
       units = 'in', width = 7, height = 10, dpi = 300)
