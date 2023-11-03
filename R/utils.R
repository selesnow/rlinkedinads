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
    req_url_query(!!!params) %>%
    req_headers(
      'Linkedin-Version' = getOption('lkd.api_version')
    )%>%
    req_perform()

}

