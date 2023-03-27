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
mod_layers_ui <- function(id) {
  ns <- NS(id)
  tagList(
    uiOutput(ns("cards")),
    tags$div(class = "fab fab-right-bottom",
             tags$a(id = ns("add_btn"), type = "button", class = "f7-action-button fab_map_layers_btns fab_add_btn",
                    tags$i(class = "icon f7-icons", "plus_circle_fill"))
    ),
    tags$div(class = "fab fab-right-bottom",
             tags$a(id = ns("reload_btn"), type = "button", class = "f7-action-button fab_map_layers_btns fab_reload_btn",
                    tags$i(class = "icon f7-icons", "arrow_2_circlepath_circle_fill"))
    )
  )
}

#' layers Server Functions
#'
#' @param id module id
#' @param glif_db connection to database
#' @param inside_map reactive logical vector
#' length 1 indicating if user is already inside map.
#'
#' @noRd
#' @import shiny
mod_layers_server <- function(id, glif_db, inside_map) {
  moduleServer( id, function(input, output, session) {
    ns <- session$ns

    layers_user <- reactiveVal(session$userData$layer)

    layers_all <- reactiveVal()

    observe({
      layers_all(get_all_layers(glif_db, session$userData$map, session$userData$layer[c("id", "edit_privileges")]))
    }) |>
      bindEvent(input$reload_btn)

    output$cards <- renderUI({
      req(inside_map())
      layers_all(get_all_layers(glif_db, session$userData$map, session$userData$layer[c("id", "edit_privileges")]))
      mapply(make_cards,
             title = layers_all()$layer_code,
             content = layers_all()$layer_description,
             edit_privileges = layers_all()$edit_privileges,
             belongs = layers_all()$belongs,
             MoreArgs = list(ns = ns))
    })

    observe({


      layers_all() # to complete - at the end, add new layer, should refrsh automatically
    }) |>
      bindEvent(input$add_btn)

  })
}

#' Make Card
#'
#' @param title card title.
#' @param content card content.
#' @param edit_privileges logical - has user edit privileges?
#' @param belongs logical - does used belong to layer already?
#' @param ns - ns from `shiny`,
#'
#' @return
#' HTML element.
#' @noRd
#' @import shinyMobile
make_cards <- function(title, content, edit_privileges, belongs, ns) {
  if (edit_privileges) {
    tagList(
      f7Card(title = title,
             content,
             footer = tagList(
               f7Row(class = "card_footer_row",
                 f7Col(
                   f7Button(ns(paste0(title, "_edit_check")), label = "Edit code")
                 ),
                 f7Col(
                   f7Button(ns(paste0(title, "_leave")), label = "Leave")
                 )
               )
             ))
           )
  } else {
    tagList(
      f7Card(title = title,
             content,
             footer = tagList(
               f7Row(class = "card_footer_row",
                 f7Col(
                   f7Button(ns(paste0(title, "_edit_join")), label = "Edit code")
                 ),
                 f7Col(
                   if (belongs) f7Button(ns(paste0(title, "_leave")), label = "Leave") else f7Button(ns(paste0(title, "_join")), label = "Join")
                 )
               )
             ))
           )
  }
}
