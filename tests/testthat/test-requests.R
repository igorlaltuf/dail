# run the full test only in my personal machine

# full test
if (Sys.getenv('USERNAME') == 'igorl') {

  df <- requests() # able to download the full database
  df2 <- requests(year = 2018) # test argument year for only one year
  df3 <- requests(year = c(2018, 2019)) # test argument year multiple years
  df4 <- requests(search = 'ovni') # test the search argument with one word
  df5 <- requests(search = 'objeto voador') # test the search argument with more than one word
  df6 <- requests(search = 'covid', answer = T) # test the search and answer arguments
  df7 <- requests(agency = 'UFF', year = 2015) # test the arguments agency and year
  df8 <- requests(agency = 'UFF', year = 2015, search = 'curso') # test the arguments agency, year and search
  df9 <- requests(agency = 'UFF', year = 2015, search = 'curso', answer = T) # test the arguments agency, year, answer and search
  df10 <- requests(agency = 'UFF', year = c(2015, 2016), search = 'curso', answer = T) # test the arguments agency, year, answer and search

  # tests

  test_that("able to download the full database", {
    expect_gt(nrow(df), 670000)
  })

  test_that("test argument year for only one year", {
    expect_equal(nrow(df2), 91464)
  })

  test_that("test argument year multiple years", {
    expect_equal(nrow(df3), 187584)
  })

  test_that("test the search argument with one word", {
    expect_gt(nrow(df4), 84)
  })

  test_that("test the search argument with more than one word", {
    expect_gt(nrow(df5), 20)
  })

  test_that("test the search and answer arguments", {
    expect_gt(nrow(df6), 16455)
  })

  test_that("test the arguments agency and year", {
    expect_equal(nrow(df7), 229)
  })

  test_that("test the arguments agency, year and search", {
    expect_equal(nrow(df8), 43)
  })

  test_that("test the arguments agency, year, answer and search", {
    expect_equal(nrow(df9), 15)
  })

  test_that("test the arguments agency, year, answer and search", {
    expect_equal(nrow(df10), 37)
  })
} else { # partial test
  df10 <- requests(agency = 'UFF', year = c(2015, 2016), search = 'curso', answer = T) # test the arguments agency, year, answer and search
  test_that("test the arguments agency, year, answer and search", {
    expect_equal(nrow(df10), 37)
  })
}


