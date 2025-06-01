#scripts/validate_sr_result.R
# CoCT x JPAL challenge
# Minimal validation script for sr_with_hex.csv.gz

source("scripts/requirements.R")

suppressPackageStartupMessages({
library(readr)
library(dplyr)
library(tictoc)
})

# File paths
result_path <- "data/processed/sr_with_hex.csv.gz"
reference_path <- "data/raw/sr_hex.csv.gz"
log_path <- "logs/validation_sr_log.txt"

# read data
result <- read_csv(result_path, show_col_types = FALSE)
reference <- read_csv(reference_path, show_col_types = FALSE)

#validation 
reference <- reference %>% rename(index = h3_level8_index)
validation_pass <- nrow(result) == nrow(reference) &&
all(sort(unique(result$index)) %in% sort(unique(reference$index)))
  
  log_msg <- paste0(
    Sys.time(), " - Validation result: ", validation_pass,
    " | Row match: ", nrow(result) == nrow(reference),
    " | Index match: ", all(sort(unique(result$index)) %in% sort(unique(reference$index)))
  )
  
  write(log_msg, file = log_path, append = TRUE)
  message(log_msg)
  
