# tests/testthat/test_integration_bellville.R
# CoCT x JPAL data science challenge

suppressPackageStartupMessages({
library(testthat)
library(readr)
library(dplyr)
library(geosphere)
})

test_that("All subsample rows are within 1.85 km of computed centroid", {
  centroid_path <- "data/processed/bellville_centroid.csv"
  subsample_path <- "data/processed/sr_bellville_south_subsample.csv.gz"
  
  centroid <- read_csv(centroid_path, show_col_types = FALSE)
  subsample <- read_csv(subsample_path, show_col_types = FALSE)
  
  coord_centroid <- c(centroid$centroid_longitude[1], centroid$centroid_latitude[1])
  distances <- distHaversine(subsample[, c("longitude", "latitude")], coord_centroid) / 1000
  
  expect_true(all(distances <= 1.85))
})
