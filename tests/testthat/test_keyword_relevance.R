# auth_NLU tests
#
# Testing includes:
#
# - correct error handling
# - correct function output for valid function input

library(watsonNLU)
context("Keyword Relevance")

credentials <- readRDS("credentials.rds")
username <- credentials$username
password <- credentials$password

# authenticate user
auth_NLU(username = username, password = password)

test_that("Check error handling for missing input", {

  expect_error(
    keyword_relevance(input = NULL, input_type='url', limit = 1),
               "Please specify an input to analyze.")
})

test_that("Check error handling for non-character input", {
  expect_error(keyword_relevance(input = 12345, input_type='url', limit = 1),
               "Please specify input text or URL as a character string")
})

# can't clear cache

# test_that("Check error handling for if valid credential authorization works.", {
#   cache <- ".httr-oauth"
#   if (file.exists(cache)) file.remove(cache)
#   # revoke_all()
#   set_config(authenticate(username, "XXXXX"), override = TRUE)
#   with_config(authenticate(username, "XXXXX"), expect_equal(auth_NLU(username = username, password = "XXXXX"),
#                "Invalid credentials provided."), override = TRUE)
#   reset_config()
# })

test_that("Check if valid credential authorization works.", {
  expect_equal(auth_NLU(username = username, password = password),
               "Valid credentials provided.")
})
