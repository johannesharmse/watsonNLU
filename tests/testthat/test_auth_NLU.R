# auth_NLU tests
#
# Testing includes:
#

library(watsonNLU)
context("Keyword Relevance")

credentials <- readRDS("credentials.rds")

test_that("Check if authorization works.", {
  expect_equal(auth_NLU(username = credentials$username, password = credentials$password), "Valid credentials provided.")
})
