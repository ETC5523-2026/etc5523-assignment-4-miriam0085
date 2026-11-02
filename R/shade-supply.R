#' Summarise foundation shade supply by lightness band
#'
#' Splits foundation shades into deep, medium and light bands using
#' lightness cut-offs. For each band, it counts the shades and distinct
#' products, their share of all shades, and the average number of shades
#' per product offering the band. Use it to see where shade supply is thin.
#'
#' @param shades A data frame with columns `brand`, `product` and
#'   `lightness`, such as [foundation_shades].
#' @param breaks Two increasing numbers between 0 and 1 giving the
#'   lightness cut-offs between deep and medium, and between medium and
#'   light.
#' @return A data frame with one row per band (`Deep`, `Medium`, `Light`)
#'   and columns:
#'   \describe{
#'     \item{band}{Lightness band}
#'     \item{n_shades}{Number of shades in the band}
#'     \item{n_products}{Number of distinct products offering at least
#'       one shade in the band}
#'     \item{share}{Proportion of all shades that fall in the band}
#'     \item{shades_per_product}{Average number of shades per product
#'       offering the band; `NA` when no product offers it}
#'   }
#'   Bands with no shades are kept with zero counts.
#' @examples
#' shade_supply(foundation_shades)
#' # Deep shades are a small share of supply, and products offering them
#' # tend to offer fewer deep options
#'
#' shade_supply(foundation_shades, breaks = c(0.40, 0.75))
#' # Check whether the conclusion holds under a different band definition
#' @importFrom dplyr group_by if_else mutate n n_distinct summarise
#' @export
shade_supply <- function(shades, breaks = c(0.45, 0.70)) {
  # Validate the cut-offs before doing any work
  if (!is.numeric(breaks) || length(breaks) != 2 ||
      any(breaks <= 0 | breaks >= 1) || breaks[1] >= breaks[2]) {
    stop("`breaks` must be two increasing numbers between 0 and 1.",
         call. = FALSE)
  }

  shades |>
    mutate(
      band = cut(
        lightness,
        breaks = c(0, breaks, 1),
        labels = c("Deep", "Medium", "Light"),
        include.lowest = TRUE
      )
    ) |>
    # .drop = FALSE keeps empty bands so gaps show up as zeros
    group_by(band, .drop = FALSE) |>
    summarise(
      n_shades = n(),
      n_products = n_distinct(brand, product),
      .groups = "drop"
    ) |>
    mutate(
      share = n_shades / sum(n_shades),
      shades_per_product = if_else(
        n_products > 0, n_shades / n_products, NA_real_
      )
    )
}