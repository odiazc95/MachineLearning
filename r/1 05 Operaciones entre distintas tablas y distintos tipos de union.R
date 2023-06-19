

# Lectura de tablas 
gdp <- read.csv('../datos/tbl/GDP.csv')
head(gdp)
tail(gdp)
nrow(gdp)
ncol(gdp)
dim(gdp)

# Seleccion de las columnas de los años 2010 a 2018
colnames(gdp)
gdp_sub <- gdp[,c(1:2, 24:31)]

# Seleccionar casos 
gdp_col <- gdp_sub[which(gdp_sub$Country == 'Colombia'),]
gdp_per <- gdp_sub[which(gdp_sub$Country == 'Peru'),]

# Ahora bien, como seleccionar ambas condiciones dentro de una sola 
gdp_col_per <- gdp_sub[which(gdp_sub$Country %in% c('Colombia', 'Peru')),]
write.csv(gdp_col_per, '../output/tbl/gpd_col_per.csv')

# Lectura de tabla gold price
library(readxl)
gold <- read_excel('../datos/tbl/Gold_Prices.xlsx')
colnames(gold)
gold <- gold[,c(1, 2)]
colnames(gold) <- c('date', 'dollar') 

# install.packages('lubridate')
library(lubridate)

gold$year <- year(gold$date)
gold$mnth <- month(gold$date)
gold$day  <- day(gold$date)
gold$hour <- hour(gold$date)
unique(gold$hour)
unique(gold$year)

gold <- gold[-which(gold$year == 1978),]

# Calculo del promedio de año tras año - Funcion Aggregate
gold_year <- aggregate(dollar ~ year, data = gold, mean, na.rm = TRUE)
gold_year$dollar <- round(gold_year$dollar, digits = 0)

# Un simple sencillo 
plot(gold_year$dollar, type = 'l', cex.lab = 1.2, xlab = '', ylab = 'Dollar')
plot(gold_year$dollar, type = 'b', cex.lab = 1.2, xlab = '', ylab = 'Dollar')
plot(gold_year$dollar, type = 'c', cex.lab = 1.2, xlab = '', ylab = 'Dollar')
plot(gold_year$dollar, type = 'o', cex.lab = 1.2, xlab = '', ylab = 'Dollar')

write.csv(gold_year, '../output/tbl/gold_years.csv', row.names = FALSE)

# Boletin eva - Datos agricolas (Cafe y Cacao)
cafe <- read.csv('../datos/tbl/cafe.csv')
cacao <- read.csv('../datos/tbl/cacao.csv')

head(cafe)
head(cacao)

# Limpieza de tablas 
colnames(cafe)
colnames(cacao)

cafe <- cafe[,c(1, 2, 3, 4, 7, 9, 10, 11:14)]
head(cafe)
cacao <- cacao[,c(1, 2, 3, 4, 7, 9, 10, 11:14)]
head(cacao)

# Cambio de los nombres de las columnas
col_names <- c('cd_dpto', 'dpto', 'cd_mpio', 'mpio', 'cultivo',
               'anio', 'periodo', 'area_smb', 'area_csh', 'prod', 'rdto')
colnames(cafe) <- col_names
colnames(cacao) <- col_names



head(cafe)
head(cacao)

# Ahora queremos responder la pregunta, cuales son los municipios que cultivan tanto Colombia para
# el anio 2019

# Seleccion de las columnas de interes
cafe_sub <- cafe[,c('cd_mpio', 'dpto', 'mpio', 'anio', 'area_csh')]
cacao_sub <- cacao[,c('cd_mpio', 'dpto', 'mpio', 'anio', 'area_csh')]

head(cafe_sub)
head(cacao_sub)

# Seleccion unicamente para el anio 2019
cafe_sub_2019 <- cafe_sub[which(cafe_sub$anio == 2019),]
cacao_sub_2019 <- cacao_sub[which(cacao_sub$anio == 2019),]

str(cafe_sub_2019)
str(cacao_sub_2019)
cafe_sub_2019$area_csh <- gsub('\\,', '', cafe_sub_2019$area_csh)
cafe_sub_2019$area_csh <- as.numeric(cafe_sub_2019$area_csh)
cacao_sub_2019$area_csh <- gsub('\\,', '', cacao_sub_2019$area_csh)
cacao_sub_2019$area_csh <- as.numeric(cacao_sub_2019$area_csh)

head(cafe_sub_2019)
head(cacao_sub_2019)

colnames(cafe_sub_2019)[5] <- 'area_csh_cafe'
colnames(cacao_sub_2019)[5] <- 'area_csh_cacao'

# Uso de la funcion merge
nrow(cafe_sub_2019)
nrow(cacao_sub_2019)
 
# Municipios que cultivan cafe y cacao a la vez
cafe_cacao <- merge(x = cafe_sub_2019, 
                    y = cacao_sub_2019, 
                    by.x = c('cd_mpio', 'dpto', 'mpio', 'anio'),
                    by.y = c('cd_mpio', 'dpto', 'mpio', 'anio')) 
nrow(cafe_cacao)

# Todos los municipios que cultivan cafe mas los municipios que cultivan cacao
cafe_all_cacao <- merge(x = cafe_sub_2019, 
                        y = cacao_sub_2019, 
                        by.x = c('cd_mpio', 'dpto', 'mpio', 'anio'), 
                        by.y = c('cd_mpio', 'dpto', 'mpio', 'anio'), 
                        all.x = TRUE)
nrow(cafe_all_cacao)

# Todos los municipios que cultivan cacao mas los municipios que cultivan cacao
cafe_cacao_all <- merge(x = cafe_sub_2019, 
                        y = cacao_sub_2019, 
                        by.x = c('cd_mpio', 'dpto', 'mpio', 'anio'), 
                        by.y = c('cd_mpio', 'dpto', 'mpio', 'anio'), 
                        all.y = TRUE)
nrow(cafe_cacao_all)

# Calcular el valor acumulado de area cosechada para cada departamento, agregacion 
cafe_sub_2019_dpto <- aggregate(area_csh_cafe ~ dpto, data = cafe_sub_2019, sum, na.rm = TRUE)
cacao_sub_2019_dpto <- aggregate(area_csh_cacao ~ dpto, data = cacao_sub_2019, sum, na.rm = TRUE)

# Filtrar para el cacao los departamentos que cultivan 0 hectareas
cacao_sub_2019_dpto <- cacao_sub_2019_dpto[-which(cacao_sub_2019_dpto$area_csh_cacao == 0),] #Uso del signo de admiracion

# Calculo del promedio de area cacao a nivel departamental 
mean(cafe_sub_2019_dpto$area_csh_cafe)
mean(cacao_sub_2019_dpto$area_csh_cacao)
      
# Escritura de tablas, mas adelante haremos uso de estas tablas 
write.csv(cafe, '../output/tbl/cafe_all.csv', row.names = FALSE)
write.csv(cacao, '../output/tbl/cacao_all.csv', row.names = FALSE)
write.csv(cafe_sub_2019, '../output/tbl/cafe_sub_2019.csv', row.names = FALSE)
write.csv(cacao_sub_2019, '../output/tbl/cacao_sub_2019.csv', row.names = FALSE)
write.csv(cafe_cacao, '../output/tbl/cafe_cacao.csv', row.names = FALSE)


