#' layers UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
#' @import shinyMobile
mod_layers_ui <- function(id){
  ns <- NS(id)
  tagList(
    tags$div(class = "fab fab-right-bottom",
             tags$a(id = ns("add_btn"), type = "button", class = "f7-action-button fab_map_layers_btns fab_add_btn",
                    tags$i(class = "icon f7-icons", "plus_circle_fill"))
    ),
    tags$div(class = "fab fab-right-bottom",
             tags$a(id = ns("reload_btn"), type = "button", class = "f7-action-button fab_map_layers_btns fab_reload_btn",
                    tags$i(class = "icon f7-icons", "eye_fill"))
    )
  )
}

#' layers Server Functions
#'
#' @noRd
mod_layers_server <- function(id, glif_db){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    layers_user <- reactiveVal(session$userData$layer)

    layers_all <- reactive({
                    get_all_layers(glif_db, session$userData$map)
                  }) |>
                    bindEvent(input$reload_btn)

    observe({

    }) |>
      bindEvent(input$add_btn)

  })
}
