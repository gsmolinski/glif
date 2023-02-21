#' map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
mod_map_ui <- function(id){
  ns <- NS(id)
  tagList(

  )
}

#' map Server Functions
#' @import shiny
#' @noRd
mod_map_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

  })
}

