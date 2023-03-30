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
    f7Row(
      f7Col(id = "col_remove_class_1", class = "col-60", f7Text(ns("layers_join_text"), label = NULL, placeholder = "Code (name)")),
      f7Col(id = "col_remove_class_2", class = "col-30", tags$div(class = "list",
        tags$div(
          tags$div(
            f7Button(ns("layers_join_btn"), label = "JOIN"))
          )
        )
      )
    ),
    tags$br(),
    tags$div(id = ns("layers_cards_row"),
             tags$div(id = ns("layers_cards_div"))
             ),
    tags$span(id = "end_vh")
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
mod_layers_server <- function(id, glif_db, inside_map, reload_btn, add_btn, changed_card_input) {
  moduleServer( id, function(input, output, session) {
    ns <- session$ns

    layers_all <- reactiveVal()

    observe({
      layers_all(get_all_layers(glif_db, session$userData$map, session$userData$layer[c("id", "edit_privileges")]))
    }) |>
      bindEvent(reload_btn())

    observe({
      req(inside_map())
      layers_all(get_all_layers(glif_db, session$userData$map, session$userData$layer[c("id", "edit_privileges")]))
      ids <- lapply(layers_all()$layer_code, generate_ids, ns = ns)
      removeUI(paste0("#", ns("layers_cards_div")))
      insertUI(paste0("#", ns("layers_cards_row")),
               where = "afterBegin",
               ui = tags$div(id = ns("layers_cards_div")))

      session$sendCustomMessage("get_changed_card_input", unlist(ids, use.names = FALSE))
      mapply(insert_card,
             title = layers_all()$layer_code,
             ids = ids,
             content = layers_all()$layer_description,
             edit_privileges = layers_all()$edit_privileges,
             belongs = layers_all()$belongs,
             participants = layers_all()$layer_participants,
             MoreArgs = list(max_participants = max(layers_all()$layer_participants),
                             ns = ns),
             SIMPLIFY = FALSE,
             USE.NAMES = FALSE)
    })

    observe({
      req(input$layers_join_text)
      req(layers_all())
      if (input$layers_join_text %in% layers_all()$layer_code) {
        refresh_data(glif_db, session$userData, layer_code = input$layers_join_text, with_edit_privileges = FALSE,
                     layer = TRUE, append = TRUE)
        layers_all(get_all_layers(glif_db, session$userData$map, session$userData$layer[c("id", "edit_privileges")]))
      } else {
        wrong_code_alert("Code (name) doesn't exist.")
      }
    }) |>
      bindEvent(input$layers_join_btn)

    observe({
      print(changed_card_input())
    }) |>
      bindEvent(changed_card_input())

    observe({
      req(layers_all())
      display_modal_dialog(ns("add_layer_code"), "Code (Name)")
    }) |>
      bindEvent(add_btn())

    observe({
      if (!any(input$add_layer_code == layers_all()$layer_code)) {
        display_modal_dialog(ns("add_layer_description"), "Description")
      } else {
        wrong_code_alert("Code already exists.")
      }
    }) |>
      bindEvent(input$add_layer_code)

    observe({
      insert_data_into_layers(glif_db, session$userData$map,
                              input$add_layer_code, input$add_layer_description, uuid::UUIDgenerate())
      refresh_data(glif_db, session$userData, layer_code = input$add_layer_code, with_edit_privileges = TRUE,
                   layer = TRUE, append = TRUE)
      layers_all(get_all_layers(glif_db, session$userData$map, session$userData$layer[c("id", "edit_privileges")]))
    }) |>
      bindEvent(input$add_layer_description)

  })
}

#' Generate Ids For Cards.
#'
#' @param title card title which will work as id.
#' @param ns - ns from `shiny`.
#'
#' @return
#' Character vector with all possible Ids for a card.
#' @noRd
generate_ids <- function(title, ns) {
  c(showedit = ns(paste0(title, "_showedit")),
    leave = ns(paste0(title, "_leave")),
    addedit = ns(paste0(title, "_addedit")),
    join = ns(paste0(title, "_join")))
}

#' Make and Insert Card
#'
#' @param title card title.
#' @param content card content.
#' @param edit_privileges logical - has user edit privileges?
#' @param belongs logical - does used belong to layer already?
#' @param ids ids to use for input.
#' @param participants number of participants in card.
#' @param max_participants biggest number of participants through all cards.
#' @param ns - ns from `shiny`.
#'
#' @return
#' Used for side effect - inserts card to UI.
#' @noRd
#' @import shinyMobile
insert_card <- function(title, ids, content, edit_privileges, belongs, participants, max_participants, ns) {
  if (participants == max_participants) {
    card_class <- "card_main"
  } else if (edit_privileges) {
    card_class <- "card_edit"
  } else if (belongs) {
    card_class <- "card_belong"
  } else {
    card_class <- "card_rest"
  }

  card <- tagList(
    tags$div(id = ns(title),
             f7Card(class = card_class,
                    title = tags$span(title, class = "card_title"),
                    tags$div(content, class = "card_content_text"),
                    tags$br(),
                    tags$div(glue::glue("Other participants: {participants}"), class = "card_participants"),
                    footer = tagList(
                      f7Row(class = "card_footer_row",
                            f7Col(class = "footer_first_col_class", # should be variable
                                  tags$span(f7Button(ids[["addedit"]], label = "Add edit")),
                                  tags$span(f7Button(ids[["showedit"]], label = "Show edit"))
                            ),
                            f7Col(
                              tags$span(f7Button(ids[["join"]], label = "Join")),
                              tags$span(f7Button(ids[["leave"]], label = "Leave"))
                            )
                      )
                    ))
    )
  )

  insertUI(paste0("#", ns("layers_cards_div")),
           where = "beforeEnd",
           ui = card)
}
