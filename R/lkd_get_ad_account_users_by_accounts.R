#' Find Ad Account Users by Accounts
#' Fetch all users associated with a specific ad account. See next [link](https://learn.microsoft.com/en-us/linkedin/marketing/integrations/ads/account-structure/create-and-manage-account-users?view=li-lms-2023-10&tabs=http#find-ad-account-users-by-accounts).
#' @param account_urn_id accounts ID with a sponsoredAccount URN
#' @inheritParams lkd_get_accounts
#'
#' @return tibble with users list
#' @export
#'
lkd_get_ad_account_users_by_accounts <- function(
    account_urn_id,
    start          = 0,
    count          = 1000
) {

  resp <- lkd_make_request(
    endpoint = 'adAccountUsers',
    params = list(
      q           = 'accounts',
      accounts    = account_urn_id,
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
