#' Get account list
#'
#' @return tibble with account metadata
#' @export
lkd_get_accounts <- function(
) {

  resp <- lkd_make_request('adAccounts', params = list(q = 'search', count = 1000)) %>%
          resp_body_json()

  resp_data <- tibble(acc = resp$elements) %>%
               unnest_wider('acc')

  resp_data

}
