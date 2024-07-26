#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

  onStop(function() {
    # when app crashes, i.e. when we stop app on server, then this results to error,
    # because connection has been already closed (and this function can't be executed). As a result
    # we do not update number of participants in this case.
    try(update_participation_layers(glif_db, "remove", session$userData$layer$id), silent = TRUE)
  })

  observe({
    session$sendCustomMessage("change_nav_text", input$glif_tabs)
    session$sendCustomMessage("show_hide_fab_btns", input$glif_tabs)
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

  mod_layers_server("glif_layers",
                    glif_db = glif_db,
                    inside_map = reactive({input$is_inside_map}),
                    reload_btn = reactive({input$reload_btn}),
                    add_btn = reactive({input$add_btn}),
                    changed_card_input = reactive({input$changed_card_input}),
                    end_vh_reached = reactive({input$end_vh_reached}))
}
