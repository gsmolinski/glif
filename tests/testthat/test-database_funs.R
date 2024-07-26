config_db <- config::get("glif_db", file = system.file(package = "glif", "database", "database-config.yml"))
glif_db <- pool::dbPool(RPostgres::Postgres(),
                        dbname = config_db$dbname,
                        host = config_db$host,
                        port = config_db$port,
                        user = config_db$user,
                        password = config_db$password)

test_that("connect_with_database returns connection if can connect
          and given tables exist", {
  expect_type(glif_db, "environment")
  expect_length(pool::dbListTables(glif_db), 5)
  expect_true(all(c("maps", "layers", "markers") %in% pool::dbListTables(glif_db)))
})

test_that("get_map_id returns integer(0) if map doesn't exist", {
  id <- get_map_id(glif_db, uuid::UUIDgenerate())$id
  expect_type(id, "integer")
  expect_length(id, 0)
})

test_that("refresh_data returns data of correct structure", {
  env_obj <- environment()
  uuid <- uuid::UUIDgenerate()

  insert_data_into_maps(glif_db, uuid)
  refresh_data(glif_db, env_obj, map_code = uuid, map = TRUE)
  expect_type(env_obj$map$id, "integer")
  expect_length(env_obj$map$id, 1)

  insert_data_into_layers(glif_db, env_obj$map$id, "test", "test", "test", 1)
  refresh_data(glif_db, env_obj, layer_code = "test", with_edit_privileges = TRUE, layer = TRUE)
  expect_s3_class(env_obj$layer, "data.frame")
  expect_length(env_obj$layer, 5)
  expect_identical(names(env_obj$layer), c("map_id", "id", "layer_code", "layer_edit_code", "edit_privileges"))
  refresh_data(glif_db, env_obj, layer_code = "test", with_edit_privileges = TRUE, layer = TRUE, append = TRUE)
  expect_true(nrow(env_obj$layer) == 2)

  insert_data_into_markers(glif_db, env_obj$map$id, env_obj$layer[1, ], 1, 2, "test", 10)
  refresh_data(glif_db, env_obj, marker = TRUE)
  expect_s3_class(env_obj$marker, "data.frame")
  expect_length(env_obj$marker, 4)
  expect_identical(names(env_obj$marker), c("layer_id", "latitude", "longitude", "marker_description"))

  pool::dbExecute(glif_db, "DELETE FROM maps WHERE map_code = $1", params = list(uuid))
})

pool::poolClose(glif_db)
