# R version 4.3.2 (23-10-2023)
# Last run: 14-07-2025

## 1: Initial Setup

### clean enviroment
rm(list = ls())

### load/install packages
require(pacman)
p_load(tidyverse, rio, rvest, httr, RSelenium)

### url for downloading monthly global
url_base <- "https://wustl.app.box.com/v/ACAG-V5GL0502-GWRPM25/folder/293381989765"


## 2: Set-Up Docker

### run docker (mac)
# sudo docker run -d -p 4445:4444 -v "D:/temp:/home/seluser/Downloads" -v /dev/shm:/dev/shm selenium/standalone-firefox:2.53.0
# sudo docker ps

### run docker (windows)
# docker run -d -p 4445:4444 -v "D:/temp:/home/seluser/Downloads" -v /dev/shm:/dev/shm selenium/standalone-firefox:109.0
# docker ps

### connect to docker
remDr <- remoteDriver(browserName = "firefox", port = 4445L)
remDr$open()


## 3: Download Data

### navigate to website
remDr$navigate(url_base)

### click on global folder
global <- remDr$findElements(using = "css selector", value = "a[href*='folder/']")
global[[which(texts == "Global")]]$clickElement()

### click on monthly
monthly <- remDr$findElements(using = "css selector", value = "a[href*='folder/']")
monthly[[which(texts == "Monthly")]]$clickElement()

### click on download button
download <- remDr$findElement(using = "css selector", value = "button[data-testid='download-button']")
download$clickElement()

### close docker
remDr$close()

### stop docker (mac)
# sudo docker stop $(sudo docker ps -q)

### stop docker (windows)
# for /f %i in ('docker ps -q') do docker stop %


## 4: Prepare Data

### set unzip direction
zip_file <- "D:/temp/Monthly.zip"
output <- "01_download_pm25/output/"

dir.create(output, showWarnings = FALSE, recursive = TRUE)

### extract only year 2013 to 2023
zip_contents <- unzip(zip_file, list = TRUE)$Name
years <- 2013:2023
pattern <- paste0(years, collapse = "|")
filtered_files <- zip_contents[grepl(pattern, zip_contents)]

### extract files
unzip(zip_file, files = filtered_files, exdir = output)


