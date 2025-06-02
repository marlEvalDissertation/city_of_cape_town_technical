# tests/integration_test_sr_join.R
# CoCT x JPAL challenge
# test the join operation

source("scripts/requirements.R")

suppressPackageStartupMessages({
  library(testthat)
  library(readr)
  library(dplyr)
  library(h3jsr)
  library(fs)
})

test_that("End-to-end pipeline produces expected joined file", {
  
  output_path <- "data/processed/sr_with_hex.csv.gz"
  reference_path <- "data/raw/sr_hex.csv.gz"
  
  # Clean up old output if it exists
  if (file_exists(output_path)) {
    file_delete(output_path)
  }
  
  # Run the join script
  result <- system("Rscript scripts/join_sr_to_hex.R", intern = TRUE)
  
  # Check that output file was created
  expect_true(file_exists(output_path))
  
  # Load and compare to reference
  result_df <- read_csv(output_path, show_col_types = FALSE)
  reference_df <- read_csv(reference_path, show_col_types = FALSE)
  
  # Align column names if necessary
  if ("h3_level8_index" %in% names(result_df)) {
    result_df <- result_df %>% rename(index = h3_level8_index)
  }
  if ("h3_level8_index" %in% names(reference_df)) {
    reference_df <- reference_df %>% rename(index = h3_level8_index)
  }
  
  # Basic sanity checks
  expect_equal(nrow(result_df), nrow(reference_df))
  expect_true(all(sort(result_df$index) %in% sort(reference_df$index)))
})
