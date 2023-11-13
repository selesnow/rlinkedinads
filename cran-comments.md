## R CMD check results

0 errors | 0 warnings | 1 note

Please ensure that your functions do not write by default or in your
examples/vignettes/tests in the user's home filespace (including the
package directory and getwd()). This is not allowed by CRAN policies.
Please omit any default path in writing functions. In your
examples/vignettes/tests you can write to tempdir(). -> R/auth.R

* The package stores only authorization data exclusively in a specialized user directory, the path to which is generated using rappdirs::user_cache_dir(), so I comply with the XDG Base Directory Specification and do not violate the CRAN policy. This is "Persistent user data" for more details see <https://r-pkgs.org/data.html#sec-data-persistent>.
