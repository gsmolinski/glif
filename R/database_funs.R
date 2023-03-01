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
  pool::dbPool(RPostgres::Postgres(),
                          dbname = config_db$dbname,
                          host = config_db$host,
                          port = config_db$port,
                          user = config_db$user,
                          password = config_db$password)
}

#' Get Map ID From Database
#'
#' It assumes table name is "maps".
#'
#' @param glif_db_conn connection to database.
#' @param code code_map (i.e. map name.)
#'
#' @return
#' Integer length 1.
#' @noRd
get_map_id <- function(glif_db_conn, code) {
  glif_db_conn |>
    dplyr::tbl("maps") |>
    dplyr::filter(map_code == code) |>
    dplyr::collect() |>
    dplyr::pull(id)
}

#' Get Layer ID And Layer Code (Name)
#'
#' It assumes table name is "layers".
#'
#' @param glif_db_conn database connection.
#' @param id_map id map returned by `get_map_id`.
#' @param code name of layer.
#' @param with_edit_privileges logical vector length 1
#' indicating if user passed correct edit code for given layer.
#'
#' @return
#' Tibble with layer id, layer code (name)
#' and informaton if user has edit privileges
#' for given layer.
#' @noRd
get_layer_id_code <- function(glif_db_conn, id_map, code, with_edit_privileges) {
  glif_db_conn |>
    dplyr::tbl("layers") |>
    dplyr::filter(map_id == id_map & layer_code == code) |>
    dplyr::select(layer_id, layer_code) |>
    dplyr::collect() |>
    dplyr::mutate(edit_privileges = with_edit_privileges)
}

#' Get Marker Coordinates And Description
#'
#' It assumes table name is "markers".
#'
#' @param glif_db_conn database connection.
#' @param id_map id map returned by `get_map_id`.
#' @param layer_ids vector of integers with layers
#' id in which user participates.
#'
#' @return
#' Tibble with columns: lat, lng of marker as well as
#' description of marker.
#' @noRd
get_markers <- function(glif_db_conn, id_map, layer_ids) {
  glif_db_conn |>
    dplyr::tbl("markers") |>
    dplyr::filter(map_id == id_map & layer_id %in% layer_ids) |>
    dplyr::select(latitude, longitude, marker_description) |>
    dplyr::collect()
}
