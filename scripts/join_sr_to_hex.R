# scripts/join_sr_to_hex.R
# CoCT JPAL Challenge 
# Join service requests to hex level 8

source("scripts/requirements.R")

suppressPackageStartupMessages({
library(dplyr)
library(readr)
library(sf)
library(tictoc)
library(fs)
})

# Required input files
required_files <- c(
  "data/raw/sr.csv.gz"
)

# Check if all files exist
if (!all(file_exists(required_files))) {
  message("Missing required files. Running download script...")
  system("Rscript scripts/download_sr_data.R")
  
  # Recheck files after download
  if (!all(file_exists(required_files))) {
    stop("Required files still missing after attempting download.")
  }
}


# File paths
hex_path <- "data/processed/city-hex-polygons-8(new).geojson"
sr_path <- "data/raw/sr.csv.gz"
output_path <- "data/processed/sr_with_hex.csv.gz"
log_path <- "logs/join_log.txt"

# Join error threshold
join_threshold <- 0.25
# We set join_threshold to 25% based on observed 22.55% join failure rate.
# This accommodates missing or malformed coordinates typical in service data,
# while still flagging major failures if join rate drops significantly.

# Start timing
tic("Service request hex join")

tryCatch({
  # Read in data
  hex <- st_read(hex_path, quiet = TRUE)
  sr_raw <- suppressMessages(read_csv(sr_path, col_types = cols(`...1` = col_skip()), show_col_types = FALSE))  
  
  # Convert to sf for spatial join
  sr_sf <- sr_raw %>%
    filter(!is.na(latitude) & !is.na(longitude)) %>%
    st_as_sf(coords = c("longitude", "latitude"), crs = 4326, remove = FALSE)
  
  # Spatial join
  hex <- st_transform(hex, st_crs(sr_sf))
  sr_joined <- st_join(sr_sf, hex["index"], left = TRUE)
  
  # Add back missing rows and assign index = 0
  sr_missing <- sr_raw %>%
    filter(is.na(latitude) | is.na(longitude)) %>%
    mutate(index = 0)
  
  # Combine full data
  sr_joined$index <- as.character(sr_joined$index)
  sr_missing$index <- as.character(sr_missing$index)
  final <- bind_rows(
    sr_joined %>% st_drop_geometry(),
    sr_missing
  )
  
  # Write output
  write_csv(final, output_path)
  
  # Check join quality
  n_total <- nrow(sr_raw)
  n_joined <- sum(!is.na(final$index) & final$index != 0)
  join_rate <- n_joined / n_total
  
  # Log results
  elapsed <- toc(log = FALSE)
  log_msg <- paste(
    Sys.time(), "- Joined", n_joined, "of", n_total,
    sprintf("(%.2f%% success)", 100 * join_rate),
    "- Time:", round(elapsed$toc - elapsed$tic, 2), "s\n"
  )
  write(log_msg, file = log_path, append = TRUE)
  
  if ((1 - join_rate) > join_threshold) {
    stop(sprintf("Join failure rate exceeded threshold (%.2f%%)", 100 * join_threshold))
  }
  
  message("Join complete. Output saved to ", output_path)
  
}, error = function(e) {
  elapsed <- toc(log = FALSE)
  write(paste(Sys.time(), "- ERROR:", e$message, "- after", elapsed$toc - elapsed$tic, "seconds\n"), file = log_path, append = TRUE)
  stop(e)
})
