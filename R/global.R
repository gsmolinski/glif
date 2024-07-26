global <- quote({
  config_db <- config::get("glif_db",
                           file = system.file(package = "glif",
                                              "database", "database-config.yml"))
  glif_db <- pool::dbPool(RPostgres::Postgres(),
                          dbname = config_db$dbname,
                          host = config_db$host,
                          port = config_db$port,
                          user = config_db$user,
                          password = config_db$password)

  shiny::onStop(function() {
    pool::poolClose(glif_db)
  })

  shiny::observe({
    shiny::invalidateLater(1000 * 59)
    pool::dbExecute(glif_db,
                    "DELETE FROM markers WHERE expires <= $1",
                    params = list(as.double(Sys.time())))
  })

  shiny::observe({
    shiny::invalidateLater(1000 * 60 * 60 * 23)
    pool::dbExecute(glif_db,
                    "DELETE FROM maps WHERE expires <= $1",
                    params = list(as.double(Sys.time())))
  })
})
