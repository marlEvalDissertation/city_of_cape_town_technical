# scripts/download_wind_data.R
# CoCT x JPAL Challenge
# Download and clean 2020 wind data for Bellville South

source("scripts/requirements.R")

library(httr)
library(readr)
library(dplyr)
library(lubridate)
library(fs)
library(tictoc)
library(jsonlite)

# Paths
centroid_path <- "data/processed/bellville_centroid.csv"
output_path <- "data/processed/wind_bellville_2020.csv.gz"
log_path <- "logs/wind_download_log.txt"

# Load centroid coordinates
centroid <- read_csv(centroid_path, show_col_types = FALSE)

if (!all(c("centroid_longitude", "centroid_latitude") %in% names(centroid))) {
  stop("Centroid file is missing required longitude and latitude columns.")
}

lon <- centroid$centroid_longitude[1]
lat <- centroid$centroid_latitude[1]

# API URL using Open-Meteo
url <- paste0(
  "https://archive-api.open-meteo.com/v1/archive?",
  "latitude=", latitude,
  "&longitude=", longitude,
  "&start_date=2020-01-01&end_date=2020-12-31",
  "&hourly=wind_speed_10m,wind_direction_10m",
  "&timezone=Africa%2FJohannesburg"
)

# Start timing
tic("Wind data download")

tryCatch({
  # Request data
  response <- GET(url)
  if (http_error(response)) stop("Failed to download wind data.")
  
  # Parse content
  json_data <- content(response, as = "text", encoding = "UTF-8")
  parsed <- fromJSON(json_data)
  
  # Extract and clean data
  wind_data <- parsed$hourly %>%
    as_tibble() %>%
    mutate(
      timestamp = ymd_hm(gsub("T", " ", time), tz = "Africa/Johannesburg")
    ) %>%
    select(timestamp, wind_speed_10m, wind_direction_10m)
  
  # Save output
  dir_create(dirname(output_path))
  write_csv(wind_data, output_path)
  
  # Logging
  elapsed <- toc(log = FALSE)
  log_msg <- paste0(
    Sys.time(), " - Downloaded and saved ", nrow(wind_data),
    " hourly wind observations. Time taken: ",
    round(elapsed$toc - elapsed$tic, 2), " sec\n"
  )
  write(log_msg, file = log_path, append = TRUE)
  message(log_msg)
  
}, error = function(e) {
  elapsed <- toc(log = FALSE)
  log_msg <- paste0(
    Sys.time(), " - ERROR during wind data download: ", e$message,
    " after ", round(elapsed$toc - elapsed$tic, 2), " sec\n"
  )
  write(log_msg, file = log_path, append = TRUE)
  stop(e)
})

