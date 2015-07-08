#' @title ealiest_date
#'
#' @description \code{get_devices} Gets device numbers from GAP API.
#'
#' @details This is a wrapper function for \code{httr::GET} which makes use of
#'   \code{format_uri} to formulate the correct uri string, and
#'   \code{jsonlite::fromJSON} to parse the incoming json, and output a
#'   character vector.
#'
#' @param ... Numeric, complex, or logical vectors.
#'   be removed?
#' @return If all inputs are integer and logical, then the output
#'
#' @examples
#' TODO
#'
#'

earliest_date <- function(
  x,
  start_date = start_date,
  end_date = end_date,
  ...
) {

  out <- tryCatch(
    {

      # check start date format

      if (!grepl("\\d+\\-\\d+\\-\\d+T\\d+\\:\\d+\\:\\d+Z", start_date, perl = TRUE)) {

        stop("Error: start_date date is not in the correct format: must be yyyy-mm-ddTHH:MM:SSZ.")

      }

      if (is.null(end_date)) {

        end_date <- x$SentFromDevice %>% min %>% lubridate::ymd_hms() %>% round(units = "secs") %>% format("%Y-%m-%dT%H:%M:%SZ")

      } else {

        if (!grepl("\\d+\\-\\d+\\-\\d+T\\d+\\:\\d+\\:\\d+Z", end_date, perl = TRUE)) {

          stop("Error: end_date date is not in the correct format: must be yyyy-mm-ddTHH:MM:SSZ.")

        }
      }

      earliest_uri <- paste(
        "?$filter=SentFromDevice gt datetime'",
        start_date,
        "' and ",
        "SentFromDevice lt datetime'",
        end_date,
        "'",
        sep = ""
      )


    },
    error=function(cond) {
      message(paste("Error in earliest_date():"))
      message(cond)
      # Choose a return value in case of error
      return(NA)
    },
    warning=function(cond) {
      message(paste("Warning from earliest_date() - this might not be terminal:"))
      message(cond)
      # Choose a return value in case of warning
      return(NULL)
    },
    finally={

      return(earliest_uri)

    }
  )

  return(out)
}
