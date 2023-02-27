glif_db <- connect_with_db(config::get("glif_db",
                                       file = system.file(package = "glif", "database", "database-config.yml")))

onStop(function() {
  pool::poolClose(glif_db)
})
