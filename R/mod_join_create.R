#' join_create UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
mod_join_create_ui <- function(id){
  ns <- NS(id)
  tagList(

  )
}

#' join_create Server Functions
#'
#' @noRd
mod_join_create_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  })
}

