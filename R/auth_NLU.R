#' Watson Natural Language Understanding API Authentication
#'
#' The \strong{auth_NLU} function takes in a username and password as input to authenticate the users computer to use the Watson Natural Language Understanding API.
#'
#' See the \href{https://github.com/johannesharmse/watsonNLU/blob/master/README.md}{sign-up} documentation for step by step instructions to secure your own username and password to enable you to use the Watson NLU API.
#'
#'
#' @param username Authentication IBM Watson Natural-Language-Understanding-3j \strong{username}
#' @param password Authentication IBM Watson Natural-Language-Understanding-3j \strong{password}
#'
#' @return If authentication is successful, there is no return value. If unsuccessful,
#'    the function will ask the user to ensure username and password combination are correct.
#'
#' @import httr
#'
#' @export

auth_NLU <- function(username = NULL, password=NULL){
  # check that username and password have been specified as character arguments
  if (is.null(username) ||
      is.null(password) ||
      !is.character(username) ||
      !is.character(password)){
    stop("Please specify a valid username and password combination as string arguments.")
  }
  # base login url
  url_NLU = "https://gateway.watsonplatform.net/natural-language-understanding/api/v1/analyze"
  
  response <- GET(url=paste0(url_NLU),
                  authenticate(username, password),
                  add_headers("Content-Type"="application/json")
  )
  
  status <- status_code(response)
  
  if (status == 400){
    return(print("Valid credentials provided."))
  }else if(status == 401){
    stop("Invalid credentials provided.")
  }else{
    stop(content(response))
  }
}
