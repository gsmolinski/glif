#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinyMobile
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Application UI logic
    f7Page(
      f7TabLayout(
        navbar = f7Navbar(tags$span(tags$span("glif", class = "glif-name-nav", id = "glif_name_nav_id"), tags$span("stands for visibility", class = "glif-desc-nav", id = "glif_desc_nav_id"), class = "glif-nav")),
        f7Tabs(id = "glif_tabs",
          f7Tab(tabName = "map_tab", icon = icon("map")),
          f7Tab(tabName = "architect_tab", icon = icon("layer-group"))
        )
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "glif"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
