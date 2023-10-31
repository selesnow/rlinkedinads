# auth data
client_id     = '77930obvliebie'
client_secret = 'j5LBjX1Nz691oDvo'
access_token  = "AQWxsB5kVNF2hSIRIfQYtwTypJvtNxWXeCeD1Uaamql5l04QbnI9U-7R4km1-rJpsoQCBmLR0So1Jc7MHw02GXOQXqllpDnvWC6ZzpGGG6ToEPwWmbBNpQhoMgeLV2TzBOPl6VaPyQ9WOcw2jXcuQlu7h7woHVbFxS6iLrnv6o07Fhc_DDK8byUc69RCKKZi9uoCwXkQ_NoPcqR447a2Cjxb7LLMIYC2Fx5xdH1JTO4jXMBigFimX2vWVB8Hg1JbjrbMGjaSTAFXQQVVcF2OAvcoARzY-c5aqo-lfoMUVzYLMiEjDGyycDZup8jNIlcOp-BnkR164ij17Z7BNTaZk_RzV4_BfQ"
refresh_token = "AQWx098i885W9izu9jI6N1u7DbXipElQN5D0RsbJqb-8xYMje6xMEnrYbCtPDpL-OUh_24wGl8oNTzdEFCcNIJbVXkZAEGWfgZ-6ArkJ4kQVx-xctaXcQcKw9A-D4IutALD6GZrLedlaPd-4-KPmFieBUR1G-3fXyNOzDxFUEetwKZ9hK1aP_RQ1EZQ2C6hM99QGKfpnBcBIesZVwkf4LJVwmv3hoied1siuuuVia1PxgyWpToMUiPWs1wU75swzSpnxNMBazb7m-ahEk6UFC_EiwBD9xXyspTaqoLc2P5xZ-_ezIzHX3V_WsWca4ZAQy5PSOY-Jdo_d2T2QbZOc4aZ5k09Few"

auth_url      = "https://www.linkedin.com/oauth/v2/authorization"
scopes        = c('r_ads_reporting', 'r_organization_social', 'rw_organization_admin', 'w_member_social', 'r_ads', 'w_organization_social', 'rw_ads', 'r_basicprofile', 'r_organization_admin', 'r_1st_connections_size')


library(urltools)
library(stringr)
library(httr2)

# take code
auth_url %>%
  param_set(key = "client_id",     value = client_id) %>%
  param_set(key = "redirect_uri",  value = "https://www.linkedin.com/developers/tools/oauth/redirect") %>%
  param_set(key = "response_type", value = "code") %>%
  param_set(key = "scope",         value = str_c(scopes, collapse = '%20')) %>%
  browseURL()

# parse code
answer <- 'https://www.linkedin.com/developers/tools/oauth/redirect?code=AQTnD6RxOK7-G3Dg-bxwPabLUIJONU-Xq09IVVKJ-4vTgNSsk__6Cnt0PcaaSR2rYNUmT0HJYe83vuWBSRekPXZTH9CsvJpFKTa5PDdYQNzIA-45sd570xhGGOeuxNpn3g5L_-M6HyEQXc-bhKmRfXziR7aQrqm8jFTW4h9uVwSE91mL9HwiOcdOHn7vgCJbaXqJWLl1K6UyWQHT6UM'
resp_code <- urltools::param_get(urls = answer, parameter_names = 'code')
resp_code <- resp_code$code


# change code to access token
token_resp <- request('https://www.linkedin.com/oauth/v2/accessToken') %>%
  req_body_form(
    'code' = resp_code,
    "grant_type" = "authorization_code",
    "client_id" = client_id,
    "client_secret" = client_secret,
    "redirect_uri" = 'https://www.linkedin.com/developers/tools/oauth/redirect'
  ) %>%
  req_perform()

# parse token
access_token <- token_resp %>% resp_body_json()
access_token$expires_in
as.POSIXct(access_token$refresh_token_expires_in)


# test req
resp <- request('https://api.linkedin.com/v2/') %>%
        req_url_path_append('me') %>%
        req_auth_bearer_token(access_token$access_token) %>%
        req_perform()

resp_data <- resp %>% resp_body_json()


browseURL('https://learn.microsoft.com/en-us/linkedin/marketing/authentication/lms-generate-an-access-token?context=linkedin%2Fmarketing%2Fcontext&view=li-lms-2023-10')
