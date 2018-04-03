watson_NLU <-  function(text = NULL, url = NULL, username = NULL, password=NULL, features = list(), version="?version=2018-03-16"){

  # api URL
  url_NLU <- "https://gateway.watsonplatform.net/natural-language-understanding/api"

  # error handling
  if (is.null(text) && is.null(url)){
    stop("Please specify either a text or URL, but not both.")
  }

  if (is.character(text)){
    text <- URLencode(text)
  }else if(is.character(url)){
    url <- url
  }else{
    stop("Please specify text or URL as a string")
  }

  if (is.null(username) ||
      is.null(password) ||
      !is.character(username) ||
      !is.character(password)){
    stop("Please specify a valid username and password combination as string arguments.")
  }

  # define input type
  if (!is.null(text)){
    input <- paste0("&text=", text)
  }else{
    input <- paste0("&url=", url)
  }

  # error handling
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
        features_attr[length(features_attr) + 1] <- paste0("&", names(features)[feat], ".", names(features[[feat]])[attr], "=", tolower(as.character(features[[feat]][attr])))
      }
    }
  }

  features_attr <- paste0(features_attr, collapse = "")

  # POST
  response <- POST(url=paste0(
    url_NLU,
    "/v1/analyze",
    version,
    input,
    features_string,
    features_attr),
    authenticate(username,password),
    add_headers("Content-Type"="application/json")
    )

  # error handling
  if (status_code(response) != 200){
    stop("Please make sure your username and password combination is correct
         and that you have a valid internet connection.")
  }


  response <- content(response)

  # remove unwanted output
  response[!(names(response) %in% names(features))] <- NULL

  return(response)

}
