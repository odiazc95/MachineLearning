

# Creación de tablas dentro de R
# Retomamos el primer dataframe creado en la primera sección 
ventas <- data.frame(meses = c('Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'),
                     ventas_a = rnorm(12, mean = 300, sd = 23), 
                     ventas_b = rnorm(12, mean = 340, sd = 34),
                     ventas_c = rnorm(12, mean = 400, sd = 20))

# Nombres, con la funcion names presenta el nombre de cada uno de los elementos
# del objeto, (si los tiene). También sirve para asignar nombres. 
names(ventas)
colnames(ventas)
names <- c('meses_12', 'ventas_a', 'ventas_b', 'ventas_c')
colnames <- c('meses_12', 'ventas_a', 'ventas_b', 'ventas_c')
names(ventas) <- names

# Otro ejemplo que suele convenir es crear un dataframe con el nombre y los valores de
# un raster, esto lo veremos más adelante
rst_lbl <- data.frame(value = 1:3,
                      class = c('Bosque', 'No bosque', 'Sin informacion'))

# Lectura de tablas csv (archivos de texto plano delimitados por coma)
getwd()
pib <- read.csv('../datos/tbl/GDP.csv')
read.csv('G:/Drive/fabiolexcastro5/Consultorias/SDM/datos/tbl/GDP.csv')

# Ver encabezado de la tabla 
head(pib)

# Ver primeras diez filas
head(pib, 10)

# Ver cinco últimas filas del dataframe 
tail(pib)
tail(pib, 10)

# Escritura de tablas csv 
write.csv(rst_lbl, '../datos/tbl/labels_bosque.csv', row.names = FALSE)

# AQUI LLEGAMOS -----------------------------------------------------------

# Lectura de tablas de excel dentro de R
# install.packages('readxl') # Esto solo se ejecuta una vez
library(readxl)
library(xlsx)

# Source: https://www.kaggle.com/andradaolteanu/2020-cost-of-living
# These indices are relative to New York City (NYC). Which means that for New York City, each index should be 100(%). If another city has, for example, rent index of 120, it means that on an average in that city rents are 20% more expensive than in New York City. If a city has rent index of 70, that means on average rent in that city is 30% less expensive than in New York City.
# The present data is extracted from Numbeo - Cost of Living for mid year 2020.
# Source of data can be found here: https://www.numbeo.com/cost-of-living/rankings_by_country.jsp
# Cost of Living Index (Excl. Rent) is a relative indicator of consumer goods prices, including groceries, restaurants, transportation and utilities. Cost of Living Index does not include accommodation expenses such as rent or mortgage. If a city has a Cost of Living Index of 120, it means Numbeo has estimated it is 20% more expensive than New York (excluding rent).
# Rent Index is an estimation of prices of renting apartments in the city compared to New York City. If Rent index is 80, Numbeo has estimated that price of rents in that city is on average 20% less than the price in New York.
# Groceries Index is an estimation of grocery prices in the city compared to New York City. To calculate this section, Numbeo uses weights of items in the "Markets" section for each city.
# Restaurants Index is a comparison of prices of meals and drinks in restaurants and bars compared to NYC.
# Cost of Living Plus Rent Index is an estimation of consumer goods prices including rent comparing to New York City.
# Local Purchasing Power shows relative purchasing power in buying goods and services in a given city for the average net salary in that city. If domestic purchasing power is 40, this means that the inhabitants of that city with an average salary can afford to buy on an average 60% less goods and services than New York City residents with an average salary.
# For more information about used weights (actual formula) please visit Motivation and Methodology page.

cst <- read_excel('../datos/tbl/Cost of living 2020.xlsx')
head(cst)
tail(cst)
dim(cst)
nrow(cst)
ncol(cst)
str(cst)

# Cambiar el nombre a los encabezados, pues estos deben evitar tener espacios en blanco 
colnames(cst) <- gsub(' ', '_', colnames(cst))

# Seleccionar ciertas filas y columnas dentro de una tabla 
# Hay dos caminos de seleccionar las columnas con la libreria base de R
cst_sub <- cst[,c(1, 2, 3)]
cst_sub <- cst[,c('Rank_2020', 'Country', 'Cost_of_Living_Index')]

cst_rnt <- cst[,c(1, 2, 4)]

# Escritura de archivos de excel dentro de R 
write.xlsx(x = cst_sub, file = '../datos/tbl/cost_of_living.xlsx', sheetName = 'CostLiving', append = FALSE)

# Escritura de más de una tabla de excel dentro de un mismo libro pero en diferentes hojas de R (haciendo uso de distintas hojas)
write.xlsx(x = cst_rnt, file = '../datos/tbl/cost_of_living.xlsx', sheetName = 'RentLiving', append = TRUE)
