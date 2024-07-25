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
                    tags$i(class = "icon f7-icons", "compass"))
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
      refresh_data(glif_db, session$userData, marker = TRUE)
      if (is.null(session$userData$marker$longitude)) {
        session$userData$marker <- data.frame(layer_id = integer(0),
                                              latitude = integer(0),
                                              longitude = integer(0),
                                              marker_description = character(0))
      }

      leaflet_proxy |>
        removeMarker("user_location") |>
        clearGroup("layers") |>
        setView(geolocation_lng(), geolocation_lat(), zoom = 17) |>
        addCircleMarkers(geolocation_lng(), geolocation_lat(),
                         layerId = "user_location", color = "#47A4A9",
                         radius = 6, stroke = FALSE, fillOpacity = 0.5) |>
        addCircleMarkers(lng = session$userData$marker$longitude,
                         lat = session$userData$marker$latitude,
                         popup = htmltools::htmlEscape(session$userData$marker$marker_description),
                         group = "layers", color = "#A94C47", radius = 10, stroke = FALSE, fillOpacity = 0.5,
                         popupOptions = popupOptions(closeOnClick = TRUE))

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
          insert_data_into_markers(glif_db, session$userData$map$id, session$userData$layer,
                                   geolocation_lat(), geolocation_lng(), input$marker_desc, expires)
        session$sendCustomMessage("get_geolocation", "placeholder") # refresh
      } else {
        wrong_code_alert("Can't find map coordinates. Try again")
      }

    }) |>
      bindEvent(input$expires_after)

  })
}

