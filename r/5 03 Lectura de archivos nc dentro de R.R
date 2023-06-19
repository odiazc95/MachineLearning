 
# Cargar las librerías
require(raster)
require(rgeos)
require(gtools)
require(rgdal)
require(fs)

# Cargar los datos 
path <- '../datos/raster/climate/terraclimate/TerraClimate_ppt_2020.nc'

# Debido a que es un archivo .nc debemos instalar la liberria ncdf4
# install.packages('ncdf4')
require(ncdf4)

pptn <- raster::stack(path)
plot(pptn)

# Extraer ciertos meses del raster stack 
pptn_ene <- pptn[[1]]
pptn_ene
pptn_ene <- pptn_ene * 1 # Asi ya queda como raster solo, y no como algo que tiene doce bandas 

# Extraer mas de un mes 
pptn_ene_mar <- pptn[[1:3]]
ppt_ene_jun_dic <- pptn[[c(1, 6, 12)]]

# Ahora como escribimos un archivo stack, ejemplo esos cuatro archivos 
writeRaster(ppt_ene_jun_dic, '../output/raster/nc/ppt_ene_jun_dic.nc', overwrite = TRUE)




