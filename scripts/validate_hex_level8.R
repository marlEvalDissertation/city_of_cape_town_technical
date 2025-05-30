# scripts/validate_hex_level8.R
# CoCT JPAL challenge

#Compares data downloaded in hex_polygons_8 to data extract made from polygons-8-10 into hex-polygons-8(new).
# all data should be level/resolution 8

source("scripts/requirements.R")

library(sf)
library(dplyr)
library(testthat)

processed_path <- "data/processed/city-hex-polygons-8(new).geojson"
reference_path <- "data/raw/city-hex-polygons-8.geojson"
log_path <- "logs/validation_log.txt"

# Ensure reference file exists
if (!file.exists(reference_path)) {
  message("Downloading reference file...")
  download.file(
    url = "https://cct-ds-code-challenge-input-data.s3.af-south-1.amazonaws.com/city-hex-polygons-8.geojson",
    destfile = reference_path,
    mode = "wb"
  )
}

tryCatch({
  geo_processed <- st_read(processed_path, quiet = TRUE)
  geo_reference <- st_read(reference_path, quiet = TRUE)
  
  # Validate number of polygons and column names
  same_n <- nrow(geo_processed) == nrow(geo_reference)
  same_names <- all(names(geo_processed) == names(geo_reference))
  same_geom <- identical(st_geometry_type(geo_processed), st_geometry_type(geo_reference))
  
  # Write log
  validation_result <- paste0(
    Sys.time(), " - Rows match: ", same_n,
    ", Colnames match: ", same_names,
    ", Geometry match: ", same_geom, "\n"
  )
  
  write(validation_result, file = log_path, append = TRUE)
  
  message("Validation complete. See logs/validation_log.txt")
  
}, error = function(e) {
  write(paste(Sys.time(), "- ERROR:", e$message), file = log_path, append = TRUE)
  stop(e)
})
