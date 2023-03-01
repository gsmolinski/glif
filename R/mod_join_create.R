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
mod_join_create_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  })
}

