#' Get Creatives
#' You can search for creative content in order to get a collection of creatives matching
#'
#' @param account_id your Linkedin Ad Account ID
#' @inheritParams lkd_get_accounts
#'
#' @return tibble with creatives metadata
#' @export
#'
lkd_get_creatives <- function(
    account_id = lkd_get_account_id(),
    start      = 0,
    count      = 1000
) {

  resp <- lkd_make_request(
    str_glue('adAccounts/{account_id}'),
    path_append = 'creatives',
    params = list(
      q           = 'criteria',
      start       = start,
      count       = count
    )
  ) %>%
    resp_body_json()

  if (length(resp$elements) == 0) {
    cli::cli_alert_warning("You don't have creatives")
    return(NULL)
  }

  resp_data <- tibble(criteria = resp$elements) %>%
    unnest_wider('criteria') %>%
    unnest_wider('content', names_sep = '_') %>%
    unnest_wider('review', names_sep = '_') %>%
    rename_with(snakecase::to_snake_case)

  resp_data

}
