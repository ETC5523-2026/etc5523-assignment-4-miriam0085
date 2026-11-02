#' Compare a brand's shade mix with the market
#'
#' Splits shades into deep, medium and light bands and compares the share
#' of a brand's shades in each band with the share across the whole
#' market. Negative gaps show bands where the brand offers proportionally
#' fewer shades than the market.
#'
#' @param shades A data frame with columns `brand`, `product` and
#'   `lightness`, such as [foundation_shades]. This is treated as the
#'   market.
#' @param brand A single brand name, matching a value in `shades$brand`.
#' @inheritParams shade_supply
#' @return A data frame with one row per band and columns:
#'   \describe{
#'     \item{band}{Lightness band}
#'     \item{brand_shades}{Number of the brand's shades in the band}
#'     \item{brand_share}{Share of the brand's shades in the band}
#'     \item{market_share}{Share of all market shades in the band}
#'     \item{gap}{`brand_share` minus `market_share`; negative values
#'       mark under-represented bands}
#'   }
#' @examples
#' brand_gaps(foundation_shades, brand = "L'Oréal")
#' # Negative gaps show where L'Oréal offers proportionally fewer shades
#' # than the market
#'
#' brand_gaps(foundation_shades, brand = "FENTY BEAUTY by Rihanna")
#' # Compare with a brand known for an inclusive shade range
#' @importFrom dplyr tibble
#' @export
brand_gaps <- function(shades, brand, breaks = c(0.45, 0.70)) {
  # Check the brand before doing any work
  if (!is.character(brand) || length(brand) != 1) {
    stop("`brand` must be a single brand name.", call. = FALSE)
  }
  if (!brand %in% shades$brand) {
    stop("Brand \"", brand, "\" was not found in `shades`.", call. = FALSE)
  }

  # Summarise the brand and the whole market with the same band definition
  brand_supply <- shade_supply(shades[shades$brand == brand, ], breaks)
  market_supply <- shade_supply(shades, breaks)

  tibble(
    band = market_supply$band,
    brand_shades = brand_supply$n_shades,
    brand_share = brand_supply$share,
    market_share = market_supply$share,
    gap = brand_supply$share - market_supply$share
  )
}