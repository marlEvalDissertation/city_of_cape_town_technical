# tests/test_anonymisation.R
# CoCT x JPAL data science challenge
# test of anonymisation script

source("scripts/requirements.R")

suppressPackageStartupMessages({
library(testthat)
library(readr)
library(dplyr)
library(lubridate)
})

anonymised_path <- "data/processed/sr_wind_anonymised.csv.gz"

test_that("Anonymised file exists and loads", {
  expect_true(file.exists(anonymised_path))
  df <- read_csv(anonymised_path, show_col_types = FALSE)
  expect_s3_class(df, "data.frame")
})

test_that("No direct identifiers remain", {
  df <- read_csv(anonymised_path, show_col_types = FALSE)
  expect_false("notification_number" %in% names(df))
  expect_false("reference_number" %in% names(df))
  expect_false("latitude" %in% names(df))
  expect_false("longitude" %in% names(df))
  expect_false("completion_timestamp" %in% names(df))
})

test_that("Temporal anonymisation is within 6-hour bins", {
  df <- read_csv(anonymised_path, show_col_types = FALSE)
  expect_true("anonymised_time" %in% names(df))
  
  # Check if all times are at 00:00, 06:00, 12:00 or 18:00
  hrs <- hour(df$anonymised_time)
  expect_true(all(hrs %in% c(0, 6, 12, 18)))
})

test_that("Spatial anonymisation preserves h3 index", {
  df <- read_csv(anonymised_path, show_col_types = FALSE)
  expect_true("h3_level8_index" %in% names(df))
  expect_type(df$h3_level8_index, "character")
  expect_true(all(nchar(df$h3_level8_index) > 0))
})

test_that("Contextual fields needed for analysis are retained", {
  df <- read_csv(anonymised_path, show_col_types = FALSE)
  expected_cols <- c(
    "directorate", "department", "branch", "section",
    "code_group", "code", "cause_code_group", "cause_code",
    "wind_speed_10m", "wind_direction_10m", "h3_level8_index", "rounded_creation_time"
  )
  expect_true(all(expected_cols %in% names(df)))
})
