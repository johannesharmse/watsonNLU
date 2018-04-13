#' Watson Natural Language Understanding: Text Categorizer
#'
#' The \strong{text_categories} function takes in a URL or text input, and returns a dataframe that contains the likelihood that the contents of the URL or text belong to a particular category.
#'
#' See the \href{https://github.com/johannesharmse/watsonNLU/blob/master/README.md}{text_categories} documentation for more useage cases.
#'
#'
#' @param text text string to be categorized.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#' @param url url to text to be categorized.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#'
#' @return A dataframe that contains the likelihood that the contents of the URL or text belong to a particular category.
#'
#' @examples
#' # Find the likelihood that the given input belongs to a particular category: from text
#' text_categories(text = 'This is a great API wrapper')
#'
#' # Find the likelihood that the given input belongs to a particular category: from URL
#' text_categories(url = 'http://santiago.begueria.es/2010/10/generating-spatially-correlated-random-fields-with-r/')
#'
#' @import httr
#'
#' @export

text_categories <-  function(username = NULL, password = NULL, input = NULL, input_type = NULL, limit = NULL, version="?version=2018-03-16"){

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

  if (!is.null(response$categories)){
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
