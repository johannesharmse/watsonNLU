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
watson_NLU <-  function(text = NULL, url = NULL, username = NULL, password=NULL, features = list(), version="?version=2018-03-16"){

  ### INIT ###

  # api URL
  # this is the base of the API call
  # the variables for the API call will get appended to this
  url_NLU <- "https://gateway.watsonplatform.net/natural-language-understanding/api"

  ### ERROR CHECKING ###

  # make sure user has only specified text OR URL argument
  # API call needs text to analyze
  # this can either be in the form of
  # a text string or url
  # both of these are input arguments
  # but only one argument should be specified
  # this condition checks that AT LEAST one of the arguments have been specified
  if (is.null(text) && is.null(url)){
    stop("Please specify either a text or URL, but not both.")
  }

  ### ENCODING ###

  # format input text/URL
  # in the case of text input
  # the text needs to be encoded
  # in the case of url input
  # no encoding is necessary
  if (is.character(text)){
    text <- URLencode(text)
  }else if(is.character(url)){
    # redundant
    url <- url
  }else{
    # if neither text or url input is a character string
    # return error message
    stop("Please specify text or URL as a string")
  }


  ### MORE ERROR CHECKING ###

  # error checking
  # check that username and password have been specified as character arguments
  # first checks that both username and password have values
  # secondly checks that those values are specified as character strings
  # error message if these checks fail
  if (is.null(username) ||
      is.null(password) ||
      !is.character(username) ||
      !is.character(password)){
    stop("Please specify a valid username and password combination as string arguments.")
  }

  ### STANDARDISE INPUT ###

  # assign either text or
  # url as a general
  # variable
  # the pre-text is necessary
  # for the API call
  if (!is.null(text)){
    input <- paste0("&text=", text)
  }else{
    input <- paste0("&url=", url)
  }

  ### MORE ERROR CHECKING ###

  # check that user has specified desired features as list object
  # this will become unnecessary
  # if we split the
  # functions
  if (!is.list(features)){
    stop("Please specify features as a list object.")
  }

  # concatenate requested features
  # the features AKA the names of the main
  # feature input argument list
  # include pre-text and seperate features
  # with a comma
  # as specified by the API call requirements
  features_string <- paste0("&features=", paste0(names(features), collapse = ","))

  # concatenate feature attributes
  # each feature can have a set of attributes
  # for the API call
  # these need to be specified as
  # feature.attribute=attribute_value
  # the features are the feature input list names
  # the attributes are the names within the vector or list
  # that is specified for each feature name
  # the attribute_value is generally "true", but
  # can be something like a query limit - eg. keywords.limit=5
  # the code below simply concatenates all the attributes and their values
  # per feature
  # the feature attribute string (as below) needs
  # to be specified seperately from the
  # list of features (as above)
  # the attributes are collapsed with an "&" character as specified by the API documentation
  features_attr <- c()

  # loop through features
  for (feat in 1:length(features)){
    # check if feature has any attributes specified
    if (length(feat) > 0){
      # loop through attributes of a feature
      for (attr in 1:length(feat)){
        # append to feature attribute list
        features_attr[length(features_attr) + 1] <-
          paste0("&", names(features)[feat], ".", names(features[[feat]])[attr], "=", tolower(as.character(features[[feat]][attr])))
      }
    }
  }

  # collapse the feature attribute list as a single string for the API call
  features_attr <- paste0(features_attr, collapse = "")

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
    features_attr),
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
  response[!(names(response) %in% names(features))] <- NULL


  ### OUTPUT ###

  # return clean output
  return(response)

}
