#' Launch the foundation shade gap explorer
#'
#' Opens an interactive Shiny app that helps beauty product strategy
#' managers compare a brand's foundation shade range with the market,
#' find the lightness bands where the brand is thinner than the market,
#' and see which competitor products lead those bands.
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