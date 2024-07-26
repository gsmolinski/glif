globalVariables(c("glif_db", "map_id", "id", "layer_code", "layer_description", "layer_edit_code",
                  "layer_participants", "belongs", "map_code", "layer_id", "latitude", "longitude",
                  "marker_description", "layer_code"))

#' Function to Use 'dbplyr' Object
#'
#' This is needed as workaround for warning
#' during cmd check that dbplyr not found.
#' And also as a workaround that no call found,
#' so shouldn't be in import field.
#'
#' @return
#' do not use this function.
#' @noRd
not_run <- function() {
  dbplyr::as.sql
}
