# tests/test_wind_join.R
# CoCT x JPAL Challenge
# Wind Data Integration Tests
suppressPackageStartupMessages({
library(testthat)
library(readr)
library(lubridate)
library(dplyr)
})
wind_path <- "data/processed/wind_bellville_2020.csv.gz"
joined_path <- "data/processed/sr_wind_joined.csv.gz"


test_that("Joined data has valid structure and timestamps", {
  joined_data <- read_csv(joined_path, show_col_types = FALSE)
  
  expect_true(all(c("creation_timestamp", "wind_speed_10m", "wind_direction_10m") %in% names(joined_data)))
  
  expect_false(any(is.na(joined_data$wind_speed_10m)))
})
