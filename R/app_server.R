#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  onStop(function() {
    update_participation_layers(glif_db, "remove", session$userData$layer$id)
  })

  observe({
    session$sendCustomMessage("change_nav_text", input$glif_tabs)
  })

  observe({
    dark_requested <- (input$toggle_theme %% 2) != 0
    session$sendCustomMessage("change_theme", dark_requested)
  }) |>
    bindEvent(input$toggle_theme)

  mod_join_create_server("map_tab_join_create",
                         glif_db = glif_db)

  mod_join_create_server("architect_tab_join_create",
                         glif_db = glif_db)

  mod_map_server("glif_map",
                 toggle_theme = reactive({input$toggle_theme}),
                 geolocation_lat = reactive({input$geolocation_lat}),
                 geolocation_lng = reactive({input$geolocation_lng}))
}
