#' Launch the foundation shade gap explorer
#'
#' Opens an interactive Shiny app that helps beauty product strategy
#' managers compare a brand's foundation shades with the market. The app
#' shows where the brand offers a smaller share of deep, medium or light
#' shades than the market, and which competitor products lead either the
#' brand's weakest band or the band the whole market supplies least.
#'
#' @return Called for its side effect of launching the app.
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#' @importFrom bslib bs_theme
#' @importFrom ggplot2 ggplot
#' @export
run_app <- function() {
  app_dir <- system.file("app", package = "shaderange")
  if (app_dir == "") {
    stop("Could not find the app. Try reinstalling `shaderange`.",
         call. = FALSE)
  }
  shiny::runApp(app_dir, display.mode = "normal")
}