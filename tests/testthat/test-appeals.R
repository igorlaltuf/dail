# run the full test only in my personal machine

# full test
if (Sys.getenv('USERNAME') == 'igorl') {

  df <- appeals()
  df2 <- appeals(year = 2018)
  df3 <- appeals(year = c(2019, 2020))
  df4 <- appeals(search = 'ovni')
  df5 <- appeals(search = 'objeto voador')
  df6 <- appeals(search = 'covid', answer = T)
  df7 <- appeals(search = 'UFF', year = 2015)
  df8 <- appeals(agency = 'UFF', year = 2015, search = 'curso')
  df9 <- appeals(agency = 'UFF', year = 2015, search = 'curso', answer = T)
  df10 <- appeals(agency = 'UFF', year = c(2015, 2016), search = 'curso', answer = T)

  # tests

  test_that("able to download the full database", {
    expect_gt(nrow(df), 84739)
  })

  test_that("test argument year for only one year", {
    expect_equal(nrow(df2), 11735)
  })

  test_that("test argument year multiple years", {
    expect_equal(nrow(df3), 25754)
  })

  test_that("test the search argument with one word", {
    expect_gt(nrow(df4), 106)
  })

  test_that("test the search argument with more than one word", {
    expect_gt(nrow(df5), 51)
  })

  test_that("test the search and answer arguments", {
    expect_gt(nrow(df6), 1289)
  })

  test_that("test the arguments agency and year", {
    expect_equal(nrow(df7), 15)
  })

  test_that("test the arguments agency, year and search", {
    expect_equal(nrow(df8), 1)
  })

  test_that("test the arguments agency, year, answer and search", {
    expect_equal(nrow(df9), 1)
  })

  test_that("test the arguments agency, year, answer and search", {
    expect_equal(nrow(df10), 5)
  })
} else { # partial test
  df10 <- appeals(agency = 'UFF', year = c(2015, 2016), search = 'curso', answer = T)
  test_that("test the arguments agency, year, answer and search", {
    expect_equal(nrow(df10), 5)
  })
  }


