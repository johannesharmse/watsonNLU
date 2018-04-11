#' Watson Natural Language Understanding API Wrapper
#'
#' See the \href{https://www.ibm.com/watson/developercloud/natural-language-understanding/api/v1/#get-analyze}{IBM Watson NLU API} documentation for more information.
#'
#'
#' @param text text string to be analyzed.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#' @param url url to text to be analyzed.
#'    Either \code{text} or \code{url} argument has to be specified,
#'    but not both.
#' @param username Authenitcation IBM Watson Natural-Language-Understanding-3j \strong{username}
#' @param password Authenitcation IBM Watson Natural-Language-Understanding-3j \strong{password}
#' @param features Text analysis features, such as \emph{keywords}, specified as
#'    list item names. Feature attributes, such as \emph{emotions} or \emph{sentiment},
#'    specified as list values.
#' @param version The release date of the API version to use.
#' @return A nested list object with content of API response.
#'
#' @import httr
#'
#' @export
keyword_relevance <-  function(text_source = NULL, source_type = NULL, limit = NULL, version="?version=2018-03-16"){

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
    text_source,
    features_string,
    limit),
    # authenticate(username,password),
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
  response[!(names(response) %in% names(features))] <- NULL




  ### OUTPUT ###

  # return clean output
  return(response)

}
