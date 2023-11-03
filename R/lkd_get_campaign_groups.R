#' Get Ad campaign Groups
#' Campaign groups provide advertisers a way to manage status, budget, and performance across multiple related campaigns.
#'
#' @param account_id your Linkedin Ad Account ID
#' @param test Searches for campaigns based on test or non-test status:
#'  * True: for test campaigns
#'  * False: for non-test campaigns If not specified, searches for both test and non-test campaigns.
#'
#' @return tibble with campaign groups metadata
#' @export
#'
lkd_get_campaign_groups <- function(
    account_id = lkd_get_account_id(),
    test = FALSE
) {

  resp <- lkd_make_request(
    str_glue('adAccounts/{account_id}'),
    path_append = 'adCampaignGroups',
    params = list(
      q = 'search',
      search.test = test,
      count = 1000
    )
  ) %>%
    resp_body_json()

  if (length(resp$elements) == 0) {
    cli::cli_alert_warning("You don't have adCampaignGroups")
    return(NULL)
  }

  resp_data <- tibble(campgroup = resp$elements) %>%
    unnest_wider('campgroup')

  resp_data

}
