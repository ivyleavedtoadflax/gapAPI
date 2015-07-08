#' @title get_GPS.
#'
#' @description \code{get_GPS} get GPS measurements from devices.
#'
#' @details This function accesses the GAP API to extract GPS meassages for a
#'   given device number between a date range. The function is essentially a
#'   wrapper for the \code{gapAPI::get_messages} and internal
#'   \code{gapAPI::simplify_format} functions.
#'
#' @param tenant The tenant code required for access to the GAP API. This is
#'   provided by CoSignal support.
#' @param username Username used to access the ninja tracking control panel.
#' @param password Password used to access the ninjac tracking control panel.
#'   removed?
#' @param device_list A character vector of device ids over which the function
#'   will iterate. These are obtained with \code{get_devices}.
#' @param start_date date from which observations will begin, given as a
#'   character vector of length one in the format: yyyy-mm-ddT00:00:00Z.
#'   Defaults to 1900-01-01T00:00:00Z. Currently functionality to select by date
#'   has not been implemented, but will be in a future version.
#' @param end_date date at which observations will end, given as a character
#'   vector of length one in the format: yyyy-mm-ddT00:00:00Z. Defaults to null.
#'   Currently functionality to select by date has not been implemented, but
#'   will be in a future version
#'
#' @return A character vector of device IDs for the appropriate tenant.
#'
#' @examples
#'
#' messages <- get_GPS <- function(
#' device = <device>,
#' tenant = <tenant-code>,
#' username = <username>,
#' password = <password>
#' )
#' print(messages)
#'
#' @export

get_GPS <- function(
  tenant,
  username,
  password,
  device_list,
  start_date = "1900-01-01T00:00:00Z",
  end_date = NULL
) {

  # Potential use cases:
  # Get all records
  # Get records up until a certain date

  # Loop through device list ----

  for (i in 1:length(device_list)) {
    #for (i in 7:9) {

    out <- tryCatch(
      {

        device <- device_list[i]

        message(paste(i, ": Device number ", device, sep = ""))

        # Get latest 10000 messages ----

        cattle_data <- get_messages(
          device = device,
          tenant = tenant,
          username = username,
          password = password
        )

        # Clean up the first 1000 values

        cattle_data <- simplify_cattle(
          x = cattle_data,
          device = device
        )

        counter <- 1

        # Every time a full 1000 rows is returned extract the earliest date, and query
        # the API for values earlier than this. Then bind these rows to the existing
        # dataframe. Once less than 1000 rows are returned in an iteration, then break
        # the loop, and continue to the next device number.

        while(nrow(cattle_data) == counter * 1000) {

          counter <- counter + 1

          message(
            paste(i, ": 1000 rows returned. Checking for earlier rows.", sep = "")
          )

          # Check the earliest date of the first 1000 rows ----

          date_string <- earliest_date(
            cattle_data,
            start_date = start_date,
            end_date = end_date
          )

          # Get next 1000 rows from the earliest date of the previous 1000 ----

          next_cattle_data <- get_messages(
            device = device,
            tenant = tenant,
            username = username,
            password = password,
            filter_string = date_string
          )

          # Simplify the returned dataframe ----

          next_cattle_data <- simplify_cattle(
            x = next_cattle_data,
            device = device
          )

          # Bind the first dataframe with the next dataframe ----

          cattle_data <- dplyr::rbind_list(
            cattle_data,
            next_cattle_data
          )

          message(
            paste(
              i,
              ": ",
              nrow(cattle_data),
              " rows returned in total.",
              sep = ""
            )
          )

        }



      },
      error = function(cond) {
        message(paste("Something went wrong in get_GPS(). Unable to get data for device", i, "."))
        message("Here's the original error message:")
        message(cond)
        # Choose a return value in case of error
        return(NA)
      },
      warning = function(cond) {
        message(paste("Unable to get data for device", i, "."))
        message("Here's the original warning message:")
        message(cond)
        message("Skipping to next...")
        # Choose a return value in case of warning
        return(NULL)
      },
      finally = {

        cattle_data <- dplyr::tbl_df(cattle_data)

        # Need to combine all dataframes from all devices together, so for the
        # first device create a new df, which results from future devices will
        # be bound to.

        if (i == 1) {

          out_data <- cattle_data

        } else {

          out_data <- dplyr::rbind_list(
            cattle_data,
            out_data
          )
        }

        #return(out_data)

      }
    )
  }

  return(out_data)

}
