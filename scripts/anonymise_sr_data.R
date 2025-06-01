# scripts/anonymise_sr_data.R
# CoCT x JPAL Challenge
# Anonymise Bellville South SR data with wind info

source("scripts/requirements.R")

suppressPackageStartupMessages({
library(dplyr)
library(readr)
library(lubridate)
library(tictoc)
library(fs)
})

input_path <- "data/processed/sr_wind_joined.csv.gz"
output_path <- "data/processed/sr_wind_anonymised.csv.gz"
log_path <- "logs/anonymise_log.txt"

tic("Anonymise SR data")

tryCatch({
  data <- read_csv(input_path, show_col_types = FALSE)
  
  # Convert creation_timestamp to Africa/Johannesburg timezone, round to 6 hours
  data <- data %>%
    mutate(
      creation_timestamp = ymd_hms(creation_timestamp, tz = "Africa/Johannesburg"),
      anonymised_time = floor_date(creation_timestamp, unit = "6 hours")
    )
  
  # Select columns to keep for anonymised output
  anonymised <- data %>%
    select(
      anonymised_time,
      wind_speed_10m,
      wind_direction_10m,
      official_suburb,
      h3_level8_index,
      directorate,
      department,
      branch,
      section,
      code_group,
      code,
      cause_code_group,
      cause_code
    )
  
  # Save anonymised data
  dir_create(dirname(output_path))
  write_csv(anonymised, output_path)
  
  elapsed <- toc(log = FALSE)
  log_msg <- paste0(
    Sys.time(), " - Anonymised data saved. Rows: ", nrow(anonymised),
    ". Time taken: ", round(elapsed$toc - elapsed$tic, 2), " sec\n"
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

