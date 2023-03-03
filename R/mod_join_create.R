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
      map_id <- get_map_id(glif_db, input$code_for_map_join)
      if (length(map_id) == 1) {
        session$userData$map <- map_id
        session$sendCustomMessage("inside_map", TRUE)
        session$userData$layer <- get_layer_id_code(glif_db, map_id, input$code_for_map_join, FALSE)
      } else {
        wrong_code_alert("Map doesn't exist.")
      }
    }) |>
      bindEvent(input$code_for_map_join)

    observe({
      req(input$code_for_map_create)
      map_id <- get_map_id(glif_db, input$code_for_map_create)
      if (length(map_id) == 0) {
        edit_code <- uuid::UUIDgenerate()
        pool::dbExecute(glif_db,
                        "INSERT INTO maps (map_code, expires) VALUES ($1, $2)",
                        params = list(input$code_for_map_create, as.double(Sys.time() + 60 * 60 * 24 * 7)))
        session$userData$map <- get_map_id(glif_db, input$code_for_map_create)

        pool::dbExecute(glif_db,
                        "INSERT INTO layers (map_id, layer_code, layer_description, layer_edit_code, layer_participants)
                        VALUES ($1, $2, $3, $4, $5)",
                        params = list(session$userData$map, input$code_for_map_create, "Main markers", edit_code, 1 + 1)) # add extra 1 participants to sort to the top later in cards list
        session$userData$layer <- get_layer_id_code(glif_db, session$userData$map, input$code_for_map_create, TRUE)

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
