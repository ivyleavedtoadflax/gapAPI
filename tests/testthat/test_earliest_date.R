require(lubridate)

# Test pass instance
test_dataframe <- readRDS("test_dataframe.Rds")


test_that(
  "Check normal used case",
  {
    test_date <- earliest_date(
        x = test_dataframe,
        start_date = "2001-01-01T00:00:00Z",
        end_date = NULL
        )

    expect_is(test_date, "character")
    expect_true(length(test_date) == 1)
    expect_equal(test_date, "?$filter=SentFromDevice gt datetime'2001-01-01T00:00:00Z' and SentFromDevice lt datetime'2011-01-01T10:00:05Z'")
    }
  )
