. <- NULL

lkd_make_request <- function(
  endpoint,
  path_append=NULL,
  params=NULL
) {

  lkd_check_token()

  request('https://api.linkedin.com/rest/') %>%
    req_url_path_append(endpoint) %>%
    req_url_path_append(path_append) %>%
    req_auth_bearer_token(lkd_get_token()$access_token) %>%
    req_url_query(!!!params, .multi = "explode") %>%
    req_headers(
      'Linkedin-Version' = getOption('lkd.api_version')
    ) %>%
    req_error(body = lkd_error_body) %>%
    req_perform()

}

lkd_error_body <- function(resp) {

  status <- resp %>% resp_body_json() %>% .$status

  if (status >= 400) {
    msg <- resp %>% resp_body_json() %>% .$message
    dsc <- resp %>% resp_body_json() %>% .$errorDetails %>% .$inputErrors %>% .[[1]] %>% .$description
    fld <- resp %>% resp_body_json() %>% .$errorDetails %>% .$inputErrors %>% .[[1]] %>% .$input %>% .$inputPath %>% .$fieldPath
    str_c(msg, dsc, fld, sep = '\n')
  }

}
