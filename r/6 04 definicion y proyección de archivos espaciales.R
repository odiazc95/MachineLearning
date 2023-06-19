

# Load libaries -----------------------------------------------------------
require(pacman)
pacman::p_load(raster, rgdal, rgeos, stringr, hrbrthemes, sf, colorspace, cartography,ghibli, tidyverse)

g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999)

# Functions to use
makeUniform < -function(SPDF){
  pref<-substitute(SPDF)  #just putting the file name in front.
  newSPDF<-spChFIDs(SPDF,as.character(paste(pref,rownames(as(SPDF,"data.frame")),sep="_")))
  return(newSPDF)
}

# -------------------------------------------------------------------------
# Archivos raster ---------------------------------------------------------
# -------------------------------------------------------------------------

# Load data ---------------------------------------------------------------------
bsq <- raster('../datos/raster/bosque/Treecover/huaitara2.tif')

# Revisamos el sistema de coordenadas
bsq
crs(bsq)

# Vamos a la web page spatialreference.org, y luego al enlace que muestra proj4 y copiamos ello
geo <- crs('+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs')
crs(bsq) <- geo

# Ahora escribimos el dato raster con el mismo nombre pero el numeral 3
writeRaster(bsq, '../datos/raster/bosque/Treecover/huaitara3.tif')

bs3 <- raster('../datos/raster/bosque/Treecover/huaitara3.tif')

# Revisamos si tiene el sistema de coordenadas correcto 
crs(bsq)

# Leamos otro archvo espacial tipo raster ---------------------------------
dem <- raster('../datos/raster/dem/peru_mazan.tif')
crs(dem)

# Ahora para saber que sistema de coordenadas utilizar para el pais de Peru, 
# vamos a la pagina web epsg.io

# EPSG 5389
prj_per <- crs('+proj=utm +zone=19 +south +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs')
dem_prj <- raster::projectRaster(dem, crs = prj_per)
dem_prj

res(dem_prj)
writeRaster(x = dem_prj, filename = '../output/raster/tif/peru_mazan_prj.tif', overwrite = TRUE)

# -------------------------------------------------------------------------
# Ahora con archivos shapefile --------------- -----------------------------
# -------------------------------------------------------------------------
ccao <- shapefile('../datos/shapefile/cacao/mpios_cacaoteros.shp')
crs(ccao)
crs(ccao) <- crs(bsq)
ccao
ccao

znas <- shapefile('../datos/shapefile/zonas_inundables/zonas_inundables.shp')
head(znas@data)
unique(znas$IUNUDA)

plot(ccao, border = 'red')
plot(znas, add = TRUE, col = 'blue')

# Revisamos los sistemas de coordenadas
znas
crs(znas)
crs(ccao)

znas <- spTransform(x = znas, CRSobj = crs(ccao))
crs(znas)
crs(ccao)
identicalCRS(x = znas, y = ccao)

# Queremos conocer el municipio de cada zona de inundacion

znas
plot(znas)
znas_ccao <- raster::intersect(x = znas, y = ccao)
head(znas_ccao)
znas_ccao@data$MPIO_CNMBR <- iconv(znas_ccao@data$MPIO_CNMBR, from = 'UTF-8', to = 'latin1')
head(znas_ccao)

# Agregar el dato del area, para ello primero tenemos que proyectar a un sistema de coordenadas plano el shapefile
znas_ccao
prj <- '+proj=tmerc +lat_0=4.596200416666666 +lon_0=-74.07750791666666 +k=1 +x_0=1000000 +y_0=1000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs'
znas_ccao <- makeUniform(SPDF = znas_ccao)
znas_ccao <- sp::spTransform(x = znas_ccao, CRSobj = crs(prj))

crs(znas_ccao)
znas_ccao@data$area_mt <- raster::area(znas_ccao)
znas_ccao@data$area_ha <- znas_ccao@data$area_mt / 10000
znas_ccao@data$area_ha <- round(znas_ccao@data$area_ha, 1)
head(znas_ccao@data)

# Shapefile a tabla
znas_ccao@data
head(znas_ccao@data)

df <- znas_ccao@data
df <- as_tibble(df)
df <- df %>% dplyr::select(DPTO_CNMBR, MPIO_CNMBR, MPIO_CCNCT, IUNUDA, area_ha)
df <- df %>% group_by(DPTO_CNMBR, MPIO_CNMBR, MPIO_CCNCT, IUNUDA) %>% dplyr::summarise(area_ha = sum(area_ha)) %>% ungroup()
df <- df %>% mutate(IUNUDA = str_to_sentence(IUNUDA))
df <- df %>% mutate(MPIO_CNMBR = str_to_title(MPIO_CNMBR))
df <- df %>% mutate(MPIO_CNMBR = str_replace_all(string = MPIO_CNMBR, pattern = 'Del', replacement = 'del'))
df <- df %>% mutate(IUNUDA = factor(IUNUDA, levels = c('Cuerpo de agua', 'Zona inundable')))
df <- df %>% arrange(desc(area_ha)) %>% mutate(MPIO_CNMBR = factor(MPIO_CNMBR, levels = unique(MPIO_CNMBR)))

##
for(i in names(ghibli_palettes)) print(ghibli_palette(i))
##

g_inundacion <- ggplot(data = df, aes(x = MPIO_CNMBR, y = area_ha, group =  IUNUDA, fill = IUNUDA)) + 
  geom_bar(position = 'dodge', stat = 'identity') + 
  scale_fill_manual(values = c('#0E84B4FF', '#1D2645FF')) +
  labs(x = '', y = 'Área (ha)', fill = 'Tipo') + 
  ggtitle(label = 'Áreas de posible inundación para los\nmunicipios cacaoteros de Caquetá') +
  # theme_ft_rc() +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, size = 9, hjust = 0.5, vjust = 0.8), 
        axis.text.y = element_text(angle = 90, size = 9, vjust = 0.5, hjust = 0.5),
        axis.title.y = element_text(size = 10, face = 'bold'),
        plot.title = element_text(size = 12, hjust = 0.5, face = 'bold'), 
        legend.position = c(0.88, 0.9))

ggsave(plot = g_inundacion, filename = '../png/graphs/geom_col_inundacion_cacao.png',
       units = 'in', width = 7, height = 6, dpi = 300)



