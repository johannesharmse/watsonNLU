#' Watson Natural Language Understanding: Text Categorizer
#'
#' See the \href{https://github.com/johannesharmse/watsonNLU/blob/master/README.md}{sign-up} documentation for step by step instructions to secure your own username and password to enable you to use the Watson NLU API. The \strong{text_categories} function takes a text or URL input along with the input type. The function then returns a dataframe that contains the likelihood that the contents of the URL or text belong to a particular category. See the \href{https://github.com/johannesharmse/watsonNLU/blob/master/README.md}{text_categories} documentation for more useage cases.
#'
#' @param input Either a text string input or website URL.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#' @param input_type Specify what type of input was entered.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#' @param limit The number of categories to return.
#' @param version The release date of the API version to use. Default value is \code{version="?version=2018-03-16"}
#'
#' @return A dataframe that contains the likelihood that the contents of the URL or text belong to a particular category.
#'
#' @examples
#' library(watsonNLU)
#'
#' # Authenticate using Watson NLU API Credentials
#' auth_NLU(username="XXXX", password="XXXX")
#'
#' # Find 5 categories that describe the text input.
#' text_categories(input = 'This is a great API wrapper', input_type='text', limit = 5)
#'
#' # Find 5 categories that describe the URL input.
#' text_categories(input = 'http://www.nytimes.com/guides/well/how-to-be-happy', input_type='url', limit = 5)
#'
#' @seealso \code{\link[watsonNLU]{keyword_sentiment}}, \code{\\link[watsonNLU]{keyword_relevance}}, \code{\\link[watsonNLU]{keyword_emotions}}, \code{\\link[watsonNLU]{auth_NLU}}
#'
#' @import httr
#'
#' @export

text_categories <-  function(input = NULL, input_type = NULL, limit = NULL, version="?version=2018-03-16"){

  # initialization

  accepted_input_types <- c('text', 'url')

  # api URL
  # this is the base of the API call
  # the variables for the API call will get appended to this
  url_NLU <- "https://gateway.watsonplatform.net/natural-language-understanding/api"

  # function feature
  # no attribute needs to be specified
  feauture <- "categories"
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
    # authenticate(username,password),
    add_headers("Content-Type"="application/json"))

  ### ERROR CHECKING ###

  # check for successful response
  # successful response has a code of 200
  # all other codes are unsuccessful responses


  status <- status_code(response)

  if (status != 200){

    message(response)

    if(status == 401){
      stop("Invalid or expired credentials provided. Provide credentials using watsonNLU::auth_NLU")
    }
    # include message to give user more insight into why the call was unsuccessful
    # can be due to query limit, internet connection, authentication fail, etc.

    stop("Please make sure you have a valid internet connection and provided a valid input. Check the response log above for further details.")
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

  if (!is.null(response$categories) &&
      length(response$categories) > 0){
    response <- response$categories
  }else{
    stop("No results available")
  }
  ### OUTPUT ###

  label <- sapply(1:length(response), function(x) response[[x]]$label)

  label_levels <- lapply(1:length(label), function(x) strsplit(substr(label[x], 2, nchar(label[x])), split = "/", fixed = T)[[1]])

  max_level <- max(sapply(label_levels, function(x) length(x)))

  score <- sapply(1:length(response), function(x) response[[x]]$score)

  response_df <- data.frame('score' = score)

  for (i in 1:length(label_levels)){
    for (j in 1:length(label_levels[[i]])){
      response_df[i , paste0('category_level_', j)] <- label_levels[[i]][j]
    }
  }

  # return clean output
  return(response_df)

}
