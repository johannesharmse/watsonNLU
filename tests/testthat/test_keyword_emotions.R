# auth_NLU tests
#
# Testing includes:
#
# - correct error handling
# - correct function output for valid function input

library(watsonNLU)
context("Keyword Emotions")

credentials <- readRDS("credentials.rds")
username <- credentials$username
password <- credentials$password

# text_input <- readLines(con = "test.txt")
text_input <- c("In the rugged Colorado Desert of California, there lies buried a treasure ship sailed there hundreds of years
                ago by either Viking or Spanish explorers. Some say this is legend; others insist it is fact.
                A few have even claimed to have seen the ship, its wooden remains poking through the sand like the skeleton of a prehistoric beast.
                Among those who say they’ve come close to the ship is small-town librarian Myrtle Botts. In 1933, she was hiking with her husband
                in the Anza-Borrego Desert, not far from the border with Mexico. It was early March, so the desert would have been in bloom,
                its washed-out yellows and grays beaten back by the riotous invasion of wildflowers. Those wildflowers were what brought the Bottses to the desert,
                and they ended up near a tiny settlement called Agua Caliente. Surrounding place names reflected the strangeness and severity of the land:
                Moonlight Canyon, Hellhole Canyon, Indian Gorge. Try Newsweek for only $1.25 per week To enter the desert is to succumb to the unknowable.
                One morning, a prospector appeared in the couple’s camp with news far more astonishing than a new species of desert flora: He’d found a ship
                lodged in the rocky face of Canebrake Canyon. The vessel was made of wood, and there was a serpentine figure carved into its prow.
                There were also impressions on its flanks where shields had been attached—all the hallmarks of a Viking craft.")

url_input <- "http://www.nytimes.com/guides/well/how-to-be-happy"

# authenticate user
auth_NLU(username = username, password = password)

response_success <- keyword_emotions(input = text_input, input_type='text')
response_success_url <- keyword_emotions(input = url_input, input_type='url')

test_that("Check error handling for missing input", {
  
  expect_error(
    keyword_relevance(input = NULL, input_type='url'),
    "Please specify an input to analyze.")
})

test_that("Check error handling for non-character input", {
  expect_error(keyword_relevance(input = 12345, input_type='url'),
               "Please specify input text or URL as a character string")
})

test_that("Check error handling for unaccepted input types", {
  expect_error(keyword_relevance(input = text_input, input_type='html'),
               "Input type should be either 'url' or 'text'.")
})

test_that("Check error handling for evidently short input.", {
  expect_error(keyword_relevance(input = "abc", input_type='text'),
               "Please make sure you have a valid internet connection and provided a valid input. Check the response log above for further details.")
})

test_that("Check that number of results is controlled by limit argument.", {
  expect_equal(nrow(response_success),
               45)
})

test_that("Check correct number of columns.", {
  expect_equal(ncol(response_success),
               7)
})

test_that("Check that all emotion scores are between 0 and 1.", {
  expect_equal(nrow(response_success[response_success$sadness >= 0 &
                                       response_success$sadness <= 1, ]),
               nrow(response_success))
})

test_that("Check that all emotion scores are between 0 and 1.", {
  expect_equal(nrow(response_success[response_success$joy >= 0 &
                                       response_success$joy <= 1, ]),
               nrow(response_success))
})

test_that("Check that all emotion scores are between 0 and 1.", {
  expect_equal(nrow(response_success[response_success$fear >= 0 &
                                       response_success$fear <= 1, ]),
               nrow(response_success))
})

test_that("Check that all emotion scores are between 0 and 1.", {
  expect_equal(nrow(response_success[response_success$disgust >= 0 &
                                       response_success$disgust <= 1, ]),
               nrow(response_success))
})

test_that("Check that all emotion scores are between 0 and 1.", {
  expect_equal(nrow(response_success[response_success$anger >= 0 &
                                       response_success$anger <= 1, ]),
               nrow(response_success))
})

test_that("Check for url input successful response", {
  expect_equal(nrow(response_success_url),
               50)
})
