library(testthat)
library(watsonNLU)

test_check("watsonNLU")

check_api <- function() {
  if (not_working()) {
    skip("API not available")
  }
}

test_that("foo api returns bar when given baz", {
  check_api()
  ...
})