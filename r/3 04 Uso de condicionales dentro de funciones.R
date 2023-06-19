

# Ejecucion condicional
# Cuando se quiere forzar la ejecucción de alguna parte del programa según el resultado
# de la evaluación de una condición lógica se ejecuta una estructura de control. 
# El ifelse o if(){} else() es una de ellas

dia <- c('soleado', 'lluvioso')
x <- sample(dia, 1)

if(x == 'soleado'){
  print('Salir a pasear')
} else {
  print('Salir con sombrilla')
}



# Genere un número aleatorio y compruebe si es par o no 
x <- sample(1:100, 1)
if(x %% 2 == 0) {
  print('Es par')
} else {
  print('Es impar')
}

# Uso del ifelse
# Es uina version más cota de if/else que se evalúa si cada uno de los elementos de un vector
# cumple con una condición
x <- c(2, 3, -5, 6, -2)
texto <- ifelse(x > 0, 'positivo', 'negativo')
data.frame(x = x, texto = texto)

# Lectura de tablas 
cffe <- read.csv('../datos/tbl/cafe.csv')
cffe <- cffe[,c(1, 2, 3, 4, 10, 11, 12)]
colnames(cffe)
colnames(cffe) <- c('cod_dpto', 'dpto', 'cod_mpio', 'mpio', 'periodo', 'area_smb', 'area_csh')
head(cffe)

cffe$area_smb <- as.numeric(gsub(',', '', cffe$area_smb))
cffe$area_csh <- as.numeric(gsub(',', '', cffe$area_csh))

# Ahora crear un dataframe para todos y cada uno de los departamentos
# que contenga la cantidad de municipios que no tienen diferencias entre 
# su cantidad de area sembrada y cosechada para el año 2019, es decir, que esta diferencia sea igual a cero 

cffe <- cffe[which(cffe$periodo == 2019),]
dpto <- unique(cffe$dpto)

get_difference <- function(dpt){
  
  print(dpt)
  sub <- cffe[which(cffe$dpto == dpt),]
  sub$dfrn <- sub$area_csh - sub$area_smb 
  sub$zero <- ifelse(sub$dfrn == 0, 'Cero', 'No cero')
  rsl <- as.data.frame(table(sub$zero))
  names(rsl) <- c('Tipo', 'Cantidad')
  return(rsl)
  
}

zero <- lapply(dpto, get_difference)
zero
zero <- do.call(rbind, zero)
write.csv(zero, '../output/tbl/cffe_zero_2019.csv', row.names = FALSE)









