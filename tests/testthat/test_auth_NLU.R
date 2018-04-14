# auth_NLU tests
#
# Testing includes:
#

library(watsonNLU)
context("Keyword Relevance")

username <- readRDS("username.rds")
password <- readRDS("password.rds")

test_that("Check if authorization works.", {
  expect_equal(auth_NLU(username = username, password = password), "Valid credentials provided.")
})
