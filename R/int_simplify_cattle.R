#' @title Simplify output from \code{get_messages}
#'
#' @description \code{simplify_cattle} data manipulaton function which formats outputs from
#' \code{get_messages}.
#'
#' @details This function implements some simple data manipulation operations for objects
#' returned by \code{get_messages}
#'
#' @param x an object returned by \code{get_messages}
#' @param device the device from which the \code{get_messages} object was
#'   obtained. Future versions will do this automatically.
#'
#' @return An object of class \code{c(tbl,tbl_df),data.frame} with the following
#'   columns: device, timestamp, date, time, SequenceNumber,SentFromDevice,
#'   MessageType, lon, lat, speed, heading, alt, accuracy.
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

simplify_cattle <- function(
  x,
  device = device
) {
  out <- tryCatch(
    {

      device <- as.character(device)

      # Test validity of device

      if(!is.character(device) & length(device) != 1) {

        stop("Error: Device number is not character or is not a singular.")

      }

      out_df <- x %>%
        httr::content("text") %>%
        jsonlite::fromJSON(flatten = TRUE) %>%
        as.data.frame

      if (nrow(out_df) == 0) {

        message("No values were returned from API query.")

#         out_df <- data.frame(
#           device = character(0),
#           date = character(0),
#           SequenceNumber = integer(0),
#           SentFromDevice = character(0),
#           MessageType = character(0),
#           lon = double(0),
#           lat = double(0),
#           speed = double(0),
#           heading = double(0),
#           alt = double(0),
#           accuracy = character(0)
#         )

      } else {
        out_df <- out_df %>%
          dplyr::mutate_(
            device = ~device,
            timestamp = ~lubridate::ymd_hms(Position.GpsTimestamp),
            time = ~format(timestamp,"%H:%M:%S"),
            date = ~format(timestamp,"%Y-%m-%d"),
            SentFromDevice = ~lubridate::ymd_hms(SentFromDevice)
          ) %>%
          dplyr::select_(
            ~device,
            ~timestamp,
            ~date,
            ~time,
            ~SequenceNumber,
            ~SentFromDevice,
            ~MessageType,
            lon = ~Position.Longitude,
            lat = ~Position.Latitude,
            speed = ~Position.Speed,
            heading = ~Position.Heading,
            alt = ~Position.Altitude,
            accuracy = ~Position.Accuracy
          ) %>%
          dplyr::tbl_df()
      }

    },
    error=function(cond) {
      message(paste("Error in simplify_cattle():"))
      message(cond)
      # Choose a return value in case of error
      return(NA)
    },
    warning=function(cond) {
      message(paste("Warning arising from simplify_cattle() - this might not be terminal:"))
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally={

      if(
        !"tbl_df" %in% class(out_df) &
        !"tbl" %in% class(out_df) &
        !"data.frame" %in% class(out_df)
      ) {

        stop("Error: Output object is not a tbl, tbl_df, or data.frame as expected")

      }

    }
  )
  return(out)
}
