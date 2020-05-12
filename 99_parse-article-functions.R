# code prereqs to copy into other scripts ####

# add these three lines to the start of your script and remove them from this script
library(tidyverse)
library(rvest)
source('99_parse-article-functions.R')

# main functions for parsing urls ####

# function that loops over a bunch of urls, running parse_url on each one, returning the results as a data frame
parse_urls <- function(urls) {
  # the map functions in purrr loop over a list, performing the same function on each element
  # map_dfr takes the resulting list and converts it into a data frame by row-binding
  # this works if the function used returns data frames with consistent fields each time it runs
  map_dfr(urls, parse_url)
}

# function that takes a url, reads it, and returns the results as a three-column one-row data frame
# errors on the html side will be skipped (passed through as NAs) if skip_errors is left as is
parse_url <- function(url, skip_errors = TRUE) {
  
  if (skip_errors) {
    # first, load the website and grab the html
    article_html <- read_html_safe(url)
    # grab the title and text of the article using functions defined below:
    article_title <- extract_title_safe(article_html)
    article_text  <- extract_text_safe(article_html) 
  } else {
    # first, load the website and grab the html
    article_html <- read_html(url)
    # grab the title and text of the article using functions defined below:
    article_title <- extract_title(article_html)
    article_text  <- extract_text(article_html)
  }
  
  # finally, create a one-row data frame (in this case, specifically a tibble) with url, title, and text
  tibble(url   = url,
         title = article_title,
         text  = article_text)
}

# versions of parsing functions that return blanks instead of stopping on error
read_html_safe     <- possibly(read_html, NULL)
extract_title_safe <- possibly(extract_title, NA_character_)
extract_text_safe  <- possibly(extract_text, NA_character_)

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

