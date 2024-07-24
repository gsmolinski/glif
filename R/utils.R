#' Show Modal Dialog
#'
#' @param id id for modal.
#' @param title title for modal.
#'
#' @return
#' Side effect - shows modal dialog.
#' @noRd
#' @import shinyMobile
display_modal_dialog <- function(id, title) {
  f7Dialog(id, title, text = "", type = "prompt")
}

#' Show Alert
#'
#' @param text text to display in alert.
#'
#' @return
#' Side effect - shows modal dialog.
#' @noRd
#' @import shiny
wrong_code_alert <- function(text) {
  showNotification(text, duration = 2)
}
