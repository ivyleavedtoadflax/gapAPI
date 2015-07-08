#' @title int_format_url
#'
#' @description \code{int_format_url} Generic internal function that formats api url string.
#'
#' @details Generic internal function that formats a url string for the gap API.
#'
#' @param tenant The tenant code required for access to the GAP API. This is provided by CoSignal support.
#' @param device device number retried from \code{get_devices}.
#' @param type character string either: \code{messages} or \code{devices}
#'
#' @return If all inputs are integer and logical, then the output
#'   will be an integer. If integer overflow
#'   \url{http://en.wikipedia.org/wiki/Integer_overflow} occurs, the output
#'   will be NA with a warning. Otherwise it will be a length-one numeric or
#'   complex vector.
#'
#'   Zero-length vectors have sum 0 by definition. See
#'   \url{http://en.wikipedia.org/wiki/Empty_sum} for more details.
#' @examples
#' sum("a")

format_uri <- function(
  tenant = tenant,
  device = device,
  type = "messages",
  filter_string = ""
) {

  out <- tryCatch(
    {

      if (!type %in% c("messages","devices") & length(type) == 1) {

        stop("Error: type argument is not one of 'devices' or 'messages'.")
      }
      if (type == "messages") {

        uri_string <- paste(
          "https://api-gap-eu-1.globalalerting.com/",
          tenant,
          "/devices/",
          device,
          "/momessages",
          filter_string,
          sep = ""

        )

      } else if (type == "devices") {

        uri_string <- paste(
          "https://api-gap-eu-1.globalalerting.com/",
          tenant,
          "/devices",
          sep = ""
        )

      }
      # There is probably a dedicated function somewhere that will do a better
      # job of this e.g. httr::parse_url and httr::build_url

      uri_string <- gsub(" ", "%20", uri_string)
      uri_string <- gsub("'", "%27", uri_string)

      message(uri_string)

    },
    error=function(cond) {
      message(paste("Error in format_uri():"))
      message(cond)
      # Choose a return value in case of error
      return(NA)
    },
    warning=function(cond) {
      message(paste("Warning from format_uri() - this might not be terminal:"))
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally={

      return(uri_string)

    }
  )

  return(out)

}
