# tests/integration_test_sr_join.R
# CoCT x JPAL challenge
# test the join operation

source("scripts/requirements.R")

suppressPackageStartupMessages({
library(testthat)
library(readr)
library
})

test_that("End-to-end pipeline produces expected joined file", {

  if (file_exists("data/processed/sr_with_hex.csv.gz")) {
    file_delete("data/processed/sr_with_hex.csv.gz")
  }
  
  result <- system("Rscript scripts/join_sr_to_hex.R", intern = TRUE)
  
  expect_true(file_exists("data/processed/sr_with_hex.csv.gz"))
  
  result_df <- read_csv("data/processed/sr_with_hex.csv.gz", show_col_types = FALSE)
  reference_df <- read_csv("data/raw/sr_hex.csv.gz", show_col_types = FALSE)
  
  reference_df <- reference_df %>% rename(index = h3_level8_index)
  
  expect_equal(nrow(result_df), nrow(reference_df))
  expect_true(all(result_df$index %in% reference_df$index))
  setdiff(unique(result_df$index), unique(reference_df$index))
})
