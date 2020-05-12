# add these three lines to the start of your script and remove them from this script
library(tidyverse)
library(rvest)
source('99_parse-article-functions.R')

# function that loops over a bunch of urls, running parse_url on each one, returning the results as a data frame
parse_urls <- function(urls) {
  # the map functions in purrr loop over a list, performing the same function on each element
  # map_dfr takes the resulting list and converts it into a data frame by row-binding
  # this works if the function used returns data frames with consistent fields each time it runs
  map_dfr(urls, parse_url)
}

# function that takes a url, reads it, and returns the results as a three-column one-row data frame
parse_url <- function(url) {
  # first, load the website and grab the html
  article_html <- read_html(url)
  
  # grab the title and text of the article using functions defined below:
  article_title <- extract_title(article_html)
  article_text  <- extract_text(article_html)
  
  # finally, create a one-row data frame (in this case, specifically a tibble) with url, title, and text
  tibble(url   = url,
         title = article_title,
         text  = article_text)
}

# this function takes the html and grabs only the title
extract_title <- function(article_html) {
  article_html %>%
    html_node("title") %>%
    html_text()
}

# this function takes the html and grabs the article text
extract_text <- function(article_html) {
  article_html %>% 
    html_nodes("p") %>%
    html_text() %>%
    paste(collapse = " ")
}
