test_that("connect_with_database returns connection or NULL if can't connect", {
  config_db <- config::get("glif_db", file = system.file(package = "glif", "database", "database-config.yml"))
  config_wrong <- config_db
  config_wrong$dbname <- "do not exists"
  glif_db <- connect_with_db(config_db)
  expect_null(connect_with_db(config_wrong))
  expect_s4_class(glif_db, class = "PqConnection")
  expect_equal(length(DBI::dbListTables(glif_db)), 5)
})
