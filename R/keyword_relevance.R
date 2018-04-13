#' Watson Natural Language Understanding: Relevance of Keywords
#'
#' See the \href{https://github.com/johannesharmse/watsonNLU/blob/master/README.md}{sign-up} documentation for step by step instructions to secure your own username and password to enable you to use the Watson NLU API. The \strong{keyword_relevance} function takes in a username and password as input to authenticate the users computer to use the Watson Natural Language Understanding API. The user then enters the text input or URL of their choice, along with the input type. The function then returns a dataframe that contains keywords and their likelihood of being a keyword, from the given input. See the \href{https://github.com/johannesharmse/watsonNLU/blob/master/README.md}{keyword_relevance} documentation for more useage cases.
#'
#' @param username Authenitcation IBM Watson Natural-Language-Understanding-3j \strong{username}
#' @param password Authenitcation IBM Watson Natural-Language-Understanding-3j \strong{password}
#' @param input Either a text string input or website URL.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#' @param input_type Specify what type of input was entered.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#' @param limit The number of keywords to return.
#' @param version The release date of the API version to use. Default value is \code{version="?version=2018-03-16"}
#'
#' @return A dataframe containing a list of keywords and their corresponding likelihoods for the given input.
#'
#' @examples
#' # Find keywords and their corresponding likelihoods for a text input.
#' keyword_relevance(username = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX', password= 'XXXXXXXXXXXX', input = 'This is a great API wrapper', input_type='text', limit = 10)
#'
#' # Find keywords and their corresponding likelihoods for a URL input.
#' keyword_relevance(username = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX', password= 'XXXXXXXXXXXX', input = 'http://santiago.begueria.es/2010/10/generating-spatially-correlated-random-fields-with-r/', input_type='url', limit = 10)
#'
#' @import httr
#'
#' @export

keyword_relevance <-  function(username = NULL, password = NULL, input = NULL, input_type = NULL, limit = NULL, version="?version=2018-03-16"){

  # initialization

  accepted_input_types <- c('text', 'url')

  # api URL
  # this is the base of the API call
  # the variables for the API call will get appended to this
  url_NLU <- "https://gateway.watsonplatform.net/natural-language-understanding/api"

  # function feature
  # no attribute needs to be specified
  feauture <- "keywords"
  features_string <- paste0("&features=", feauture)


  # input argument error checking

  if (is.null(input)){
    stop("Please specify an input to analyze.")
  }else if(!is.character(input)){
    stop("Please specify input text or URL as a character string")
  }

  if (is.null(input_type)){
    message("Input type not specified. Assuming text input.")
    input_type <- 'text'
  }

  if (!is.character(input_type)){
    stop("Input type needs to be specified as a character string('url' or 'text').")
  }else{
    input_type <- tolower(input_type)
  }


  if (!input_type %in% accepted_input_types){
    stop("Input type should be either 'url' or 'text'.")
  }

  if(is.null(limit)){
    message("No limit specified. Using default API call limit.")
  }else if(!is.numeric(limit) ||
           length(limit) > 1){
    message("Limit needs to be specified as a numeric integer.")
  }else{
    limit <- paste0("&", feauture, ".limit=", limit)
  }


  ### ENCODING ###

  # format input text/URL
  # in the case of text input
  # the text needs to be encoded
  # in the case of url input
  # no encoding is necessary
  if (input_type == 'text'){
    input <- URLencode(input)
  }

  ### STANDARDISE INPUT ###

  # assign either text or
  # url as a general
  # variable
  # the pre-text is necessary
  # for the API call
  if (input_type == 'text'){
    input <- paste0("&text=", input)
  }else if(input_type == 'url'){
    input <- paste0("&url=", input)
  }



  ### API CALL ###

  # GET
  # the POST call doesn't seem to do anything different
  # this is the actual API call
  # version - version of API to be used
  # input - text or url string
  # feature_string - string containing all specified features
  # feature_attr - string containing all specified attributes for specific features
  # authenticate - used to verify credentials
  # add_header - fails if not specified
  response <- GET(url=paste0(
    url_NLU,
    "/v1/analyze",
    version,
    input,
    features_string,
    limit),
    authenticate(username,password),
    add_headers("Content-Type"="application/json")
    )

  ### ERROR CHECKING ###

  # check for successful response
  # successful response has a code of 200
  # all other codes are unsuccessful responses
  if (status_code(response) != 200){
    # include message to give user more insight into why the call was unsuccessful
    # can be due to query limit, internet connection, authentication fail, etc.
    message(response)
    stop("Please make sure your username and password combination is correct
         and that you have a valid internet connection or check the response log above.")
  }

  ### API RESPONSE CONTENT ###

  # get response structured content
  # this is the list that gets returned
  response <- content(response)

  ### CLEAN OUTPUT ###

  # remove unwanted output
  # there are generally unwanted list items
  # that the user isn't interested in
  # this needs to be removed
  # this can include things like input text metadata

  if (!is.null(response$keywords)){
    response <- response$keywords
  }else{
    stop("No results available")
  }
  ### OUTPUT ###

  keywords <- sapply(1:length(response), function(x) response[[x]]$text)
  relevance <- sapply(1:length(response), function(x) response[[x]]$relevance)

  response_df <- data.frame('keyword' = keywords, 'relevance' = relevance)

  # return clean output
  return(response_df)

}
