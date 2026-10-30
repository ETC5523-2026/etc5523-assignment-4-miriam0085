## Prepare the foundation_shades dataset
## Source: The Pudding, "The Naked Truth" (2021), via TidyTuesday 2021-03-30
## Licence: MIT

shades_raw <- readr::read_csv(
  "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2021/2021-03-30/allShades.csv",
  show_col_types = FALSE
)

foundation_shades <- shades_raw |>
  dplyr::mutate(
    # Record which retailer each product was scraped from
    retailer = dplyr::if_else(
      stringr::str_detect(url, "ulta"), "Ulta", "Sephora"
    ),
    # Remove the "selected" flag left by web scraping before deduplicating
    shade = description |>
      stringr::str_remove("\\s*selected$") |>
      stringr::str_squish()
  ) |>
  # Drop shades scraped twice; match on shade description, not hex,
  # because distinct shades can share the same extracted hex code
  dplyr::distinct(brand, product, shade, .keep_all = TRUE) |>
  dplyr::select(brand, product, retailer, shade, hex, hue, sat, lightness) |>
  dplyr::arrange(brand, product, dplyr::desc(lightness))

usethis::use_data(foundation_shades, overwrite = TRUE)