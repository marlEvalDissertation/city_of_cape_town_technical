# scripts/anonymise_sr_data.R
# CoCT x JPAL Challenge
# Anonymise Bellville South SR data with wind info

source("scripts/requirements.R")

suppressPackageStartupMessages({
library(dplyr)
library(readr)
library(lubridate)
library(h3jsr)
library(tictoc)
library(fs)
})

# Paths
input_path <- "data/processed/sr_wind_joined.csv.gz"
output_path <- "data/processed/sr_wind_anonymised.csv.gz"
log_path <- "logs/anonymise_log.txt"

tic("Anonymise SR data")

tryCatch({
  # Load data
  data <- read_csv(input_path, show_col_types = FALSE)
  
  # Check location columns
  if (!all(c("longitude", "latitude") %in% names(data))) {
    stop("Missing 'longitude' or 'latitude' columns in the dataset.")
  }
  
  # Remove identifying columns
  sensitive_cols <- c(
    "request_description", "caller_name", "street_address", "contact_number",
    "email", "gps_accuracy", "request_id", "user_id"
  )
  data <- data %>% select(-any_of(sensitive_cols))
  
  # Round creation time to nearest 6 hours (in Johannesburg time)
  data <- data %>%
    mutate(
      creation_timestamp = ymd_hms(creation_timestamp, tz = "UTC") %>%
        with_tz("Africa/Johannesburg"),
      rounded_time = floor_date(creation_timestamp, unit = "6 hours")
    )
  
  # Replace coordinates with H3 index
  data <- data %>%
    mutate(
      h3_500m = point_to_h3(data.frame(lat = latitude, lng = longitude), res = 8)
    ) %>%
    select(-longitude, -latitude, -creation_timestamp)
  
  # Reorder columns for clarity
  data <- data %>%
    relocate(rounded_time, h3_500m)
  
  # Write anonymised data
  dir_create(dirname(output_path))
  write_csv(data, output_path)
  
  # Log success
  elapsed <- toc(log = FALSE)
  log_msg <- paste0(
    Sys.time(), " - Anonymised data saved. Rows: ", nrow(data),
    ". Time: ", round(elapsed$toc - elapsed$tic, 2), " sec\n"
  )
  write(log_msg, file = log_path, append = TRUE)
  message(log_msg)
  
}, error = function(e) {
  elapsed <- toc(log = FALSE)
  log_msg <- paste0(
    Sys.time(), " - ERROR during anonymisation: ", e$message,
    " after ", round(elapsed$toc - elapsed$tic, 2), " sec\n"
  )
  write(log_msg, file = log_path, append = TRUE)
  stop(e)
})
