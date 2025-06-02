# scripts/join_wind.R
# CoCT x JPAL Challenge
# Join Bellville South subsample with 2020 wind data by nearest previous hour

source("scripts/requirements.R")

suppressPackageStartupMessages({
library(dplyr)
library(readr)
library(lubridate)
library(tictoc)
library(fs)
library(data.table)
})

# Paths
subsample_path <- "data/processed/sr_bellville_south_subsample.csv.gz"
wind_data_path <- "data/processed/wind_bellville_2020.csv.gz"
output_path <- "data/processed/sr_wind_joined.csv.gz"
log_path <- "logs/join_wind_log.txt"

tic("Join wind data with subsample")

tryCatch({
  
  if (!file_exists(subsample_path)) stop("Subsample file not found: ", subsample_path)
  if (!file_exists(wind_data_path)) stop("Wind data file not found: ", wind_data_path)
  
  sr_data <- read_csv(subsample_path, show_col_types = FALSE)
  
  # Validate creation_timestamp column
  if (!"creation_timestamp" %in% names(sr_data)) stop("Missing 'creation_timestamp' column in subsample data.")
  
  # Parse creation_timestamp as UTC then convert to Africa/Johannesburg
  sr_data <- sr_data %>%
    mutate(
      creation_timestamp_utc = ymd_hms(creation_timestamp, tz = "UTC"),
      creation_timestamp_loc = with_tz(creation_timestamp_utc, "Africa/Johannesburg")
    )
    
  # Load wind data
  wind_data <- read_csv(wind_data_path, show_col_types = FALSE)
  
  # Validate columns
  required_wind_cols <- c("timestamp", "wind_speed_10m", "wind_direction_10m")
  if (!all(required_wind_cols %in% names(wind_data))) stop("Wind data missing required columns.")
  
  # Convert wind_data timestamp to POSIXct with Africa/Johannesburg timezone
  if (!inherits(wind_data$timestamp, "POSIXct")) {
    wind_data <- wind_data %>%
      mutate(timestamp = with_tz(ymd_hms(timestamp, tz = "UTC"), "Africa/Johannesburg"))
  }
  
  
  # Prepare data.tables for rolling join on timestamps
  dt_sr <- data.table(sr_data)
  dt_wind <- data.table(wind_data)
  
  setkey(dt_sr, creation_timestamp_loc)
  setkey(dt_wind, timestamp)
  
  # Rolling join for each creation_timestamp, find latest wind_data timestamp <= creation_timestamp
  joined <- dt_wind[dt_sr, roll = TRUE]
  
  result <- as_tibble(joined) %>% select(-creation_timestamp_utc) %>% select(-timestamp)
  
  dir_create(dirname(output_path))
  write_csv(result, output_path)
  
  elapsed <- toc(log = FALSE)
  log_msg <- paste0(
    Sys.time(), " - Successfully joined wind data to subsample. Rows: ", nrow(result),
    ". Time taken: ", round(elapsed$toc - elapsed$tic, 2), " sec\n"
  )
  write(log_msg, file = log_path, append = TRUE)
  message(log_msg)
  
}, error = function(e) {
  elapsed <- toc(log = FALSE)
  log_msg <- paste0(
    Sys.time(), " - ERROR during join: ", e$message,
    " after ", round(elapsed$toc - elapsed$tic, 2), " sec\n"
  )
  write(log_msg, file = log_path, append = TRUE)
  stop(e)
})
