# tests/test_unit_bellville.R
# CoCT x JPAL Data science challenge
suppressPackageStartupMessages({
library(testthat)
library(readr)
library(dplyr)
})
test_that("Centroid CSV contains expected structure", {
  path <- "data/processed/bellville_centroid.csv"
  expect_true(file.exists(path))
  
  df <- read_csv(path, show_col_types = FALSE)
  expect_true(all(c("centroid_latitude", "centroid_longitude") %in% colnames(df)))
  expect_type(df$centroid_latitude, "double")
  expect_type(df$centroid_longitude, "double")
})

test_that("Subsample output exists and contains expected structure", {
  path <- "data/processed/sr_bellville_south_subsample.csv.gz"
  expect_true(file.exists(path))
  
  df <- read_csv(path, show_col_types = FALSE)
  expect_true(all(c("latitude", "longitude") %in% colnames(df)))
})
