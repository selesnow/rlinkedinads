#' Get campaigns
#'
#' @param account_id your Linkedin Ad Account ID
#' @param test Searches for campaigns based on test or non-test status:
#'  * True: for test campaigns
#'  * False: for non-test campaigns If not specified, searches for both test and non-test campaigns.
#'
#' @return tibble with campaign metadata
#' @export
#'
lkd_get_campaigns <- function(
    account_id = lkd_get_account_id(),
    test = FALSE
) {

  resp <- lkd_make_request(
    str_glue('adAccounts/{account_id}'),
    path_append = 'adCampaigns',
    params = list(
      q = 'search',
      search.test = test,
      count = 1000
      )
    ) %>%
    resp_body_json()

  resp_data <- tibble(camp = resp$elements) %>%
    unnest_wider('camp') %>%
    unnest_wider('dailyBudget', names_sep = '_') %>%
    unnest_wider('unitCost', names_sep = '_')

}
