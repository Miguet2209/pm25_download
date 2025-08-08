# R version 4.3.2 (23-10-2023)
# Last run: 15-07-2025

## 1: Initial Setup

### clean enviroment
rm(list = ls())

### load/install packages
require(pacman)
p_load(terra, tidyverse, rio, sf)


## 2: Import Data

### files location
input <- "02_prepare_data/temp/"

### files names
files <- list.files(input, pattern = "\\.tif$", full.names = TRUE)

### grid
grid <- import("C:/Users/migue/OneDrive/Escritorio/Work/CIENFI/IAE_CIENFI/R/01_night_lights/03_combine_data/output/poly_grids_cali.rds") %>%
  st_as_sf() %>%
  st_transform(crs = "EPSG:4326") %>%
  vect()

head(names(grid))
  
 
## 3: Get Mean per Month

pm25 <- lapply(files, function(f) {
  
  # import raster
  r <- rast(f)
  
  # make sure crs are the same
  r <- project(r, crs(grid))
  
  # extract year and month
  date <- str_extract(basename(f), "\\d{6}")
  year <- substr(date, 1, 4)
  month <- substr(date, 5, 6)
  
  # get results
  vals <- terra::extract(r, grid)
  vals$id <- grid$id[vals$ID]
  
  # get data frame with results
  df <- vals %>%
    group_by(id) %>%
    summarise(pm25 = mean(GWRPM25, na.rm = TRUE)) %>%
    mutate(year = year, month = month) %>%
    ungroup()
  
  return(df)

}) %>%
  bind_rows() %>%
  arrange(year, month)


## 4: Export Data
export(pm25, "02_prepare_data/output/pm25_monthly_2013_2023.rds")
