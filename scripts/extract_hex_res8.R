# scripts/extract_hex_res8.R
# CoCT JPAL challenge

#Extracts data from source URLs
#Possible to instead use AWS credentials provided - not working.

source("scripts/requirements.R")

suppressPackageStartupMessages({
library(aws.s3)
library(sf)
library(jsonlite)
library(tictoc)
library(fs)
})


url <- "https://cct-ds-code-challenge-input-data.s3.af-south-1.amazonaws.com/city-hex-polygons-8-10.geojson"
url2 <- "https://cct-ds-code-challenge-input-data.s3.af-south-1.amazonaws.com/city-hex-polygons-8.geojson" 
raw_path <- "data/raw/city-hex-polygons-8-10.geojson"
processed_path <- "data/processed/city-hex-polygons-8(new).geojson"
log_path <- "logs/extraction_log.txt"

tic("Hex level 8 extraction")

tryCatch({
  if (!file.exists(raw_path)) {
    message("Downloading city-hex-polygons-8-10.geojson...")
    download.file(url, destfile = raw_path, mode = "wb")
  }
  
  
  # read in file
  geo_all <- st_read(raw_path, quiet = TRUE)
  
  # Check resolution column (commonly named 'resolution' or 'level')
  res_col <- grep("res|level", names(geo_all), value = TRUE)
  if (length(res_col) != 1) stop("Could not uniquely identify resolution column")
  
  # Filter to resolution 8
  geo_lvl8 <- geo_all[geo_all[[res_col]] == 8, ]
  
  # Save filtered data
  st_write(geo_lvl8, processed_path, delete_dsn = TRUE, quiet = TRUE)
  
  message("Extraction complete. Level 8 polygons saved to ", processed_path)
  
  elapsed <- toc(log = FALSE)
  write(paste(Sys.time(), "-", elapsed$toc - elapsed$tic, "seconds"), file = log_path, append = TRUE)
  
}, error = function(e) {
  elapsed <- toc(log = FALSE)
  write(paste(Sys.time(), "- ERROR:", e$message, "- after", elapsed$toc - elapsed$tic, "seconds"), file = log_path, append = TRUE)
  stop(e)
})

