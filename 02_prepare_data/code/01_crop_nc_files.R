# R version 4.3.2 (23-10-2023)
# Last run: 14-07-2025

## 1: Initial Setup

### clean enviroment
rm(list = ls())

### load/install packages
require(pacman)
p_load(terra, osmdata, fs, mapview, tidyverse, ncdf4)

### load Cali's shape
poly <- getbb(place_name = "Cali, Colombia", featuretype = "boundary:administrative",
              format_out = "sf_polygon")
poly <- poly[2, ]
mapview(poly)

poly_v <- vect(poly)

### set objects for function
input <- "01_download_pm25/output/Monthly/"
output <- "02_prepare_data/temp/"
dir.create(output, showWarnings = FALSE)


## 2: Crop pm25
crop_pm25 <- function(input, output) {
  
  # get nc files
  nc <- dir(input, pattern = "\\.(nc|NC)$", full.names = TRUE)
  
  for (file in nc) {
    
    # read file
    r <- rast(file)
    
    # crop polygon
    r_crop <- crop(r, poly_v, mask = TRUE)
    
    # set file name
    date <- str_extract(basename(file), "20[0-9]{4}")
    
    # export raster
    writeRaster(r_crop, paste0(output, "pm25_", date, ".tif"), overwrite = TRUE)
  }
}

crop_pm25(input, output)
