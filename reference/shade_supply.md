# Summarise foundation shade supply by lightness band

Splits foundation shades into deep, medium and light bands using
lightness cut-offs. For each band, it counts the shades and distinct
products, their share of all shades, and the average number of shades
per product offering the band. Use it to see where shade supply is thin.

## Usage

``` r
shade_supply(shades, breaks = c(0.45, 0.7))
```

## Arguments

- shades:

  A data frame with columns `brand`, `product` and `lightness`, such as
  [foundation_shades](https://etc5523-2026.github.io/etc5523-assignment-4-miriam0085/reference/foundation_shades.md).

- breaks:

  Two increasing numbers between 0 and 1 giving the lightness cut-offs
  between deep and medium, and between medium and light.

## Value

A data frame with one row per band (`Deep`, `Medium`, `Light`) and
columns:

- band:

  Lightness band

- n_shades:

  Number of shades in the band

- n_products:

  Number of distinct products offering at least one shade in the band

- share:

  Proportion of all shades that fall in the band

- shades_per_product:

  Average number of shades per product offering the band; `NA` when no
  product offers it

Bands with no shades are kept with zero counts.

## Examples

``` r
shade_supply(foundation_shades)
#> # A tibble: 3 × 5
#>   band   n_shades n_products share shades_per_product
#>   <fct>     <int>      <int> <dbl>              <dbl>
#> 1 Deep       1083        221 0.160               4.90
#> 2 Medium     3094        310 0.457               9.98
#> 3 Light      2597        302 0.383               8.60
# Deep shades are a small share of supply, and products offering them
# tend to offer fewer deep options

shade_supply(foundation_shades, breaks = c(0.40, 0.75))
#> # A tibble: 3 × 5
#>   band   n_shades n_products share shades_per_product
#>   <fct>     <int>      <int> <dbl>              <dbl>
#> 1 Deep        735        188 0.109               3.91
#> 2 Medium     4226        315 0.624              13.4 
#> 3 Light      1813        286 0.268               6.34
# Check whether the conclusion holds under a different band definition
```
