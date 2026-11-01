# Compare a brand's shade mix with the market

Splits shades into deep, medium and light bands and compares the share
of a brand's shades in each band with the share across the whole market.
Negative gaps show bands where the brand offers proportionally fewer
shades than the market.

## Usage

``` r
brand_gaps(shades, brand, breaks = c(0.45, 0.7))
```

## Arguments

- shades:

  A data frame with columns `brand`, `product` and `lightness`, such as
  [foundation_shades](https://etc5523-2026.github.io/etc5523-assignment-4-miriam0085/reference/foundation_shades.md).
  This is treated as the market.

- brand:

  A single brand name, matching a value in `shades$brand`.

- breaks:

  Two increasing numbers between 0 and 1 giving the lightness cut-offs
  between deep and medium, and between medium and light.

## Value

A data frame with one row per band and columns:

- band:

  Lightness band

- brand_shades:

  Number of the brand's shades in the band

- brand_share:

  Share of the brand's shades in the band

- market_share:

  Share of all market shades in the band

- gap:

  `brand_share` minus `market_share`; negative values mark
  under-represented bands

## Examples

``` r
brand_gaps(foundation_shades, brand = "L'Oréal")
#> # A tibble: 3 × 5
#>   band   brand_shades brand_share market_share     gap
#>   <fct>         <int>       <dbl>        <dbl>   <dbl>
#> 1 Deep             29       0.190        0.160  0.0297
#> 2 Medium           72       0.471        0.457  0.0138
#> 3 Light            52       0.340        0.383 -0.0435
# Negative gaps show where L'Oréal's range is thinner than the market's

brand_gaps(foundation_shades, brand = "FENTY BEAUTY by Rihanna")
#> # A tibble: 3 × 5
#>   band   brand_shades brand_share market_share      gap
#>   <fct>         <int>       <dbl>        <dbl>    <dbl>
#> 1 Deep             22       0.147        0.160 -0.0132 
#> 2 Medium           69       0.46         0.457  0.00325
#> 3 Light            59       0.393        0.383  0.00996
# Compare with a brand known for an inclusive shade range
```
