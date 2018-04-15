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

text_input <- readLines(con = "test.txt")
url_input <- "http://www.nytimes.com/guides/well/how-to-be-happy"

# authenticate user
auth_NLU(username = username, password = password)

response_success <- keyword_relevance(input = text_input, input_type='text', limit = 3)
response_success_url <- keyword_relevance(input = url_input, input_type='url', limit = 5)

test_that("Check error handling for missing input", {

  expect_error(
    keyword_relevance(input = NULL, input_type='url', limit = 1),
               "Please specify an input to analyze.")
})

test_that("Check error handling for non-character input", {
  expect_error(keyword_relevance(input = 12345, input_type='url', limit = 1),
               "Please specify input text or URL as a character string")
})

test_that("Check error handling for unaccepted input types", {
  expect_error(keyword_relevance(input = text_input, input_type='html', limit = 1),
               "Input type should be either 'url' or 'text'.")
})

test_that("Check error handling for evidently short input.", {
  expect_error(keyword_relevance(input = "abc", input_type='text', limit = 1),
               "Please make sure you have a valid internet connection and provided a valid input. Check the response log above for further details.")
})

test_that("Check that number of results is controlled by limit argument.", {
  expect_equal(nrow(response_success),
               3)
})

test_that("Check correct number of columns.", {
  expect_equal(ncol(response_success),
               2)
})

test_that("Check that all relevance scores are between 0 and 1.", {
  expect_equal(nrow(response_success[response_success$relevance >= 0 &
                                  response_success$relevance <= 1, ]),
               nrow(response_success))
})

test_that("Check for url input successful response", {
  expect_equal(nrow(response_success_url),
               5)
})
