config_db <- config::get("glif_db", file = system.file(package = "glif", "database", "database-config.yml"))
glif_db <- connect_with_db(config_db)

test_that("connect_with_database returns connection if can connect
          and given tables exist", {
  expect_type(glif_db, "environment")
  expect_length(DBI::dbListTables(glif_db), 5)
  expect_true(all(c("maps", "layers", "markers") %in% DBI::dbListTables(glif_db)))
})

test_that("get_map_id returns integer(0) if map doesn't exist", {
  id <- get_map_id(glif_db, "non_existing_code_hopefully_2023_03_04")
  expect_type(id, "integer")
  expect_length(id, 0)
})
