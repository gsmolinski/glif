test_that("connect_with_database returns connection if can connect
          and given tables exist", {
  config_db <- config::get("glif_db", file = system.file(package = "glif", "database", "database-config.yml"))
  glif_db <- connect_with_db(config_db)
  expect_type(glif_db, type = "environment")
  expect_equal(length(DBI::dbListTables(glif_db)), 5)
  expect_true(all(c("maps", "layers", "markers") %in% DBI::dbListTables(glif_db)))
})
