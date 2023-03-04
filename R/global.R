glif_db <- connect_with_db(config::get("glif_db",
                                       file = system.file(package = "glif",
                                                          "database", "database-config.yml")))

onStop(function() {
  pool::poolClose(glif_db)
})

observe({
  invalidateLater(1000 * 59)
  delete_expired(glif_db, "markers")
})

observe({
  invalidateLater(1000 * 60 * 60 * 23)
  delete_expired(glif_db, "maps")
})
