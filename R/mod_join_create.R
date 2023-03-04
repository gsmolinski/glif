#' join_create UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
#' @import shinyMobile
mod_join_create_ui <- function(id){
  ns <- NS(id)
  tagList(
    f7Row(class = "join_create_row",
      f7Col(f7Button(ns("join"), "JOIN", fill = FALSE)),
      f7Col(tags$div("/", class = "join_create_slash"), class = "join_create_slash_col"),
      f7Col(f7Button(ns("create"), "CREATE", fill = FALSE))
    )
  )
}

#' join_create Server Functions
#'
#' @noRd
#' @import shiny
mod_join_create_server <- function(id, glif_db){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    observe({
      ask_for_map_code(ns("code_for_map_join"))
    }) |>
      bindEvent(input$join)

    observe({
      ask_for_map_code(ns("code_for_map_create"))
    }) |>
      bindEvent(input$create)

    observe({
      req(input$code_for_map_join)
      refresh_data(glif_db, session$userData, map_code = input$code_for_map_join, map = TRUE)
      if (length(session$userData$map) == 1) {
        refresh_data(glif_db, session$userData, layer_code = input$code_for_map_join, with_edit_privileges = FALSE, layer = TRUE)
        update_participation_layers(glif_db, "add", session$userData$layer$id[session$userData$layer$layer_code == input$code_for_map_join])
        session$sendCustomMessage("inside_map", TRUE)
      } else {
        wrong_code_alert("Map doesn't exist.")
      }
    }) |>
      bindEvent(input$code_for_map_join)

    observe({
      req(input$code_for_map_create)
      refresh_data(glif_db, session$userData, map_code = input$code_for_map_create, map = TRUE)
      if (length(session$userData$map) == 0) {
        insert_data_into_maps(glif_db, input$code_for_map_create)
        refresh_data(glif_db, session$userData, map_code = input$code_for_map_create, map = TRUE)
        insert_data_into_layers(glif_db, session$userData$map, input$code_for_map_create, "Main markers", uuid::UUIDgenerate())
        refresh_data(glif_db, session$userData, layer_code = input$code_for_map_create, with_edit_privileges = TRUE, layer = TRUE)
        session$sendCustomMessage("inside_map", TRUE)
        session$sendCustomMessage("edit_privileges", TRUE)
      } else {
        wrong_code_alert("Map already exists.")
      }
    }) |>
      bindEvent(input$code_for_map_create)

  })
}


ask_for_map_code <- function(id) {
  f7Dialog(id, "Map Code (Name)", text = "", type = "prompt")
}

wrong_code_alert <- function(text) {
  f7Toast(text, closeButton = FALSE, icon = f7Icon("exclamationmark_circle_fill"))
}
