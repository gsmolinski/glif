glif_db <- connect_with_db(config::get("glif_db",
                                       file = system.file(package = "glif", "database", "database-config.yml")))

onStop(function() {
  pool::poolClose(glif_db)
})

observe({
  invalidateLater(1000 * 59)
  pool::dbExecute(glif_db, "DELETE FROM markers WHERE expires <= $1", params = list(as.double(Sys.time())))
})

observe({
  invalidateLater(1000 * 60 * 60 * 23)
  pool::dbExecute(glif_db, "DELETE FROM maps WHERE expires <= $1", params = list(as.double(Sys.time())))
})
