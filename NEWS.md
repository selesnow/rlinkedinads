# rlinkedinads (development version)

* Now package include default ClientID and Client Secret for authorization.

# rlinkedinads 0.2.0

* Migrate to Linkedin Advertising API version January 2024 (202401)
* Change dependence, now `rlinkedinads` require `httr2 >= 1.0.0`.
* Change argument `facets` to `...` in `lkd_get_ads_analytics()`,

Old example (using facets):
```
report <- lkd_get_ads_analytics(
  pivot = 'CAMPAIGN',
  date_from = '2023-09-01',
  date_to = '2023-09-30',
  time_granularity = 'DAILY',
  fields = c(
    'pivotValues',
    'dateRange',
    'clicks',
    'impressions',
    'dateRange',
    'costInUsd',
    'oneClickLeads',
    'externalWebsiteConversions'
  ),
  facets = list(
    accounts = 'urn:li:sponsoredAccount:511009658',
    campaigns = "urn:li:sponsoredCampaign:253102116",
    campaigns = "urn:li:sponsoredCampaign:229686963"
  )
)
```

New example (using ...):
```
report <- lkd_get_ads_analytics2(
  pivot            = 'CAMPAIGN',
  date_from        = '2023-09-01',
  date_to          = '2023-09-30',
  time_granularity = 'DAILY',
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
  accounts  = 'urn:li:sponsoredAccount:511009658', 
  campaigns = c(
    'urn:li:sponsoredCampaign:253102116', 
    'urn:li:sponsoredCampaign:276103383'
    )
)
```

# rlinkedinads 0.1.3

* Fix token refresh process.

# rlinkedinads 0.1.2

* Patch for CRAN: Corrected package Description field.

# rlinkedinads 0.1.1

* Patch for CRAN: Corrected package title to title case.

# rlinkedinads 0.1.0

* Added a `NEWS.md` file to track changes to the package.
