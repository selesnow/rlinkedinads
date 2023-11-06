#' Find Ad Accounts by Authenticated User
#' All ad accounts that an authenticated user has access
#' @inheritParams lkd_get_accounts
#'
#' @return tibble with accounts list
#' @export
#'
lkd_get_accounts_by_authenticated_user <- function(
    start      = 0,
    count      = 1000
) {

  resp <- lkd_make_request(
    endpoint = 'adAccountUsers',
    params = list(
      q           = 'authenticatedUser',
      start       = start,
      count       = count
    )
  ) %>%
    resp_body_json()

  if (length(resp$elements) == 0) {
    cli::cli_alert_warning("You don't have adAccountUsers")
    return(NULL)
  }

  resp_data <- tibble(accounts = resp$elements) %>%
    unnest_wider('accounts') %>%
    unnest_wider('changeAuditStamps') %>%
    unnest_wider('created', names_sep = '_') %>%
    unnest_wider('lastModified', names_sep = '_') %>%
    rename_with(snakecase::to_snake_case)

  resp_data

}
