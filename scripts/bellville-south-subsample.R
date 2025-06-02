#scripts/bellville-south-subsample.R
#CoCT x JPAL challenge
#samples data from the sr_hex csv that is within 1 minute of the centroid of the Bellville south suburb

source("scripts/requirements.R")
source("scripts/get_bellville_centroid.R")

suppressPackageStartupMessages({
library(dplyr)
library(readr)
library(geosphere)
library(fs)
library(tictoc)
})

# File paths
input_path <- "data/raw/sr_hex.csv.gz"
output_path <- "data/processed/sr_bellville_south_subsample.csv.gz"
centroid_path <- "data/processed/bellville_centroid.csv"
log_path <- "logs/subsample_log.txt"

# Distance threshold
distance_threshold_km <- 1.85

# Start timing
tic("Bellville subsample filter")

tryCatch({
  # Check input exists
  if (!file_exists(input_path)) stop("Input file not found: ", input_path)
  if (!file_exists(centroid_path)) stop("Missing centroid file: ", centroid_path)
  
  # Load data
  sr_data <- read_csv(input_path, show_col_types = FALSE)
  centroid_df <- read_csv(centroid_path, show_col_types = FALSE)
  
  # Validate centroid structure
  if (!all(c("centroid_latitude", "centroid_longitude") %in% names(centroid_df))) {
    stop("Centroid file missing required columns.")
  }
  
  centroid <- c(
    centroid_df$centroid_longitude[1],
    centroid_df$centroid_latitude[1]
  )
  
  # Ensure required columns exist
  if (!all(c("longitude", "latitude") %in% names(sr_data))) stop("Missing required latitude/longitude columns.")
  
  # Filter non-missing coordinate rows
  sr_valid <- sr_data %>% filter(!is.na(longitude) & !is.na(latitude))
  
  # Compute distances to centroid meters
  distances <- distHaversine(sr_valid[, c("longitude", "latitude")], centroid) / 1000 
  
  # Add to dataframe
  sr_valid <- sr_valid %>% mutate(distance_to_centroid_km = distances)
  
  # Filter to those within 1.85km
  sr_filtered <- sr_valid %>% filter(distance_to_centroid_km <= distance_threshold_km)
  sr_filtered <- sr_filtered %>% select(-distance_to_centroid_km)
  
  # Save output
  write_csv(sr_filtered, output_path)
  
  # Logging
  elapsed <- toc(log = FALSE)
  log_msg <- paste0(
    Sys.time(), " - Filtered ", nrow(sr_filtered), " requests within ", distance_threshold_km,
    " km of Bellville South centroid. Time taken: ",
    round(elapsed$toc - elapsed$tic, 2), " sec\n"
  )
  write(log_msg, file = log_path, append = TRUE)
  message(log_msg)
  
}, error = function(e) {
  elapsed <- toc(log = FALSE)
  log_msg <- paste0(
    Sys.time(), " - ERROR during filtering: ", e$message,
    " after ", round(elapsed$toc - elapsed$tic, 2), " sec\n"
  )
  write(log_msg, file = log_path, append = TRUE)
  stop(e)
})
