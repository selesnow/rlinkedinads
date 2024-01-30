.onLoad <- function(libname, pkgname) {

  # options
  op <- options()
  op.lkd <- list(lkd.api_version = '202401')

  toset <- !(names(op.lkd) %in% names(op))
  if (any(toset)) options(op.lkd[toset])

  invisible()
}

.onAttach <- function(lib, pkg,...){

  packageStartupMessage(rgoogleadsWelcomeMessage())

}


rgoogleadsWelcomeMessage <- function(){
  # library(utils)

  paste0("\n",
         "---------------------\n",
         "Welcome to rgoogleads version ", utils::packageDescription("rlinkedinads")$Version, "\n",
         "\n",
         "Author:           Alexey Seleznev (Head of analytics dept at Netpeak).\n",
         "Telegram channel: https://t.me/R4marketing \n",
         "YouTube channel:  https://www.youtube.com/R4marketing/?sub_confirmation=1 \n",
         "Email:            selesnow@gmail.com\n",
         "Site:             https://selesnow.github.io \n",
         "Blog:             https://alexeyseleznev.wordpress.com \n",
         "Facebook:         https://facebook.com/selesnown \n",
         "Linkedin:         https://www.linkedin.com/in/selesnow \n",
         "\n",
         "Using Googla Ads API version: ", getOption('lkd.api_version'), "\n",
         "\n",
         "Type ?rgoogleads for the main documentation.\n",
         "The github page is: https://github.com/selesnow/rlinkedinads/\n",
         "Package site: https://selesnow.github.io/rlinkedinads\n",
         "Package lessons playlist: https://www.youtube.com/playlist?list=PLD2LDq8edf4qprTxRcflDwV9IvStiChHi\n",
         "\n",
         "Suggestions and bug-reports can be submitted at: https://github.com/selesnow/rlinkedinads/issues\n",
         "Or contact: <selesnow@gmail.com>\n",
         "\n",
         "\tTo suppress this message use:  ", "suppressPackageStartupMessages(library(rlinkedinads))\n",
         "---------------------\n"
  )
}
