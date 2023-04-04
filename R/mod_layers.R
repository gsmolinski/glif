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
#' @param reload_btn reload_btn and add_btn needs to be
#' outside this mod, because otherwise they do not behave
#' like FAB buttons (position is not fixed).
#' @param add_btn see above.
#' @param changed_card_input indicated if and which button
#' from footer in any card has been pushed by user.
#' @param end_vh_reached used for infinite scrolling, indicates
#' the end of visible height area.
#'
#' @noRd
#' @import shiny
mod_layers_server <- function(id, glif_db, inside_map, reload_btn, add_btn, changed_card_input, end_vh_reached) {
  moduleServer( id, function(input, output, session) {
    ns <- session$ns

    layers_all <- reactiveVal()
    cards_all <- reactiveVal()
    cards_boundaries <- reactiveValues(start_from = 0,
                                       last_index = Inf)

    observe({
      reload_btn()
      req(inside_map())
      layers_all(get_all_layers(glif_db, session$userData$map, session$userData$layer[c("id", "edit_privileges")]))
    })

    observe({
      req(layers_all())
      ids <- lapply(layers_all()$layer_code, generate_ids, ns = ns)
      removeUI(paste0("#", ns("layers_cards_div")))
      insertUI(paste0("#", ns("layers_cards_row")),
               where = "afterBegin",
               ui = tags$div(id = ns("layers_cards_div")))

      session$sendCustomMessage("get_changed_card_input", unlist(ids, use.names = FALSE))
      cards_boundaries$last_index <- nrow(layers_all())
      cards_boundaries$start_from <- 0
      cards_all(mapply(make_card,
                       title = layers_all()$layer_code,
                       ids = ids,
                       content = layers_all()$layer_description,
                       edit_privileges = layers_all()$edit_privileges,
                       belongs = layers_all()$belongs,
                       participants = layers_all()$layer_participants,
                       MoreArgs = list(max_participants = max(layers_all()$layer_participants),
                                       ns = ns),
                       SIMPLIFY = FALSE,
                       USE.NAMES = FALSE))
    })

    observe({
      req(cards_all())
      from <- cards_boundaries$start_from + 1
      req(from <= cards_boundaries$last_index)
      to <- if (from + 5 > cards_boundaries$last_index) cards_boundaries$last_index else from + 5
      lapply(cards_all()[from:to], insert_card, ns = ns)
      cards_boundaries$start_from <- to
    }) |>
      bindEvent(end_vh_reached())

    observe({
      req(input$layers_join_text)
      req(layers_all())
      if (input$layers_join_text %in% layers_all()$layer_code) {
        update_participation_layers(glif_db, "add", session_user_data$layer$id[session_user_data$layer$layer_code == input$layers_join_text])
        refresh_data(glif_db, session$userData, layer_code = input$layers_join_text, with_edit_privileges = FALSE,
                     layer = TRUE, append = TRUE)
        layers_all(get_all_layers(glif_db, session$userData$map, session$userData$layer[c("id", "edit_privileges")]))
      } else {
        wrong_code_alert("Code (name) doesn't exist")
      }
    }) |>
      bindEvent(input$layers_join_btn)

    observe({
      # for technical reasons (see JS code), `changed_card_input` returns character vector length 1,
      # but we need only first element
      input_info <- determine_input(changed_card_input()[[1]], ns(""))
      switch(input_info$type,
             copyedit = layer_copy_edit(input_info$card_code, session$userData, session),
             leaveeee = layer_leave(input_info$card_code, session$userData, glif_db, layers_all),
             addeditt = display_modal_dialog(ns("add_edit_code"), "Edit code"),
             joinnnnn = layer_join(input_info$card_code, session$userData, glif_db, layers_all)
             )
    }) |>
      bindEvent(changed_card_input())

    observe({
      input_info <- determine_input(changed_card_input()[[1]], ns(""))
      layer_add_edit(input_info$card_code, session$userData, ns, glif_db, layers_all, input)
    }) |>
      bindEvent(input$add_edit_code)

    observe({
      req(layers_all())
      display_modal_dialog(ns("add_layer_code"), "Code (Name)")
    }) |>
      bindEvent(add_btn())

    observe({
      if (!any(input$add_layer_code == layers_all()$layer_code)) {
        display_modal_dialog(ns("add_layer_description"), "Description")
      } else {
        wrong_code_alert("Code already exists")
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
  # strange names, because later we want to use
  # substr() easy with the same number of characters
  # after `_`.
  c(copyedit = ns(paste0(title, "_copyedit")),
    leave = ns(paste0(title, "_leaveeee")),
    addedit = ns(paste0(title, "_addeditt")),
    join = ns(paste0(title, "_joinnnnn")))
}

#' Make Card
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
#' HTML element.
#' @noRd
#' @import shinyMobile
#' @import shiny
make_card <- function(title, ids, content, edit_privileges, belongs, participants, max_participants, ns) {
  if (participants == max_participants) {
    card_class <- "card_main"
  } else if (edit_privileges) {
    card_class <- "card_edit"
  } else if (belongs) {
    card_class <- "card_belong"
  } else {
    card_class <- "card_rest"
  }

  addedit_span_class <- "show_glif"
  copyedit_span_class <- "show_glif"
  join_span_class <- "show_glif"
  leave_span_class <- "show_glif"

  if (belongs) {
    footer_first_col_class <- "show_glif"
    card_footer_row_class <- "card_footer_row_two_items"
    join_span_class <- "hide_glif"
    if (edit_privileges) {
      addedit_span_class <- "hide_glif"
    } else {
      copyedit_span_class <- "hide_glif"
    }
  } else {
    footer_first_col_class <- "hide_glif"
    card_footer_row_class <- "card_footer_row_one_item"
    leave_span_class <- "hide_glif"
  }

  tagList(
    tags$div(id = ns(title),
             f7Card(class = card_class,
                    title = tags$span(title, class = "card_title"),
                    tags$div(content, class = "card_content_text"),
                    tags$br(),
                    tags$div(tags$span("Participants: "), tags$span(participants, id = paste0(ns(title), "_participants_number")), class = "card_participants"),
                    footer = tagList(
                      f7Row(class = card_footer_row_class,
                            f7Col(id = paste0(ns(title), "_footerfirstcolid"), class = footer_first_col_class,
                                  tags$span(f7Button(ids[["addedit"]], label = "Add edit"), id = paste0(ns(title), "_span_addedit"), class = addedit_span_class),
                                  tags$span(f7Button(ids[["copyedit"]], label = "Copy edit"), id = paste0(ns(title), "_span_copyedit"), class = copyedit_span_class)
                            ),
                            f7Col(
                                  tags$span(f7Button(ids[["join"]], label = "Join"), id = paste0(ns(title), "_span_join"), class = join_span_class),
                                  tags$span(f7Button(ids[["leave"]], label = "Leave"), id = paste0(ns(title), "_span_leave"), class = leave_span_class)
                            )
                      )
                    ))
    )
  )
}

#' Insert Card
#'
#' @param card card from `make_card`.
#' @param ns from `shiny`.
#'
#' @return
#' Used for side effect - inserts
#' HTML element to specific place.
#' @noRd
#' @import shiny
insert_card <- function(card, ns) {
  insertUI(paste0("#", ns("layers_cards_div")),
           where = "beforeEnd",
           ui = card)
}

#' Determine Input Name and Input Type
#'
#' @param input_id input id.
#' @param namespace namespace for module.
#'
#' @return
#' List with two elements - first element is a
#' card id (id without namespace and added info about type),
#' second element is a type of button.
#' @noRd
determine_input <- function(input_id, namespace) {
  list(
    card_code = gsub(paste0("^", namespace, "|_[a-z]+$"), "", input_id, perl = TRUE),
    type = substr(input_id, nchar(input_id) - 8 + 1, nchar(input_id))
  )
}

#' Copy Edit Code to Clipboard
#'
#' @param card_code card title.
#' @param session_user_data `session$userData` environment.
#' @param session session from `shiny`.
#'
#' @return
#' Used for side effect - copies edit code for given card
#' to the clipboard.
#' @import shiny
#' @import shinyMobile
#' @noRd
layer_copy_edit <- function(card_code, session_user_data, session) {
  card_data <- session_user_data$layer |>
                dplyr::filter(map_id == session_user_data$map,
                              session_user_data$layer$layer_code == card_code)
    req(card_data$edit_privileges) # should be TRUE, but let's check this anyway
    session$sendCustomMessage("copy_edit_code", card_data$layer_edit_code)
    f7Toast("Copied", closeButton = FALSE,
            icon = f7Icon("checkmark_alt_circle_fill"),
            closeTimeout = 1000)
}

#' Leave Layer (Card)
#'
#' @param card_code card title.
#' @param session_user_data `session$userData` environment.
#' @param glif_db connection to database.
#' @param layers_all reactiveVal to update.
#'
#' @return
#' Used for side effect - user leaves the layer.
#' @noRd
layer_leave <- function(card_code, session_user_data, glif_db, layers_all) {
  update_participation_layers(glif_db, "remove", session_user_data$layer$id[session_user_data$layer$layer_code == card_code])
  session_user_data$layer <- session_user_data$layer |>
    dplyr::filter(!layer_code == card_code)
  layers_all(get_all_layers(glif_db, session_user_data$map, session_user_data$layer[c("id", "edit_privileges")]))
}

#' Add Edit Privileges to Given Layer (Card)
#'
#' @param card_code card title.
#' @param session_user_data `session$userData` environment.
#' @param ns from `shiny`.
#' @param glif_db connection to database.
#' @param layers_all reactiveVal to update.
#' @param input from `shiny`.
#'
#' @return
#' Used for side effects - adds edit privileges
#' for the user for chosen layer.
#' @noRd
layer_add_edit <- function(card_code, session_user_data, ns, glif_db, layers_all, input) {
  req(input$add_edit_code)
  if (session_user_data$layer$layer_edit_code[session_user_data$layer$layer_code == card_code] == input$add_edit_code) {
    session_user_data$layer$edit_privileges[session_user_data$layer$layer_code == card_code] <- TRUE
    layers_all(get_all_layers(glif_db, session_user_data$map, session_user_data$layer[c("id", "edit_privileges")]))
  } else {
    wrong_code_alert("Wrong edit code")
  }
}

#' Join to Layer (Card)
#'
#' @param card_code card title.
#' @param session_user_data `session$userData` environment.
#' @param glif_db connection to database.
#' @param layers_all reactiveVal to update.
#'
#' @return
#' Used for side effect - user joins to the layer.
#' @noRd
layer_join <- function(card_code, session_user_data, glif_db, layers_all) {
  update_participation_layers(glif_db, "add", session_user_data$layer$id[session_user_data$layer$layer_code == card_code])
  refresh_data(glif_db, session_user_data, layer_code = card_code, with_edit_privileges = FALSE,
               layer = TRUE, append = TRUE)
  layers_all(get_all_layers(glif_db, session_user_data$map, session_user_data$layer[c("id", "edit_privileges")]))
}
