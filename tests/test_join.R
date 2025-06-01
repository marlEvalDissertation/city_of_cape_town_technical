# tests/test-join_utils.R
# CoCT x JPAL challenge
# test the join operation

source("scripts/requirements.R")
suppressPackageStartupMessages({
library(testthat)
library(dplyr)
library(sf)
})

test_that("Missing lat/lon rows are handled correctly", {
  df <- tibble(
    id = 1:3,
    latitude = c(-33.9, NA, -33.8),
    longitude = c(18.5, 18.6, NA)
  )
  
  missing <- df %>%
    filter(is.na(latitude) | is.na(longitude)) %>%
    mutate(index = "0")
  
  expect_equal(nrow(missing), 2)
  expect_true(all(missing$index == "0"))
})

test_that("Spatial join adds index column", {
  # Create a small test hexagon polygon
  hex <- st_sf(index = "abc123", geometry = st_sfc(st_polygon(list(rbind(
    c(18.4, -33.9), c(18.6, -33.9), c(18.6, -33.7),
    c(18.4, -33.7), c(18.4, -33.9)
  ))), crs = 4326))
  
  sr <- tibble(latitude = -33.8, longitude = 18.5)
  sr_sf <- st_as_sf(sr, coords = c("longitude", "latitude"), crs = 4326)
  
  joined <- st_join(sr_sf, hex, left = TRUE)
  
  expect_true("index" %in% colnames(joined))
  expect_equal(joined$index, "abc123")
})
