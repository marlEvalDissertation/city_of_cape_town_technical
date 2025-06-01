# tests/test_wind_data.R
# Unit tests for downloaded wind data

source("scripts/requirements.R")

library(testthat)
library(readr)
library(lubridate)
library(fs)

# File path
wind_path <- "data/processed/wind_bellville_2020.csv.gz"

test_that("Wind data file exists", {
  expect_true(file_exists(wind_path))
})

test_that("Wind data has required columns", {
  data <- read_csv(wind_path, show_col_types = FALSE)
  expect_true(all(c("timestamp", "wind_speed_10m", "wind_direction_10m") %in% names(data)))
})

test_that("Wind speed and direction have no missing values", {
  data <- read_csv(wind_path, show_col_types = FALSE)
  expect_false(any(is.na(data$wind_speed_10m)))
  expect_false(any(is.na(data$wind_direction_10m)))
})
