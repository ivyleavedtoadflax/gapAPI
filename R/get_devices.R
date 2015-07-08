#' @title Get device numbers
#'
#' @description \code{get_devices} Gets device numbers from GAP API.
#'
#' @details This is a wrapper function for \code{httr::GET} which makes use of
#'   \code{format_uri} to formulate the correct uri string, and
#'   \code{jsonlite::fromJSON} to parse the incoming json, and output a
#'   character vector.
#'
#' @param tenant The tenant code required for access to the GAP API. This is
#'   provided by CoSignal support.
#' @param username Username used to access the ninja tracking control panel.
#' @param password Password used to access the ninjac tracking control panel.
#'   removed?
#' @return A character vector of device IDs for the appropriate tenant.
#'
#' @examples
#'
#' library(dplyr)
#'
#' tenant <- <tenant>
#' username <- <username>
#' password <- <password>
#'
#' device_list <- get_devices(
#' tenant, username, password
#' )
#'
#' df <- get_messages(
#' device = device_list[1],
#' tenant = tenant,
#' username = username,
#' password = password
#' ) %>%
#' simplify_cattle(
#' device = device_list[1]
#' )
#'
#' print(df)
#'
#' @export


get_devices <- function(
  tenant,
  username,
  password,
  uri_string = ""
) {
  out <- tryCatch(
    {

      uri_string <- format_uri(
        tenant = tenant,
        type = "devices"
      )

      devices_get <- httr::GET(
        url = uri_string,
        handle = httr::handle(uri_string),
        httr::authenticate(username, password),
        httr::accept_json()
      )

      device_list <- devices_get %>%
        httr::content("text") %>%
        jsonlite::fromJSON(flatten = TRUE) %>%
        as.data.frame

      device_list <- device_list$DeviceId

      if (!class(device_list) %in% c("character","numeric")) {

        stop("Error: device list is not character or integer")

      }

    },
    error=function(cond) {
      message(paste("Error in get_devices():"))
      message(cond)
      # Choose a return value in case of error
      return(NA)
    },
    warning=function(cond) {
      message(paste("Warning from get_devices() - this might not be terminal:"))
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally={



    }
  )

  return(device_list)
  #return(out)

}
