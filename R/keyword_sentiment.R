#' Watson Natural Language Understanding: Sentiment Analysis of Input Keywords
#'
#' See the \href{https://github.com/johannesharmse/watsonNLU/blob/master/README.md}{sign-up} documentation for step by step instructions to secure your own username and password to enable you to authenticate the Watson NLU API. The \strong{keyword_sentiment} function takes a text or URL input, along with the input type. The function then returns a dataframe containing the sentiments of the keywords extracted from the input, and the likelihood that the input is described by that sentiment. See the \href{https://github.com/johannesharmse/watsonNLU/blob/master/README.md}{keyword_sentiment} documentation for more usage cases.
#'
#'
#' @param input Either a text string input or website URL.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#' @param input_type Specify what type of input was entered.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#' @param version The release date of the API version to use. Default value is \code{version="?version=2018-03-16"}
#' @return Dataframe containing the sentiments of the keywords extracted from the input, and the likelihood that the input is described by that sentiment.
#'
#' @examples
#'
#' credentials <- readRDS("../tests/testthat/credentials.rds")
#' username <- credentials$username
#' password <- credentials$password
#'
#' # Authenticate using Watson NLU API Credentials
#' auth_NLU(username, password)
#'
#' # Find the keywords and related emotions in the given text input.
#' keyword_sentiment(input = 'This is a great API wrapper', input_type='text')
#'
#' # Find the keywords and related emotions in the given URL input.
#' keyword_sentiment(input = 'http://www.nytimes.com/guides/well/how-to-be-happy', input_type='url')
#'
#' @seealso \code{\link[watsonNLU]{text_categories}}, \code{\\link[watsonNLU]{keyword_relevance}}, \code{\\link[watsonNLU]{keyword_emotions}}, \code{\\link[watsonNLU]{auth_NLU}}
#'
#' @import httr
#'
#' @export

keyword_sentiment <-  function(input = NULL,
                        input_type = NULL,
                        version="?version=2018-03-16"){

  # specfying accepted input types
  accepted_input_types <- c('text', 'url')

  url_NLU <- "https://gateway.watsonplatform.net/natural-language-understanding/api"

  # We will be extracting emotions of keyword features in our API
  feature_string <- paste0("&features=", "keywords")
  sentiment_string <- paste0("&keywords.sentiment=true")

  # CHECK if input_type is specified or not. By default use URL.
  if (is.null(input_type)){
    message("Input type not specified. Please make sure to specify `url` in `input_type` if input is URL. Assuming text input.")
    input_type <- 'text'
  }

  # CHECK if Input-type is character.
  if (!is.character(input_type)){
    stop("Input type needs to be specified as a character string('url' or 'text').")
  }else{
    input_type <- tolower(input_type)
  }


  # CHECK if input is text or url and modify input string.
  if (input_type == 'text'){
    input <- URLencode(input)
    input_string <- paste0("&text=", input)
  }else if(input_type == 'url'){
    input_string <- paste0("&url=", input)
  }

  # CHECK if input type is within acceptable values.
  if (!input_type %in% accepted_input_types){
    stop("Input type should be either 'url' or 'text'.")
  }

  # Building the GET query.
  response_json <- GET(
    url = paste0(
      url_NLU,
      "/v1/analyze",
      version,
      input_string,
      feature_string,
      sentiment_string
    ),
    # authenticate(username, password),
    add_headers("Content=Type"="application/json")
  )

  ###### CHECK RESPONSE ########

  if (status_code(response_json) != 200){

    # Include error message returned from the API call.
    message(response_json)
    stop("Please make sure your username and password combination is correct
         and that you have a valid internet connection or check the response log above.")
  }

  # Save response as a list
  response_list <- content(response_json)

  # Check if response is NULL.
  if (!is.null(response_list$keywords)){
    response_keywords <- response_list$keywords
  }else{
    stop("No results available")
  }

  # Store keywords and emotion scores in vectors.
  keywords <- sapply(1:length(response_keywords),
                     function(x) response_keywords[[x]]$text)
  relevance <- sapply(1:length(response_keywords),
                      function(x) response_keywords[[x]]$relevance)
  sentiment_score <- sapply(1:length(response_keywords),
                        function(x) response_keywords[[x]]$sentiment$score)
  label <- sapply(1:length(response_keywords),
                    function(x) response_keywords[[x]]$sentiment$label)

  # Combine vectors into one data frame.
  response_df <- data.frame(
    'keyword' = keywords,
    'key_relevance' = relevance,
    'score' = sentiment_score,
    'label' = label
  )

  # Return a DataFrame of sentiment score and labels of the keywords found in the text/url.
  return(response_df)
  }
