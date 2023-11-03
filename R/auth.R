#' Authorization in Linkedin API
#'
#' Authorization in Linkedin API. For more details see [link](https://learn.microsoft.com/en-us/linkedin/shared/authentication/authentication).
#'
#' @param login your Linkedin login
#'
#' @return No return value, just take API token
#' @export
#'
#' @examples
#' \dontrun{
#' # set auth data
#' lkd_set_client_id('Your client id')
#' lkd_set_client_secret('Your client secret')
#' lkd_set_login('Your linkedin login')
#'
#' lkd_auth()
#'
#' }
lkd_auth <- function(
    login = Sys.getenv('LKD_LOGIN')
) {

  lkd_set_login(login)

  if (lkd_has_token()) {
    cli::cli_alert_success('Token load from cache!\nCache path: {.path {lkd_token_file_path()}}')
  } else {
    lkd_auth_browser()
  }

}


# helpers -----------------------------------------------------------------
lkd_auth_browser <- function(
    login         = lkd_get_login(),
    client_id     = lkd_get_client_id(),
    client_secret = lkd_get_client_secret(),
    redirect_uri  = 'https://selesnow.github.io/rlinkedinads/inst/get_code/auth_code.html',
    scopes        = c('r_ads_reporting', 'r_organization_social', 'rw_organization_admin', 'w_member_social', 'r_ads', 'w_organization_social', 'rw_ads', 'r_basicprofile', 'r_organization_admin', 'r_1st_connections_size')
) {

  if (client_id == "" || client_secret == "") {
    cli::cli_alert_danger('You need to set client_id and client_secret for authorization, see {.href https://learn.microsoft.com/en-us/linkedin/shared/authentication/authentication}')
    stop('client_id or client_secret not set!')
  }

  # take code
  "https://www.linkedin.com/oauth/v2/authorization" %>%
    param_set(key = "client_id",     value = client_id) %>%
    param_set(key = "redirect_uri",  value = redirect_uri) %>%
    param_set(key = "response_type", value = "code") %>%
    param_set(key = "scope",         value = str_c(scopes, collapse = '%20')) %>%
    browseURL()

  auth_code <- readline('Enter your code: ')

  # change code to access token
  token_resp <- request('https://www.linkedin.com/oauth/v2/accessToken') %>%
    req_body_form(
      'code'          = auth_code,
      "grant_type"    = "authorization_code",
      "client_id"     = client_id,
      "client_secret" = client_secret,
      "redirect_uri"  = 'https://selesnow.github.io/rlinkedinads/inst/get_code/auth_code.html'
    ) %>%
    req_perform()

  # parse token
  access_token <- token_resp %>% resp_body_json()

  # expire time
  access_token$expires_at <- Sys.time() + access_token$expires_in
  access_token$refresh_token_expires_at <- Sys.time() + access_token$refresh_token_expires_in

  # add class
  class(access_token) <- 'lkd.oauth.token'

  if (! dir.exists(lkd_get_token_path()) ) {
    dir.create(lkd_get_token_path(), recursive = T)
  }

  file_path <- lkd_token_file_path()
  saveRDS(access_token, file_path)
  cli::cli_alert_success('Authorizations complete!')
  cli::cli_alert_info('Token cached at {.path {lkd_token_file_path()}}')

}

lkd_get_token <- function(login = lkd_get_login()) {

  file_path <- lkd_token_file_path(login)

  if (file.exists(file_path)) {

    lkd_token <- readRDS(file_path)

  } else {

    cli::cli_alert_warning("You need make autharizations!")

    if (interactive()) {
      lkd_auth_browser()
    } else {
      lkd_token <- NULL
    }

  }

  lkd_token

}

lkd_refresh_token <- function(
    login         = lkd_get_login(),
    client_id     = lkd_get_client_id(),
    client_secret = lkd_get_client_secret()
) {

  token <- lkd_get_token(login = login)

  token_resp <- request('https://www.linkedin.com/oauth/v2/accessToken') %>%
    req_body_form(
      "grant_type"    = "refresh_token",
      "refresh_token" = token$refresh_token,
      "client_id"     = client_id,
      "client_secret" = client_secret
    ) %>%
    req_perform()

  # parse token
  access_token <- token_resp %>% resp_body_json()

  # expire time
  access_token$expires_at <- Sys.time() + access_token$expires_in
  access_token$refresh_token_expires_at <- Sys.time() + access_token$refresh_token_expires_in

  # save
  if (! dir.exists(lkd_get_token_path()) ) {
    dir.create(lkd_get_token_path(), recursive = T)
  }

  file_path <- lkd_token_file_path()
  saveRDS(access_token, file_path)

  cli::cli_alert_success('Token updated successful!')
  cli::cli_alert_info('Token file location {.path {lkd_token_file_path()}}')

}

lkd_inspect_token <- function(
    login = lkd_get_login(),
    echo  = FALSE
) {

  token <- lkd_get_token(login = login)

  token_resp <- request('https://www.linkedin.com/oauth/v2/introspectToken') %>%
    req_body_form(
      "client_id"     = lkd_get_client_id(),
      "client_secret" = lkd_get_client_secret(),
      "token"         = token$access_token
    ) %>%
    req_perform()

  # parse token
  access_token <- token_resp %>% resp_body_json()

  if (echo) {

    cli::cat_rule('Linkedin Ads OAuth Token Info:')

    for (field in names(access_token)) {
      field_val <- if (field %in% c('authorized_at', 'created_at', 'expires_at')) as.POSIXct(access_token[[field]], tz = Sys.timezone()) else access_token[[field]]
      cli::cli_inform('{.pkg {field}}: {field_val}')
    }

    cli::cli_inform('{.pkg need_to_refresing}: {access_token$expires_at < (Sys.time() - (60 * 60 * 24 * 10))}')

  }

  access_token$expires_at < (Sys.time() - (60 * 60 * 24 * 10))

}

lkd_check_token <- function(
    login = Sys.getenv('LKD_LOGIN')
  ) {

  token <- lkd_get_token(login)

  if (lkd_inspect_token(login)) {
    cli::cli_alert_info('Token auto refreshing')
    lkd_refresh_token(login = login)
  }

}

lkd_token_file_path <- function(
    login = lkd_get_login()
) {
  file_name <- str_glue('{login}.lkd.rds')
  file_path <- normalizePath(str_c(lkd_get_token_path(), file_name, sep = "/"), mustWork = F)
  file_path
}

lkd_has_token <- function(
    login = lkd_get_login()
) {
  file.exists(lkd_token_file_path())
}

# setters -----------------------------------------------------------------
lkd_set_client_id <- function(client_id) {
  Sys.setenv('LKD_CLIENT_ID' = client_id)
}

lkd_set_client_secret <- function(client_secret) {
  Sys.setenv('LKD_CLIENT_SECRET' = client_secret)
}

lkd_set_login <- function(login) {
  Sys.setenv('LKD_LOGIN' = login)
}

lkd_set_token_path <- function(token_path) {
  Sys.setenv('LKD_TOKEN_PATH' = token_path)
}

lkd_set_api_version <- function(api_version) {
  options('lkd.api_version' = api_version)
}

lkd_set_account_id <- function(account_id) {
  options('lkd.account_id' = account_id)
}

# getters -----------------------------------------------------------------
lkd_get_client_id <- function() {
  Sys.getenv('LKD_CLIENT_ID')
}

lkd_get_client_secret <- function() {
  Sys.getenv('LKD_CLIENT_SECRET')
}

lkd_get_login <- function(echo=FALSE) {
  login <- Sys.getenv('LKD_LOGIN')
  if (length(login) > 0 & echo) {
    cli::cli_text('Token location: {.path {lkd_token_file_path(login)}}')
  }
  login
}

lkd_get_token_path <- function() {
  token_path <- getOption('lkd.token_path') %||% Sys.getenv('LKD_TOKEN_PATH')
  if (is.null(token_path) || identical(token_path,  '')) return( normalizePath(rappdirs::user_cache_dir("rlinkedinads"), mustWork = F))
  return(token_path)
}

lkd_get_account_id <- function() {
  getOption('lkd.account_id')
}

lkd_list_logins <- function() {
  logins <- dir(lkd_get_token_path(), all.files = T, pattern = 'rds$') %>% str_remove('\\.rds')

  if (length(logins) > 0)
  cli::cat_rule('List of Linkedin Ads OAuth Tokens')
  for (login in logins) cli::cli_text('{.file {login}}')

}


# remove token ------------------------------------------------------------

#' remove token
#'
#' @param login your login at Linkedin
#'
#' @return no return value, just remove token cacche
#' @export
lkd_remove_token <- function(login = lkd_get_login()) {

  if (interactive()) {
    answer <- readline(prompt = "Do you want to remove token? Y/n")
    if (answer == "Y") {
      file_path <- lkd_token_file_path()
      file.remove(file_path)
    } else {
      cli::cli_alert_warning('Tokent don`t removed')
    }
  } else {
    cli::cli_alert_warning('You can remove token only on interactive mode.')
  }
}

# print -------------------------------------------------------------------
print.lkd.oauth.token <- function(x, ...) {
  cli::cat_rule('Linkedin Ads OAuth Token')
  cli::cli_inform('{.pkg Access token} expires at { access_token$expires_at}')
  cli::cli_inform('{.pkg Refresh token} expires at {access_token$refresh_token_expires_at}')
}
