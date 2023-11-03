#' Get Linkedin ads analytics
#' The Analytics Finder should be used when specifying a single pivot.
#'
#' @param pivot String. Pivot of results, by which each report data point is grouped.
#' * COMPANY - Group results by advertiser's company
#' * ACCOUNT - Group results by account.
#' * SHARE - Group results by sponsored share.
#' * CAMPAIGN - Group results by campaign.
#' * CREATIVE - Group results by creative.
#' * CAMPAIGN_GROUP - Group results by campaign group.
#' * CONVERSION - Group results by conversion.
#' * CONVERSATION_NODE - The element row in the conversation will be the information for each individual node of the conversation tree.
#' * CONVERSATION_NODE_OPTION_INDEX - Used actionClicks are deaggregated and reported at the Node Button level. The second value of the pivot_values will be the index of the button in the node.
#' * SERVING_LOCATION - Group results by serving location, onsite or offsite.
#' * CARD_INDEX - Group results by the index of where a card appears in a carousel ad creative. Metrics are based on the index of the card at the time when the user's action (impression, click, etc.) happened on the creative (Carousel creatives only).
#' * MEMBER_COMPANY_SIZE - Group results by member company size.
#' * MEMBER_INDUSTRY - Group results by member industry.
#' * MEMBER_SENIORITY - Group results by member seniority.
#' * MEMBER_JOB_TITLE - Group results by member job title.
#' * MEMBER_JOB_FUNCTION - Group results by member job function.
#' * MEMBER_COUNTRY_V2 - Group results by member country.
#' * MEMBER_REGION_V2 - Group results by member region.
#' * MEMBER_COMPANY - Group results by member company.
#' * PLACEMENT_NAME - Group results by placement.
#' * IMPRESSION_DEVICE_TYPE - Group results by the device type the ad made an impression on. Reach metrics and conversion metrics will not be available when this pivot is used.
#' @param fields String vector of report metrics. You can find list of actual metrics [here](https://learn.microsoft.com/en-us/linkedin/marketing/integrations/ads-reporting/ads-reporting?view=li-lms-2023-04&tabs=http#metrics-available).
#' @param date_from Date. Represents the inclusive start time range of the analytics. If unset, it indicates an open range up to the end time.
#' @param date_to Date. Represents the inclusive end time range of the analytics. Must be after start time if it's present. If unset, it indicates an open range from start time to everything after.
#' @param time_granularity String. Time granularity of results. Valid enum values:
#'  * ALL - Results grouped into a single result across the entire time range of the report.
#'  * DAILY - Results grouped by day.
#'  * MONTHLY - Results grouped by month.
#'  * YEARLY - Results grouped by year.
#' @param campaign_type String. Match result by a campaign type. Supported types are: TEXT_AD, SPONSORED_UPDATES, SPONSORED_INMAILS, DYNAMIC. Requires at least one other facet. Defaults to empty.
#' @param sort_by_fields String. The field by which the results are sorted. Supported values include:
#'  * COST_IN_LOCAL_CURRENCY
#'  * IMPRESSIONS
#'  * CLICKS
#'  * ONE_CLICK_LEADS
#'  * OPENS
#'  * SENDS
#'  * EXTERNAL_WEBSITE_CONVERSIONS
#' @param sort_by_order String. The order of the results. Supported values include:
#'  * ASCENDING
#'  * DESCENDING
#' @param facets List. Faceting parameter For more details see next [link](https://learn.microsoft.com/en-us/linkedin/marketing/integrations/ads-reporting/ads-reporting?view=li-lms-2023-04&tabs=http#query-parameters-4).You must specify at least one of:
#'  * shares - Match result by share facets. Defaults to empty.
#'  * campaigns - Match result by campaign facets. Defaults to empty.
#'  * creatives - Match result by creative facets. Defaults to empty.
#'  * campaignGroups - Match result by campaign group facets. Defaults to empty.
#'  * accounts - Match result by sponsored ad account facets. Defaults to empty.
#'  * companies - Match result by company facets. Defaults to empty.
#'
#' @return tibble with report
#' @export
#'
#' @examples
#' \dontrun{
#' stat <- lkd_get_ads_analytics(
#'     pivot            = 'CAMPAIGN',
#'     date_from        = '2023-09-01',
#'     date_to          = '2023-09-30',
#'     time_granularity = 'DAILY',
#'     fields           = c(
#'       'pivot',
#'       'pivotValue',
#'       'dateRange',
#'       'clicks',
#'       'impressions',
#'       'dateRange',
#'       'costInUsd',
#'       'oneClickLeads',
#'       'externalWebsiteConversions'
#'     ),
#'     facets    = list(
#'       accounts  = 'urn:li:sponsoredAccount:511009658',
#'       campaigns = "urn:li:sponsoredCampaign:253102116",
#'       campaigns = "urn:li:sponsoredCampaign:229686963"
#'     )
#'  )
#' }
lkd_get_ads_analytics <- function(
    pivot = c(
      'COMPANY',
      'ACCOUNT',
      'SHARE',
      'CAMPAIGN',
      'CREATIVE',
      'CAMPAIGN_GROUP',
      'CONVERSION',
      'CONVERSATION_NODE',
      'CONVERSATION_NODE_OPTION_INDEX',
      'SERVING_LOCATION',
      'CARD_INDEX',
      'MEMBER_COMPANY_SIZE',
      'MEMBER_INDUSTRY',
      'MEMBER_SENIORITY',
      'MEMBER_JOB_TITLE',
      'MEMBER_JOB_FUNCTION',
      'MEMBER_COUNTRY_V2',
      'MEMBER_REGION_V2',
      'MEMBER_COMPANY'
    ),
    fields           = c(
      'pivotValues',
      'dateRange',
      'clicks',
      'impressions',
      'dateRange',
      'costInUsd',
      'oneClickLeads',
      'externalWebsiteConversions'
      ),
    date_from        = Sys.Date() - 31,
    date_to          = Sys.Date() - 1,
    time_granularity = c('DAILY', 'ALL', 'MONTHLY', 'YEARLY'),
    campaign_type    = NULL,
    sort_by_fields   = c("", 'COST_IN_LOCAL_CURRENCY', 'IMPRESSIONS', 'ONE_CLICK_LEADS', 'OPENS', 'SENDS', 'EXTERNAL_WEBSITE_CONVERSIONS'),
    sort_by_order    = c("", 'ASCENDING', 'DESCENDING'),
    facets
) {

  # check args
  fields_str       <- str_c(fields, collapse = ',')
  pivot            <- match.arg(pivot)
  time_granularity <- match.arg(time_granularity)
  sort_by_fields   <- match.arg(sort_by_fields)
  sort_by_order    <- match.arg(sort_by_order)
  sort_by_fields   <- if (sort_by_fields == "") NULL
    sort_by_order  <- if (sort_by_order == "") NULL
  date_from        <- as.Date(date_from)
  date_to          <- as.Date(date_to)

  # make query params
  params <- append(
    list(
      q                     = 'analytics',
      pivot                 = pivot,
      timeGranularity       = time_granularity,
      fields                = fields_str,
      dateRange.start.day   = format(date_from, '%d'),
      dateRange.start.month = format(date_from, '%m'),
      dateRange.start.year  = format(date_from, '%Y'),
      dateRange.end.day     = format(date_to  , '%d'),
      dateRange.end.month   = format(date_to  , '%m'),
      dateRange.end.year    = format(date_to  , '%Y'),
      campaignType          = campaign_type,
      sortBy.field          = sort_by_fields,
      sortBy.order          = sort_by_order
  ),
     facets
  )

  # make request
  resp <- lkd_make_request(
    'adAnalytics',
    params = params
  ) %>% resp_body_json()

  # parse result
  parsed_resp <- tibble(elements = resp$elements) %>%
    unnest_wider('elements')


  if ('dateRange' %in% fields) {
    parsed_resp <- parsed_resp %>%
      unnest_wider('dateRange') %>%
      unnest_wider('start', names_sep = '_') %>%
      unnest_wider('end', names_sep = '_')
  }

  if ('pivotValues' %in% fields) {
    parsed_resp <- parsed_resp %>%
      unnest_longer('pivotValues')
  }

  parsed_resp <- rename_with(parsed_resp, snakecase::to_snake_case)

  parsed_resp

}
