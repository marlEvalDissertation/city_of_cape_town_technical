# scripts/download_sr_data.R
# CoCT JPAL Challenge 
# Download Service Request Datasets

source("scripts/requirements.R")

suppressPackageStartupMessages({
library(tictoc)
library(fs)
})

# File paths
urls <- list(
  sr = "https://cct-ds-code-challenge-input-data.s3.af-south-1.amazonaws.com/sr.csv.gz",
  sr_hex = "https://cct-ds-code-challenge-input-data.s3.af-south-1.amazonaws.com/sr_hex.csv.gz"
)

paths <- list(
  sr = "data/raw/sr.csv.gz",
  sr_hex = "data/raw/sr_hex.csv.gz"
)

log_path <- "logs/download_sr_log.txt"

# Start timer
tic("Download SR data")

tryCatch({
  for (name in names(urls)) {
    url <- urls[[name]]
    dest <- paths[[name]]
    
    if (!file_exists(dest)) {
      message("Downloading ", name, " data...")
      download.file(url, destfile = dest, mode = "wb")
    } else {
      message(name, " data already exists. Skipping download.")
    }
  }
  
  elapsed <- toc(log = FALSE)
  write(paste(Sys.time(), "- Downloaded service request datasets in", round(elapsed$toc - elapsed$tic, 2), "seconds\n"),
        file = log_path, append = TRUE)
  
}, error = function(e) {
  elapsed <- toc(log = FALSE)
  write(paste(Sys.time(), "- ERROR:", e$message, "- after", round(elapsed$toc - elapsed$tic, 2), "seconds\n"),
        file = log_path, append = TRUE)
  stop(e)
})
