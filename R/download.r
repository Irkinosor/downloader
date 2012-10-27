#' Download a file, using http, https, or ftp
#'
#' This is a wrapper for \code{\link{download.file}} and takes all the same
#' arguments. The only difference is that, if the protocol is https, it changes
#' some settings to make it work. How exactly the settings are changed
#' differs among platforms.
#'
#' With Windows, it calls \code{setInternet2}, which tells R to use the
#' \code{internet2.dll}. Then it downloads the file by calling
#' \code{\link{download.file}} using the \code{"internal"} method.
#'
#' On other platforms, it will try to use \code{wget}, then \code{curl}, and
#' then \code{lynx} to download the file. Typically, Linux platforms will have
#' \code{wget} installed, and Mac OS X will have \code{curl}.
#'
#' @param url The URL to download.
#' @param ... Other arguments that are passed to \code{\link{download.file}}.
#'
#' @seealso \code{\link{download.file}} for more information on the arguments
#'   that can be used with this function.
#'
#' @export
#' @examples
#' \dontrun{
#' download("https://raw.github.com/gist/3961317/28bea6e63ec295a452486cbc36afb62a3ddad878/download.r", "download.r")
#' }
#'
download <- function(url, ...) {
  # First, check protocol. If https, check platform:
  if (grepl('^https://', url)) {

    # If Windows, call setInternet2, then use download.file with defaults.
    if (.Platform$OS.type == "windows") {

      # Store initial settings, and restore on exit
      internet2_start <- setInternet2(NA)
      on.exit(setInternet2(internet2_start))

      # Needed for https
      setInternet2(TRUE)
      download.file(url, ...)

    } else {
      # If non-Windows, check for curl/wget/lynx, then call download.file with
      # appropriate method.

      if (system("wget --help", ignore.stdout=TRUE, ignore.stderr=TRUE) == 0L) 
        method <- "wget"
      else if (system("curl --help", ignore.stdout=TRUE, ignore.stderr=TRUE) == 0L) 
        method <- "curl"
      else if (system("lynx -help", ignore.stdout=TRUE, ignore.stderr=TRUE) == 0L) 
        method <- "lynx"
      else
        stop("no download method found")

      download.file(url, method = method, ...)
    }

  } else {
    download.file(url, ...)
  }
}