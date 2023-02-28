#' Connect With Database
#'
#' Connect based on config file. Currently works
#' with postgresql through RPostgres package.
#'
#' @param config_db config file (returned by config::get).
#'
#' @return
#' Database connection object if connected with success,
#' otherwise NULL.
#' @noRd
connect_with_db <- function(config_db) {
  tryCatch(pool::dbPool(RPostgres::Postgres(),
                          dbname = config_db$dbname,
                          host = config_db$host,
                          port = config_db$port,
                          user = config_db$user,
                          password = config_db$password),
           error = function(e) NULL)
}

get_map_id <- function(glif_db_conn, code) {
  glif_db_conn |>
    dplyr::tbl("maps") |>
    dplyr::filter(map_code == code) |>
    dplyr::collect() |>
    dplyr::pull(id)
}

get_layer_id_code <- function(glif_db_conn, id_map, code, with_edit_privileges) {
  glif_db_conn |>
    dplyr::tbl("layers") |>
    dplyr::filter(map_id == id_map & layer_code == code) |>
    dplyr::select(layer_id, layer_code) |>
    dplyr::collect() |>
    dplyr::bind_cols(dplyr::tibble(edit_privileges = with_edit_privileges))
}

get_markers <- function(glif_db_conn, id_map, layer_ids) {
  glif_db_conn |>
    dplyr::tbl("markers") |>
    dplyr::filter(map_id == id_map & layer_id %in% layer_ids) |>
    dplyr::select(latitude, longitude, marker_description) |>
    dplyr::collect()
}
