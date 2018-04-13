#' Watson Natural Language Understanding: Relevance of Keywords
#'
#' The \strong{keyword_relevance} function takes in a URL or text input, and returns a dataframe that contains keywords and their likelihood of being a keyword, from the given input.
#'
#' See the \href{https://github.com/johannesharmse/watsonNLU/blob/master/README.md}{keyword_relevance} documentation for more useage cases.
#'
#'
#' @param text text string to be categorized.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#' @param url url to text to be categorized.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#'
#' @return A dataframe that contains keywords and their likelihood of being a keyword, for the given input.
#'
#' @examples
#' # Find the likelihood that a word is a keyword from the given input: text input
#' keyword_relevance(text = 'This is a great API wrapper')
#'
#' # Find the likelihood that a word is a keyword from the given input: URL input
#' keyword_relevance(url = 'http://santiago.begueria.es/2010/10/generating-spatially-correlated-random-fields-with-r/')
#'
#' @import httr
#'
#' @export

keyword_relevance <-  function(username = NULL, password = NULL, text_source = NULL, source_type = NULL, limit = NULL, version="?version=2018-03-16"){

  # initialization

  accepted_source_types <- c('text', 'url')

  # api URL
  # this is the base of the API call
  # the variables for the API call will get appended to this
  url_NLU <- "https://gateway.watsonplatform.net/natural-language-understanding/api"

  # function feature
  # no attribute needs to be specified
  feauture <- "keywords"
  features_string <- paste0("&features=", feauture)


  # input argument error checking

  if (is.null(text_source)){
    stop("Please specify a text source to analyze.")
  }else if(!is.character(text_source)){
    stop("Please specify text or URL as a character string")
  }

  if (is.null(source_type)){
    message("Source type not specified. Assuming text input.")
    source_type <- 'text'
  }

  if (!is.character(source_type)){
    stop("Source type needs to be specified as a character string('url' or 'text').")
  }else{
    source_type <- tolower(source_type)
  }


  if (!source_type %in% accepted_source_types){
    stop("Source type should be either 'url' or 'text'.")
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
  if (source_type == 'text'){
    text_source <- URLencode(text_source)
  }

  ### STANDARDISE INPUT ###

  # assign either text or
  # url as a general
  # variable
  # the pre-text is necessary
  # for the API call
  if (source_type == 'text'){
    input <- paste0("&text=", text_source)
  }else if(source_type == 'url'){
    input <- paste0("&url=", text_source)
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
