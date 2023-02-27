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
