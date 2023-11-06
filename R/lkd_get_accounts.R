#' Get account list
#'
#' @param start Integer, paggination. The index of the first item you want results for.
#' @param count Integer, pagination. The number of items you want included on each page of results. There could be fewer items remaining than the value you specify.
#'
#' @return tibble with account metadata
#' @export
lkd_get_accounts <- function(
    start=0,
    count=1000
) {

  resp <- lkd_make_request('adAccounts', params = list(q = 'search', start = start, count = count)) %>%
          resp_body_json()

  resp_data <- tibble(acc = resp$elements) %>%
               unnest_wider('acc')

  resp_data

}
