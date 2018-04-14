# auth_NLU tests
#
# Testing includes:
#

library(watsonNLU)
context("Keyword Relevance")

# username <- readRDS("username.rds")
# password <- readRDS("password.rds")

credentials <- readRDS("credentials.rds")
username <- credentials$username
password <- credentials$password

test_that("Check if authorization works.", {
  expect_equal(auth_NLU(username = username, password = password), "Valid credentials provided.")
})
