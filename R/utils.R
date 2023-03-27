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
#' @import shinyMobile
wrong_code_alert <- function(text) {
  f7Toast(text, closeButton = FALSE, icon = f7Icon("exclamationmark_circle_fill"))
}
