# run the full test only in my personal machine

# full test
if (Sys.getenv('USERNAME') == 'igorl') {
df <- corporateCardExpenses()

  # tests

  test_that("able to download the full database", {
    expect_gt(nrow(df), 113340)
  })
}
