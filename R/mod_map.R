#' map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
#' @import leaflet
mod_map_ui <- function(id){
  ns <- NS(id)
  tagList(
    leafletOutput(ns("main_map"), height = "100%"),
    tags$div(class = "fab fab-right-bottom",
             tags$a(id = ns("geolocation_btn"), type = "button", class = "f7-action-button fab_map_btns fab_geolocation_btn",
                    tags$i(class = "icon f7-icons", "location_fill"))
             ),
    tags$div(class = "fab fab-right-bottom",
             tags$a(id = ns("pin_btn"), type = "button", class = "f7-action-button fab_map_btns fab_pin_btn",
                    tags$i(class = "icon f7-icons", "map_pin"))
    )
  )
}

#' map Server Functions
#' @import shiny
#' @import leaflet
#' @noRd
mod_map_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    output$main_map <- renderLeaflet({
      leaflet(options = leafletOptions(zoomControl = FALSE)) |>
        addTiles()
    })

    observe({
      session$sendCustomMessage("get_geolocation", input$geolocation_btn)
    }) |>
      bindEvent(input$geolocation_btn)
  })
}

