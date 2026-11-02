
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shaderange

<!-- badges: start -->

<!-- badges: end -->

The shaderange package helps beauty product strategy managers find
opportunities for their next foundation launch. It compares a brand’s
foundation shades with the whole market across two major US beauty
retailers, Sephora and Ulta, showing where the brand offers a smaller
share of deep, medium or light shades than the market. Based on the
result, it also points to the competitor products worth benchmarking
against.

The package contains:

- `foundation_shades`: 6,774 foundation shades from 107 brands,
  collected from the Sephora and Ulta websites in early 2021
- `shade_supply()`: summarises shade supply by lightness band
- `brand_gaps()`: compares a brand’s shade mix with the market
- `run_app()`: launches an interactive Shiny app for exploring brand
  gaps

Documentation website:
<https://etc5523-2026.github.io/etc5523-assignment-4-miriam0085/>

## Installation

Install the package from GitHub with:

``` r
# install.packages("remotes")
remotes::install_github("ETC5523-2026/etc5523-assignment-4-miriam0085")
```

## Launch the app

``` r
library(shaderange)
run_app()
```

Choose your brand and retailer in the sidebar. The app shows where your
brand’s shade mix is thinner than the market and which competitor
products lead those bands.

## Example

Compare a brand’s shade mix with the market:

``` r
library(shaderange)
brand_gaps(foundation_shades, brand = "L'Oréal")
#> # A tibble: 3 × 5
#>   band   brand_shades brand_share market_share     gap
#>   <fct>         <int>       <dbl>        <dbl>   <dbl>
#> 1 Deep             29       0.190        0.160  0.0297
#> 2 Medium           72       0.471        0.457  0.0138
#> 3 Light            52       0.340        0.383 -0.0435
```

A negative `gap` marks a band where the brand offers proportionally
fewer shades than the market.

## Data

The shade data come from The Pudding’s article [The Naked
Truth](https://pudding.cool/2021/03/foundation-names/) (2021), released
under the MIT licence and accessed via
[TidyTuesday](https://github.com/rfordatascience/tidytuesday/tree/main/data/2021/2021-03-30).
The script data-raw/foundation_shades.R downloads the raw data from
TidyTuesday, removes duplicate shades and saves the cleaned result as
foundation_shades.

## AI declaration

Generative AI declaration: I used Claude to guide me through the R
package development workflow, explain concepts, help debug code errors,
and suggest wording and styling for the app and documentation.
