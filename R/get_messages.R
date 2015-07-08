#' @title Get GPS data
#'
#' @description \code{get_devices} Gets device numbers from GAP API.
#'
#' @details This is a wrapper function for \code{httr::GET} which makes use of
#'   \code{format_uri} to formulate the correct uri string, and
#'   \code{jsonlite::fromJSON} to parse the incoming json, and output a
#'   character vector. This function is called repeatedly by
#'   \code{gapAPI::get_GPS}, but can be called individually to get a full
#'   dataframe without simplification.
#'
#' @param device device number retried from \code{get_devices}.
#' @inheritParams get_devices
#' @param filter_string Additional filter string that can be added to the uri
#'   string. This will be appended to the end of the http string an uses the
#'   standard verbs defined by the open api
#'   (\url{http://www.odata.org/documentation/odata-version-2-0/uri-conventions/})
#'    and implemented in the GAP API
#'   (\url{https://developer.globalalerting.com/API?item=ThingsToKnow})
#'
#' @return An object of class \code{response} from the \code{httr} package which
#'   can be passed to \code{gapAPI::simplify_cattle} for conversion to a
#'   \code{data.frame}.
#'
#' @examples
#'
#' messages <- get_messages <- function(
#' device = <device>,
#' tenant = <tenant-code>,
#' username = <username>,
#' password = <password>
#' )
#' print(messages)
#'
#' @export

get_messages <- function(
  device,
  tenant,
  username,
  password,
  filter_string = ""
) {
  out <- tryCatch(
    {

      # This is the try part

      uri_string <- format_uri(
        tenant,
        device,
        filter_string,
        type = "messages"
      )

      messages_get <- httr::GET(
        url = uri_string,
        handle = httr::handle(uri_string),
        httr::authenticate(username, password),
        httr::accept_json()
      )

    },
    error=function(cond) {
      message(paste("Error in get_messages():"))
      message(cond)
      # Choose a return value in case of error
      return(NA)
    },
    warning=function(cond) {
      message(paste("Warning from  in get_messages() - this might not be terminal:"))
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally={

      content_length <- httr::headers(messages_get)$`content-length`
      status <- httr::status_code(messages_get)

      paste(
        "Returned object of ",
        content_length,
        " bytes with status code ",
        status,
        ".",
        sep = ""
      ) %>% message
    }


  )
  return(out)
}

