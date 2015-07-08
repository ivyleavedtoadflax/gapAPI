#' @title Save GPS data to .csv
#'
#' @description Saves objects created by \code{get_messages} and
#'   \code{simplify_cattle} to a .csv file.
#'
#' @details Saves out .csv file from GPS data obtained using \code{get_messages}
#'   and then passed to \code{simplify_cattle}, and includes a check that an
#'   output file was created.
#'
#' @param x a dataframe object created by \code{simplify_cattle}. Can also be
#'   used for other dataframes with a SentFromDevice field.
#' @param folder destination folder.
#'
#' @return Writes out csv file to destination folder with file name of the format: <device>_yyyy-mm-dd_HH_MM_SS_.csv
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
#' # Must create "my folder" first
#'
#' df <- get_messages(
#' device = device_list[1],
#' tenant = tenant,
#' username = username,
#' password = password
#' ) %>%
#' simplify_cattle(
#' device = device_list[1]
#' ) %>%
#' save_records(
#' "my_folder"
#' )
#'
#' print(df)
#'
#' @import dplyr
#' @export

save_records <- function(x, folder) {

  # Setup filename

  unique_device <- unique(x$device)
  earliest_date <- max(x$SentFromDevice)
  earliest_date <- paste(earliest_date, collapse = " ")
  earliest_date <- gsub(
    ":|\ ", "_",
    x = earliest_date,
    perl = TRUE
  )

  file_name <- paste(
    unique_device,
    earliest_date,
    ".csv",
    sep = "_"
  )

  # Check that filename is reasonable
  # TODO: automatically shortening filenames if required

  if(class(file_name) != "character") {

    warning("Filename is not character")

  } else if (nchar(file_name) > 256 ) {

    stop("Error: Filename does not exceed 256 characters")

  }

  file_path <- file.path(
    folder,
    file_name
  )

  write_csv(
    x,
    path = file_path
  )

  if (!file.exists(file_path)) {

    warning("Warning: file was not created.")

  }

}
