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
mod_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    leafletOutput(ns("main_map"), height = "100%"),
    tags$div(class = "fab fab-right-bottom",
             tags$a(id = ns("pin_btn"), type = "button", class = "f7-action-button fab_map_layers_btns fab_pin_btn",
                    tags$i(class = "icon f7-icons", "map_pin_ellipse"))
    ),
    tags$div(class = "fab fab-right-bottom",
             tags$a(id = ns("geolocation_btn"), type = "button", class = "f7-action-button fab_map_layers_btns fab_geolocation_btn",
                    tags$i(class = "icon f7-icons", "compass_fill"))
             )
  )
}

#' map Server Functions
#' @import shiny
#' @import leaflet
#' @noRd
mod_map_server <- function(id, toggle_theme, geolocation_lat, geolocation_lng) {
  moduleServer( id, function(input, output, session) {
    ns <- session$ns
    leaflet_proxy <- leafletProxy(ns("main_map"))

    output$main_map <- renderLeaflet({
      leaflet(options = leafletOptions(zoomControl = FALSE)) |>
        addProviderTiles(providers$CartoDB.DarkMatter,
                         options = providerTileOptions(minZoom = 6))
    })

    observe({
      dark_requested <- (toggle_theme() %% 2) == 0

      if (dark_requested) {
        leaflet_proxy |>
          clearTiles() |>
          addProviderTiles(providers$CartoDB.DarkMatter,
                           options = providerTileOptions(minZoom = 6))
      } else {
        leaflet_proxy |>
          clearTiles() |>
          addProviderTiles(providers$CartoDB.Voyager,
                           options = providerTileOptions(minZoom = 6))
      }
    }) |>
      bindEvent(toggle_theme())

    observe({
      session$sendCustomMessage("get_geolocation", "placeholder")
    }) |>
      bindEvent(input$geolocation_btn)

    observe({
      session$sendCustomMessage("get_geolocation", "placeholder")
    }) |>
      bindEvent(input$pin_btn)

    observe({
      req(geolocation_lat(), geolocation_lng())

      leaflet_proxy |>
        removeMarker("user_location") |>
        setView(geolocation_lat(), geolocation_lng(), zoom = 18) |>
        addCircleMarkers(geolocation_lat(), geolocation_lng(),
                         layerId = "user_location")
      # because we want to center view even if lat and lng didn't change;
      # it doesn't work with bindEvent, probably because this is too fast
      # then and req(geolocation()) returns false? I.e. geolocation
      # do not work when first clicked after launching the app.
      input$geolocation_btn
    })

    observe({
      req(geolocation_lat(), geolocation_lng())


    }) |>
      bindEvent(input$pin_btn)

  })
}

