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
#'
#' @param id module id.
#' @param toggle_theme reactive - number
#' changes when user clicks the button
#' responsible to change theme.
#' @param geolocation_lat reactive with geolocation lat.
#' @param geolocation_lng reactive with geolocation long.
#'
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
      req(geolocation_lng(), geolocation_lat())

      leaflet_proxy |>
        removeMarker("user_location") |>
        setView(geolocation_lng(), geolocation_lat(), zoom = 18) |>
        addCircleMarkers(geolocation_lng(), geolocation_lat(),
                         layerId = "user_location")
      # because we want to center view even if lat and lng didn't change;
      # it doesn't work with bindEvent, probably because this is too fast
      # then and req(geolocation()) returns false? I.e. geolocation
      # do not work when first clicked after launching the app.
      input$geolocation_btn
    })

    observe({
      session$sendCustomMessage("get_geolocation", "placeholder")
      display_modal_dialog(ns("marker_desc"), "Marker Description")
    }) |>
      bindEvent(input$pin_btn)

    observe({
      display_modal_dialog(ns("expires_after"), "Expires After (minutes)")
    }) |>
      bindEvent(input$marker_desc)

    observe({
      expires <- as.double(input$expires_after)
      req(expires)
      if (isTruthy(geolocation_lng()) & isTruthy(geolocation_lat())) {
          insert_data_into_markers(glif_db, session$userData$map$id, session$userData$layer$id,
                                   geolocation_lat(), geolocation_lng(), input$marker_desc, expires)
      } else {
        wrong_code_alert("Can't find map coordinates")
      }

    }) |>
      bindEvent(input$expires_after)

  })
}

