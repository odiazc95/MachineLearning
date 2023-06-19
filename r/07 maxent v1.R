

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(raster, rgdal, rgeos, stringr, sf, tidyverse, 
               dismo, usdm, ENMeval, ecospat, rJava, gtools, 
               glue, fs)

g <- gc(reset = TRUE)
rm(list = ls())
options(scipen = 999)

# Load data ---------------------------------------------------------------
occ <- read_csv('../table/points/occ_v1.csv')
bck <- read_csv('../table/points/bck_v1.csv')
vrs <- readRDS(file = '../rds/vars_vif.rds')

# Climate data
fls <- list.files('../raster/worldclim/v20/1km/smo', full.names = TRUE, pattern = '.tif$')
fls <- fls[-grep('gwr', fls, value = FALSE)]
fls <- grep('bio', fls, value = TRUE)
vrs <- glue('{vrs}.tif$')
fls <- grep(paste0(vrs, collapse = '|'),  fls, value = TRUE) 
fls <- mixedsort(fls)
stk <- raster::stack(fls)

# Add IDS -----------------------------------------------------------------
occ.mtx <- occ[,c(2:ncol(occ))]
occ.mtx$pb <- 1
bck.mtx <- bck[,c(2:ncol(bck))]
bck.mtx$pb <- 0

colnames(occ.mtx)[1:2] <- c('x', 'y')
colnames(bck.mtx)

occ.mtx <- dplyr::select(occ.mtx, pb, everything())
bck.mtx <- dplyr::select(bck.mtx, pb, everything())

env <- rbind(occ.mtx, bck.mtx)

fld_occ <- kfold(occ.mtx, k = 25)
fld_bck <- kfold(bck.mtx, k = 25)

mdl <- map(.x = 1:25, .f = function(k){
  
  cat('Start ', k, '\n')
  tst <- occ.mtx[fld_occ == k,]
  trn <- occ.mtx[fld_occ != k,]
  tst_bck <- bck.mtx[fld_bck == k,]
  trn_bck <- bck.mtx[fld_bck != k,]
  
  env <- rbind(trn, trn_bck)
  y   <- c(trn$pb, trn_bck$pb)
  
  out <- glue('../maxent/run_2/model_{k}')
  ifelse(!file.exists(out), dir_create(out), print('Directorio existe'))
  
  mxn <- maxent(env[,4:ncol(env)], 
                y,
                arcgs = c('addsamplestobackground=true'),
                path = out)
  
  rst <- raster::predict(mxn, stk, progress = 'text')
  raster::writeRaster(x = rst, 
                      filename = glue('{out}/predict_crn.tif'), 
                      overwrite = TRUE)
  
  evl <- evaluate(mxn, 
                  p = data.frame(tst[,4:ncol(tst)]),
                  a = data.frame(tst_bck[,4:ncol(tst_bck)]))
  
  prc <- mxn@results %>% as.data.frame() 
  prc <- data.frame(variables = vrs, percentage = prc[grep('contribution', rownames(prc)),], rutin = k)
  
  auc <- evl@auc
  tss <- evl@TPR + evl@TNR - 1
  tss <- evl@t[which.max(tss)]
  dfm <- data.frame(routine = k, threshold = tss, auc = auc)
  
  return(list(rst, prc, dfm))
  
})

prd <- map(.x = 1:length(mdl), .f = function(k) mdl[[k]][1])
prd <- flatten(prd)
prd <- stack(prd)
plot(prd)

library(rasterVis)
levelplot(prd)

avg <- mean(prd)
sdt <- calc(prd, sd)

raster::writeRaster(avg, filename = '../maxent/run_2/predict_crn_avg.tif')
raster::writeRaster(sdt, filename = '../maxent/run_2/predict_crn_sdt.tif')


# Get the percentage of contribution --------------------------------------


prcn <- lapply(mdl, `[[`, 2) # lapply(1:length(mdl), function(k) mdl[[k]][[2]]) # Otro camino
prcn <- bind_rows(prcn)
class(prcn)
prcn <- as_tibble(prcn)
prcn <- mutate(prcn, variables = as.character(variables))
prcn <- mutate(prcn, variables = gsub('.tif', '', variables)) 
prcn <- mutate(prcn, variables = gsub('\\$', '', variables))

# Make a simple boxplot

vars <- pull(prcn, variables) %>% unique() %>% mixedsort()

prcn <- mutate(prcn, variables = factor(variables, levels = vars))

gbox <- ggplot(data = prcn, aes(x = variables, y = percentage)) + 
  geom_boxplot() +
  labs(x = 'Variables', y = 'Porcentaje (%)') +
  theme_bw() + 
  ggtitle(label = 'Porcentaje de contrbución de cada variable\n25 iterraciones') +
  theme(plot.title = element_text(size = 14, hjust = 0.5))

ggsave(plot = gbox, 
       filename = '../png/boxplot/boxplot_contribution.jpg', 
       units = 'in', width = 9, height = 7, dpi = 300)

# Contribution (average)
prcn_avrg <- aggregate(percentage ~ variables, prcn, mean)
prcn_avrg <- prcn_avrg %>% arrange(desc(percentage))

dir_create('../table/model/maxent/run_2')
write.csv(prcn_avrg, '../table/model/maxent/run_2/prcn_avrg_cntrb.csv', row.names = FALSE)
write.csv(prcn, '../table/model/maxent/run_2/prcn_cmpl_cntrb.csv', row.names = FALSE)

# Threhsolds --------------------------------------------------------------

thrs <- lapply(mdl, `[[`, 3)
thrs <- do.call(rbind, thrs)

# Boxplot AUC
boxplot(thrs$auc)

# Threshold
boxplot(thrs$threshold)
thrs_avrg <- mean(thrs$threshold)

# Rasters -----------------------------------------------------------------

plot(avg)

bin <- avg
bin[which(bin[] >= thrs_avrg)] <- 1
bin[which(bin[] <  thrs_avrg)] <- 0

writeRaster(bin, filename = '../maxent/run_2/predict_crn_bin.tif')

mdl

save(mdl, file = '../rData/mdl.rData')


