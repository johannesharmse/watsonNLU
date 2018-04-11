auth_NLU <- function(username = NULL, password=NULL){
  # check that username and password have been specified as character arguments
  if (is.null(username) ||
      is.null(password) ||
      !is.character(username) ||
      !is.character(password)){
    stop("Please specify a valid username and password combination as string arguments.")
    
    # base login url 
    url_NLU="https://gateway.watsonplatform.net/natural-language-understanding/api"
    # or try this:
    # "https://gateway.watsonplatform.net/natural-language-understanding/api/v1/analyze?version=2017-02-27&url=www.ibm.com&features=keywords,entities",
    
    
    # instead of doing full GET, would it make sense to do a post?
    test_post <- POST(authenticate(username, password), add_headers("Content-Type"="application/json"))
    
    # GET -- opens channel with credentials
    response <- GET(url=url_NLU,
      authenticate(username,password),
      add_headers("Content-Type"="application/json")
    )
    
    # check for successful response
    if (status_code(response) != 200){
      message(response)
      stop("Please make sure your username and password combination is correct
         and that you have a valid internet connection or check the response log above.")
  }
  }
}  

  