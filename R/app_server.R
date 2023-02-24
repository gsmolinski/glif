#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  glif_db <- connect_with_db(config::get("glif_db",
                                         file = system.file(package = "glif", "database", "database-config.yml")))

  onStop(function() {
    DBI::dbDisconnect(glif_db)
  })

  observe({
    session$sendCustomMessage("change_nav_text", input$glif_tabs)
  })

  observe({
    dark_requested <- (input$toggle_theme %% 2) != 0
    session$sendCustomMessage("change_theme", dark_requested)
  }) |>
    bindEvent(input$toggle_theme)

  mod_map_server("glif_map",
                 toggle_theme = reactive({input$toggle_theme}),
                 geolocation = reactive({input$geolocation}),
                 geolocation_lat = reactive({input$geolocation_lat}),
                 geolocation_lng = reactive({input$geolocation_lng}))
}
