test_that(
  "Test normal use case for devices.",
  {

    test_uri <- format_uri(
      tenant = 4064,
      type = "devices",
      filter_string = ""
    )

    expect_is(test_uri,"character")
    expect_true(nchar(test_uri) > 0)

  }
)

test_that(
  "Test case for devices where redundant arguments are given.",
  {

    test_uri <- format_uri(
      tenant = 4064,
      device = "351564050232917",
      type = "devices",
      filter_string = ""
    )

    expect_is(test_uri,"character")
    expect_true(nchar(test_uri) > 0)

  }
)
