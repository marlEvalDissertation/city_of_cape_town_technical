# tests/test_hex_extraction.R
# CoCT JPAL challenge

# Tests for extracted geojson

suppressPackageStartupMessages({
library(testthat)
library(sf)
library(jsonlite)
})

test_that("Extracted file exists and loads", {
  expect_true(file.exists("data/processed/city-hex-polygons-8(new).geojson"))
  geo <- st_read("data/processed/city-hex-polygons-8(new).geojson", quiet = TRUE)
  expect_s3_class(geo, "sf")
})

test_that("Only resolution 8 polygons present", {
  geo <- st_read("data/processed/city-hex-polygons-8(new).geojson", quiet = TRUE)
  res_col <- grep("res|level", names(geo), value = TRUE)
  expect_equal(length(res_col), 1)
  expect_true(all(geo[[res_col]] == 8))
})

