#' Watson Natural Language Understanding: Document Keyword-Emotions Analyzer
#'
#' See the \href{https://www.ibm.com/watson/developercloud/natural-language-understanding/api/v1/#get-analyze}{IBM Watson NLU API} documentation for more information.
#'
#'
#' @param input A text input or URL of a website
#' @param input_type The type of input. It can either be `text` or `url` but not both.
#'
#' @param version The release date of the API version to use.
#' @return A dataframe with keywords and likelihood of emotions related to those keywords found in the text or URL.
#'
#' @examples
#' # Find the keywords and related emotions in the given text input. By default it takes version = 2018-03-16
#' keyword_emotions(input = 'This is a great API wrapper', input_type='text')
#'
#' # Find the keywords and related emotions in the given URL input. By default it takes version = 2018-03-16
#' keyword_emotions(input = 'http://www.nytimes.com/guides/well/how-to-be-happy', input_type='url')
#'
#' @import httr
#'
#' @export

keyword_emotions <-  function(input = NULL, 
                        input_type = NULL, 
                        version="?version=2018-03-16"){
  
  # specfying accepted input types
  accepted_input_types <- c('text', 'url')
  
  url_NLU <- "https://gateway.watsonplatform.net/natural-language-understanding/api"
  
  # We will be extracting emotions of keyword features in our API
  feature_string <- paste0("&features=", "keywords")
  emotion_string <- paste0("&keywords.emotion=true")
  
  # CHECK if input_type is specified or not. By default use URL.
  if (is.null(input_type)){
    message("Input type not specified. Please make sure to specify `url` in `input_type` if input is URL. Assuming text input.")
    input_type <- 'text'
  }
  
  # CHECK if Input-type is character.
  if (!is.character(input_type)){
    stop("Input type needs to be specified as a character string('url' or 'text').")
  }else{
    input_type <- tolower(input_type)
  }
  
  
  # CHECK if input is text or url and modify input string.
  if (input_type == 'text'){
    input <- URLencode(input)
    input_string <- paste0("&text=", input)
  }else if(input_type == 'url'){
    input_string <- paste0("&url=", input)
  }
  
  # CHECK if input type is within acceptable values.
  if (!input_type %in% accepted_input_types){
    stop("Input type should be either 'url' or 'text'.")
  }
  
  # Building the GET query.
  response_json <- GET(
    url = paste0(
      url_NLU,
      "/v1/analyze",
      version,
      input_string,
      feature_string,
      emotion_string
    ),
    # authenticate(username, password),
    add_headers("Content=Type"="application/json")
  )
  
  ###### CHECK RESPONSE ########
  
  if (status_code(response_json) != 200){
    
    # Include error message returned from the API call.
    message(response_json)
    stop("Please make sure your username and password combination is correct
         and that you have a valid internet connection or check the response log above.")
  }
  
  # Save response as a list
  response_list <- content(response_json)
  
  # Check if response is NULL.
  if (!is.null(response_list$keywords)){
    response_keywords <- response_list$keywords
  }else{
    stop("No results available")
  }

  # Store keywords and emotion scores in vectors.
  keywords <- sapply(1:length(response_keywords), 
                     function(x) response_keywords[[x]]$text)
  relevance <- sapply(1:length(response_keywords), 
                      function(x) response_keywords[[x]]$relevance)
  emo_sadness <- sapply(1:length(response_keywords), 
                        function(x) response_keywords[[x]]$emotion$sadness)
  emo_joy <- sapply(1:length(response_keywords), 
                    function(x) response_keywords[[x]]$emotion$joy)
  emo_fear <- sapply(1:length(response_keywords), 
                     function(x) response_keywords[[x]]$emotion$fear)
  emo_disgust <- sapply(1:length(response_keywords), 
                        function(x) response_keywords[[x]]$emotion$disgust)
  emo_anger <- sapply(1:length(response_keywords), 
                      function(x) response_keywords[[x]]$emotion$anger)

  # Combine vectors into one data frame.
  response_df <- data.frame(
    'keyword' = keywords,
    'key_relevance' = relevance,
    'sadness' = emo_sadness,
    'joy' = emo_joy,
    'fear' = emo_fear,
    'disgust' = emo_disgust,
    'anger' = emo_anger
  )

  # Return a DataFrame of emotions of the keywords found in the text/url.
  return(response_df)
}
  