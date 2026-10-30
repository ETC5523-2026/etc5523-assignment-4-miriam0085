#' Launch the foundation shade supply explorer
#'
#' Opens an interactive Shiny app that helps beauty product strategists
#' explore how crowded each part of the foundation lightness range is,
#' and which brands compete there.
#'
#' @return Called for its side effect of launching the app.
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#' @export
run_app <- function() {
  app_dir <- system.file("app", package = "shaderange")
  if (app_dir == "") {
    stop("Could not find the app. Try reinstalling `shaderange`.",
         call. = FALSE)
  }
  shiny::runApp(app_dir, display.mode = "normal")
}