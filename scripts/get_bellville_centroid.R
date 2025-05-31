# scripts/get_bellville_centroid.R
# CoCT x JPAL Challenge
# Derives centroid of Bellville South from service request data

source("scripts/requirements.R")

library(dplyr)
library(readr)
library(fs)
library(tictoc)

# File paths
input_path <- "data/processed/sr_with_hex.csv.gz"
output_path <- "data/processed/bellville_centroid.csv"
log_path <- "logs/centroid_log.txt"

# Start timing
tic("Bellville centroid computation")

tryCatch({
  if (!file_exists(input_path)) stop("Input file not found: ", input_path)
  
  sr_data <- read_csv(input_path, show_col_types = FALSE)
  
  if (!all(c("latitude", "longitude", "official_suburb") %in% names(sr_data))) {
    stop("Missing required columns: latitude, longitude, or suburb.")
  }
  
  bellville_data <- sr_data %>%
    filter(!is.na(latitude), !is.na(longitude)) %>%
    filter(grepl("Bellville South", official_suburb, ignore.case = TRUE))
  
  if (nrow(bellville_data) == 0) stop("No Bellville South records found in service request data.")
  
  centroid <- bellville_data %>%
    summarise(
      centroid_latitude = mean(latitude),
      centroid_longitude = mean(longitude)
    )
  
  write_csv(centroid, output_path)
  
  elapsed <- toc(log = FALSE)
  log_msg <- paste0(
    Sys.time(), " - Calculated Bellville South centroid (",
    round(centroid$centroid_latitude, 6), ", ", round(centroid$centroid_longitude, 6),
    "). Time: ", round(elapsed$toc - elapsed$tic, 2), " sec\n"
  )
  write(log_msg, file = log_path, append = TRUE)
  message(log_msg)
  
}, error = function(e) {
  elapsed <- toc(log = FALSE)
  log_msg <- paste0(
    Sys.time(), " - ERROR in centroid calculation: ", e$message,
    " after ", round(elapsed$toc - elapsed$tic, 2), " sec\n"
  )
  write(log_msg, file = log_path, append = TRUE)
  stop(e)
})
