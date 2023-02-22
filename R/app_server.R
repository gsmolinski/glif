#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  observe({
    session$sendCustomMessage("change_nav_text", input$glif_tabs)
  })

  dark_requested <- reactive({
    (input$toggle_theme %% 2) != 0
  }) |>
    bindEvent(input$toggle_theme)

  observe({
    session$sendCustomMessage("change_theme", dark_requested())
  }) |>
    bindEvent(dark_requested())

  mod_map_server("glif_map")
}
