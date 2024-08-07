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

#' Add or Remove One Participant For All Given Layers
#'
#' @param glif_db_conn connection to database.
#' @param layer_ids ids of layers to which user belongs.
#'
#' @return
#' Used for side effect - updated number
#' of participants belongs to layer if
#' user disconnect from the app (so remove
#' number of participants then) or joins the
#' layer (so add number of participants then).
#' @details
#' Number of participants is used to sort the cards
#' in architect tab.
#' @noRd
update_participation_layers <- function(glif_db_conn, action = c("add", "remove"), layer_ids) {
  if (action == "add") {
    pool::dbExecute(glif_db_conn,
                    "UPDATE layers SET layer_participants = layer_participants + 1 WHERE id IN ($1)",
                    params = list(layer_ids))
  } else if (action == "remove") {
    pool::dbExecute(glif_db_conn,
                    "UPDATE layers SET layer_participants = layer_participants - 1 WHERE id IN ($1)",
                    params = list(layer_ids))
  }
}

#' Insert Newly Created Map Into Database
#'
#' @param glif_db_conn connection to database.
#' @param map_code map code (name)
#'
#' @return
#' Used for side effect - inserts row to database.
#' @details
#' Sys.time() converted to double returns value in seconds.
#' @noRd
insert_data_into_maps <- function(glif_db_conn, map_code) {
  pool::dbExecute(glif_db_conn,
                  "INSERT INTO maps (map_code, expires) VALUES ($1, $2)",
                  params = list(map_code, as.double(Sys.time() + 60 * 60 * 24 * 7)))
}

#' Insert Newly Created Layer Into Database
#'
#' @param glif_db_conn connection to database.
#' @param map_id id of map (id taken from database).
#' @param layer_code layer code (name).
#' @param layer_description information about layer for
#' other users.
#' @param layer_edit_code cod needed to know if user
#' may have edit privileges.
#' @param layer_participants number of participants to add
#' to layer. Usually 1, but when the map is created and we make
#' "main layer", then 2, to easier sort later (we want main
#' layer to be at the top of all layers).
#'
#' @return
#' Used for side effect - inserts row into database.
#' @noRd
insert_data_into_layers <- function(glif_db_conn, map_id, layer_code, layer_description, layer_edit_code, layer_participants = 1) {
  pool::dbExecute(glif_db_conn,
                  "INSERT INTO layers (map_id, layer_code, layer_description, layer_edit_code, layer_participants)
                   VALUES ($1, $2, $3, $4, $5)",
                  params = list(map_id, layer_code, layer_description, layer_edit_code, layer_participants))
}

#' Insert Newly Created Marker Into Database
#'
#' @param glif_db_conn connection to database.
#' @param map_id id of map (taken from database)
#' @param layer_id layer data.frame from session object (taken from database)
#' @param latitude latitute coord
#' @param longitude longitude coord
#' @param marker_description description to show after
#' clicked on marker
#' @param expires after which time the marker should be
#' removed from map? Specified in minutes.
#'
#' @return
#' Used for side effect - inserts row into database, table
#' "markers".
#' @details
#' Sys.time() converted to double returns value in seconds.
#' @noRd
insert_data_into_markers <- function(glif_db_conn, map_id, layer_id, latitude, longitude,
                                     marker_description, expires) {

  layers_edit_privileges <- layer_id$id[layer_id$edit_privileges]
  length_layer_ids <- length(layers_edit_privileges)

  pool::dbExecute(glif_db_conn,
                  "INSERT INTO markers (map_id, layer_id, latitude, longitude, marker_description, expires)
                  VALUES ($1, $2, $3, $4, $5, $6)",
                  params = list(rep(map_id, length_layer_ids), layers_edit_privileges, rep(latitude, length_layer_ids),
                                rep(longitude, length_layer_ids), rep(marker_description, length_layer_ids),
                                rep(as.double(Sys.time() + 60 * expires), length_layer_ids)))
}

#' Retrieve All Layers For Given Map
#'
#' Needed to display all layer for map
#' for the user.
#'
#' @param glif_db_conn connection to database.
#' @param id_map map id saved in `session$userData$map`.
#' @param edit_privileges data.frame with columns: layer id and
#' info if user has edit privileges for id (for layer).
#'
#' @return
#' Tibble with columns specified in `select` + column
#' `edit_privileges` - logical TRUE / FALSE if user
#' has edit privileges for given layer as well as column
#' indicated if user already belongs to the layer.
#' @noRd
get_all_layers <- function(glif_db_conn, id_map, edit_privileges) {
  edit_privileges$belongs <- TRUE

  glif_db_conn |>
    dplyr::tbl("layers") |>
    dplyr::filter(map_id == id_map) |>
    dplyr::select(layer_id = id, layer_code, layer_description, layer_edit_code, layer_participants) |>
    dplyr::collect() |>
    dplyr::left_join(edit_privileges, by = c("layer_id" = "id")) |>
    dplyr::mutate(dplyr::across(c(edit_privileges, belongs), ~ dplyr::if_else(is.na(.x), FALSE, .x))) |>
    dplyr::arrange(dplyr::desc(layer_participants == max(layer_participants)), dplyr::desc(edit_privileges), dplyr::desc(belongs), dplyr::desc(layer_participants))
}

#' Refresh Data By Retrieving Most Up To Date Data From Database
#'
#' @param glif_db_conn connection to database.
#' @param session_user_data object `session$userData` - environment.
#' @param map_code map code (name).
#' @param layer_code layer code (name).
#' @param with_edit_privileges logical. Does user have edit
#' privileges for layer into which she / he joined?
#' @param map logical. If TRUE, data for map will be refreshed.
#' @param layer logical. If TRUE, data for layer will be refreshed.
#' @param marker logical. If TRUE, data for marker will be refreshed.
#' @param append logical. Should rows be append or not? Applicable
#' only for layers and markers (both at the same time).
#'
#' @return
#' Used for side effect - function binds new data
#' to `session` object (`userData` element), but because
#' this object is an environment, we don't need to return
#' anything (values are passed by reference).
#' @details
#' In this was decided to use `session` object (specifically:
#' element `userData`) to store information about to which
#' map user belongs, to which layers and so which markers user
#' should see on map.
#' @noRd
refresh_data <- function(glif_db_conn, session_user_data, map_code = NULL, layer_code = NULL,
                         with_edit_privileges = NULL, map = FALSE, layer = FALSE, marker = FALSE,
                         append = FALSE) {

  if (map) {
    session_user_data$map <- get_map_id(glif_db_conn, map_code)
  }

  if (layer) {
    if (append) {
      session_user_data$layer <- dplyr::bind_rows(session_user_data$layer,
                                                  get_layer_id_code(glif_db_conn, session_user_data$map$id,
                                                                    layer_code, with_edit_privileges))
    } else {
      session_user_data$layer <- get_layer_id_code(glif_db_conn, session_user_data$map$id,
                                                   layer_code, with_edit_privileges)
    }
  }

  if (marker) {
    if (append) { # we do not use this append = TRUE for markers currently, but leave it for future
      session_user_data$marker <- dplyr::bind_rows(session_user_data$marker,
                                                   get_markers(glif_db_conn, session_user_data$map$id,
                                                               session_user_data$layer$id))
    } else {
      session_user_data$marker <- get_markers(glif_db_conn, session_user_data$map$id,
                                              session_user_data$layer$id)
    }
  }
}

#' Get Map ID From Database
#'
#' It assumes table name is "maps".
#'
#' @param glif_db_conn connection to database.
#' @param code code_map (i.e. map name.)
#'
#' @return
#' Tibble (columns - see select function).
#' @noRd
get_map_id <- function(glif_db_conn, code) {
  glif_db_conn |>
    dplyr::tbl("maps") |>
    dplyr::filter(map_code == code) |>
    dplyr::select(id, map_code) |>
    dplyr::collect()
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
#' Tibble.
#' @noRd
get_layer_id_code <- function(glif_db_conn, id_map, code, with_edit_privileges) {
  glif_db_conn |>
    dplyr::tbl("layers") |>
    dplyr::filter(map_id == id_map & layer_code == code) |>
    dplyr::select(map_id, id, layer_code, layer_edit_code) |>
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
#' description of marker and layer id.
#' @noRd
get_markers <- function(glif_db_conn, id_map, layer_ids) {
  glif_db_conn |>
    dplyr::tbl("markers") |>
    dplyr::filter(map_id == id_map & layer_id %in% layer_ids) |>
    dplyr::select(layer_id, latitude, longitude, marker_description) |>
    dplyr::collect()
}
