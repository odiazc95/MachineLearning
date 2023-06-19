

# Cargamos librerias -----------------------------------------
library(pacman)
pacman::p_load(raster, rgdal, rgeos, stringr, foreign, sf, tidyverse, gtools, rgeos, ncdf4)

g <- gc(reset = TRUE)
rm(list = ls())

# Datos del bosque -------------------------------------------
frst <- raster('../datos/raster/bosque/Bosque_NoBosque_2013/Geotiff/SBQ_SMBYC_BQNBQ_V5_2013.tif')
plot(frst)

dpto <- shapefile('../datos/shapefile/admon/MGN_DPTO_POLITICO.shp')
dpto

qndi <- dpto[dpto@data$DPTO_CNMBR == 'QUINDIO',]

# A simple plot -------------------------------------------------
plot(dpto)
plot(qndi, add = TRUE, border = 'red')

frst_qndi <- raster::crop(frst, qndi)
plot(frst_qndi)

# Extracción por máscara para el departamento del bosque --------
frst_qndi <- raster::crop(frst, qndi)
plot(frst_qndi)
frst_qndi <- raster::mask(frst_qndi, qndi)
plot(frst_qndi)

frst_qndi

# Terraclimate
pptn <- raster::stack('../datos/raster/climate/terraclimate/TerraClimate_ppt_2020.nc')
getData('ISO3')
mexc <- raster::getData(name = 'GADM', country = 'MEX', level = 0)

pptn <- raster::crop(pptn, mexc)
pptn <- raster::mask(pptn, mexc)
plot(pptn)
pptn_ttal <- sum(pptn)

lbls <- read.dbf('../datos/raster/bosque/Bosque_NoBosque_2013/Geotiff/SBQ_SMBYC_BQNBQ_V5_2013.tif.vat.dbf')
lbls$Leyenda <- iconv(lbls$Leyenda, from = 'UTF-8', to = 'latin1')

frst_qndi

# Conteo de area -----------------------------------------------
res(frst_qndi)[1] * 111.11 * 1000
pxls <- (res(frst_qndi)[1] * 111.11 * 1000) * (res(frst_qndi)[1] * 111.11 * 1000)
pxls <- pxls / 10000

frst_qndi_tbl <- frst_qndi %>% rasterToPoints %>% as_tibble()
frst_qndi_tbl <- frst_qndi_tbl %>% 
  setNames(c('x', 'y', 'value')) %>% 
  group_by(value) %>% 
  dplyr::summarise(count = n()) %>% 
  ungroup()
frst_qndi_tbl <- inner_join(frst_qndi_tbl, lbls[,c(1, 3)], by = c('value' = 'Value'))
# frst_qndi_tbl <- frst_qndi_tbl %>% mutate(Leyenda = iconv(Leyenda, from = 'UTF-8', to = 'latin1'))
frst_qndi_tbl <- frst_qndi_tbl %>% mutate(count_has = count * pxls)

# Un simple gráfico 
options(scipen = 999)

gg <- ggplot(data = frst_qndi_tbl, aes(x = Leyenda, y = count_has)) +
  geom_col() + 
  theme_bw() + 
  theme(axis.text.y = element_text(size = 12, angle = 90, hjust = 0.5)) + 
  labs(x = '', y = 'Cantidad hectáreas')

# Ahora ordenemos de mayor a menor
frst_qndi_tbl <- frst_qndi_tbl %>% arrange(desc(count_has)) %>% mutate(Leyenda = factor(Leyenda, levels = Leyenda))

gg <- ggplot(data = frst_qndi_tbl, aes(x = Leyenda, y = count_has)) +
  geom_col() + 
  theme_bw() + 
  theme(axis.text.y = element_text(size = 12, angle = 90, hjust = 0.5)) + 
  labs(x = '', y = 'Cantidad hectáreas')

ggsave(plot = gg, filename = '../png/graphs/count_bosque_quindio.png', units = 'in', 
       width = 7, height = 5, dpi = 300)

# Descarga de datos climáticos desde R  -----------------------------------
peru <- raster::getData(name = 'GADM', country = 'PER', level = 1)
peru
peru_adm0 <- aggregate(peru, 'NAME_0')
peru_adm0
plot(peru_adm0)

coord <- coordinates(peru_adm0)

pptn <- raster::getData(name = 'worldclim', var = 'prec', res = 0.5, lon = coord[1,1], lat = coord[1,2])
plot(pptn)

pptn <- raster::crop(pptn, peru_adm0)
pptn <- raster::mask(pptn, peru_adm0)
plot(pptn[[1]])

# Esta es la precipitacion para los 12 meses del año, sin embargo, deseamos calcular
# la precipitación acumulada, para ello hacemos una suma
pptn_ttal <- sum(pptn)
plot(pptn_ttal)

# Ahora escribimos el raster
writeRaster(pptn_ttal, '../output/raster/tif/prec_sum_per.tif')


# Datos de cobertura boscosa ---------------------------------------------

# Source: https://data.globalforestwatch.org/documents/14228e6347c44f5691572169e9e107ad/explore
fles <- fs::dir_ls('../datos/raster/dem', regexp = '.tif$')
rstr <- map(.x = fles, .f = raster)

par(mfrow = c(1, 3))
plot(rstr[[1]])
plot(rstr[[2]])
plot(rstr[[3]])
par(mfrow = c(1, 1))

# Mosaic
msc1 <- raster::mosaic(x = rstr[[1]], y = rstr[[2]], fun = 'mean')
msc2 <- raster::mosaic(x = msc1, y = rstr[[3]], fun = 'mean')
plot(msc1)
plot(msc2)

# Ahora como hacerlo de una sola
names(rstr) <- c('x', 'y', 'z')
rstr$fun <- mean
rstr$na.rm <- TRUE
msco <- do.call(raster::mosaic, rstr)

writeRaster(msco, filename = '../output/raster/tif/msco_dem_peru.tif')
