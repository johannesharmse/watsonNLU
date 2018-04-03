#' Watson Natural Language Understanding [API](https://www.ibm.com/watson/developercloud/natural-language-understanding/api/v1/#get-analyze) Wrapper function
#'
#'
#' @param text text string to be analyzed.
#'    Either `text` or `url` argument has to be specified,
#'    but not both.
#' @param url url to text to be analyzed.
#'    Either `text` or `url` argument has to be specified,
#'    but not both.
#' @param username Authenitcation IBM Watson Natural-Language-Understanding-3j username
#' @param password Authenitcation IBM Watson Natural-Language-Understanding-3j password
#' @param features Text analysis features, such as *keywords*, specified as
#'    list item names. Feature attributes, such as *emotions* or *sentiment*,
#'    specified as list values.
#' @param version The release date of the API version to use.
#' @return A nested list object with content of API response.
#'
#' @import httr
#'
#' @export
watson_NLU <-  function(text = NULL, url = NULL, username = NULL, password=NULL, features = list(), version="?version=2018-03-16"){

  # api URL
  url_NLU <- "https://gateway.watsonplatform.net/natural-language-understanding/api"

  # make sure user has only specified text OR URL argument
  if (is.null(text) && is.null(url)){
    stop("Please specify either a text or URL, but not both.")
  }

  # format input text/URL
  if (is.character(text)){
    text <- URLencode(text)
  }else if(is.character(url)){
    # redundant
    url <- url
  }else{
    stop("Please specify text or URL as a string")
  }

  # check that username and password have been specified as character arguments
  if (is.null(username) ||
      is.null(password) ||
      !is.character(username) ||
      !is.character(password)){
    stop("Please specify a valid username and password combination as string arguments.")
  }

  # generalize input argument (text or URL)
  if (!is.null(text)){
    input <- paste0("&text=", text)
  }else{
    input <- paste0("&url=", url)
  }

  # check that user has specified desired features as list object
  if (!is.list(features)){
    stop("Please specify features as a list object.")
  }

  # concatenate requested features
  features_string <- paste0("&features=", paste0(names(features), collapse = ","))

  # concatenate feature attributes
  features_attr <- c()

  for (feat in 1:length(features)){
    if (length(feat) > 0){
      for (attr in 1:length(feat)){
        features_attr[length(features_attr) + 1] <-
          paste0("&", names(features)[feat], ".", names(features[[feat]])[attr], "=", tolower(as.character(features[[feat]][attr])))
      }
    }
  }

  features_attr <- paste0(features_attr, collapse = "")

  # GET
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

  # check for successful response
  if (status_code(response) != 200){
    message(response)
    stop("Please make sure your username and password combination is correct
         and that you have a valid internet connection or check the response log above.")
  }

  # get response structured content
  response <- content(response)

  # remove unwanted output
  response[!(names(response) %in% names(features))] <- NULL

  return(response)

}
