# Find gaps in a foundation shade range

## Who this guide is for

This guide is for beauty product strategy managers planning their next
foundation launch. It shows how to use shaderange to find where that
launch has the most room to make a difference, by answering one
question: where is our foundation shade range thinner than the market?

## Install the package

Install shaderange from GitHub:

``` r

# install.packages("remotes")
remotes::install_github("ETC5523-2026/etc5523-assignment-4-miriam0085")
```

## Launch the app

Load the package and launch the app:

``` r

library(shaderange)
run_app()
```

The app opens in your browser or in the viewer of your coding
environment.

## Use the app

The sidebar has three controls:

- **Your brand** sets the brand you are planning for. Every output
  updates to compare that brand with the market.
- **Retailer** limits the market to Sephora, Ulta or both, so you can
  see whether a gap differs by channel.
- **Shade bands** sets where deep ends and light begins, on a lightness
  scale from 0 (deepest) to 1 (lightest). The defaults are 0.45 and
  0.70. Moving them shows whether a gap still holds under a different
  definition.

## Read the results

The bold sentence at the top summarises your brand’s current position:
where its largest gap is, or whether its shade mix matches the market.
Below it, the app shows three outputs.

**Your brand vs the market.** The beige area shows how all market shades
spread across lightness, and the rose line shows your brand. Where the
line dips below the area, your range is thinner than the market.

**Share of shades by band.** Yours and Market show the percentage of
shades in each band, and Gap is the difference between them in
percentage points. A band 5 or more points below the market counts as a
meaningful gap and is highlighted in rose.

**Catch-up priority or market opportunity.** If your brand has a
meaningful gap, this table lists the competitor products with the most
shades in that band, showing the range you would need to match. If your
shade mix matches the market, it lists the leaders in the band the whole
market supplies least, where you could stand out.

## The same analysis in R

The app is built on two functions you can also use directly.

``` r

library(shaderange)
```

### The market as a whole

[`shade_supply()`](https://etc5523-2026.github.io/etc5523-assignment-4-miriam0085/reference/shade_supply.md)
summarises how many shades and products fall in each band:

``` r

shade_supply(foundation_shades)
#> # A tibble: 3 × 5
#>   band   n_shades n_products share shades_per_product
#>   <fct>     <int>      <int> <dbl>              <dbl>
#> 1 Deep       1083        221 0.160               4.90
#> 2 Medium     3094        310 0.457               9.98
#> 3 Light      2597        302 0.383               8.60
```

Deep shades make up the smallest share of supply, and products that
offer them provide fewer deep options on average. This is the
market-wide gap the app refers to as a market opportunity.

### A brand with a gap

[`brand_gaps()`](https://etc5523-2026.github.io/etc5523-assignment-4-miriam0085/reference/brand_gaps.md)
compares one brand with the market:

``` r

brand_gaps(foundation_shades, brand = "florence by mills")
#> # A tibble: 3 × 5
#>   band   brand_shades brand_share market_share     gap
#>   <fct>         <int>       <dbl>        <dbl>   <dbl>
#> 1 Deep              1      0.0667        0.160 -0.0932
#> 2 Medium           12      0.8           0.457  0.343 
#> 3 Light             2      0.133         0.383 -0.250
```

florence by mills offers a much smaller share of light shades than the
market, so its catch-up priority is light shades.

### A brand that matches the market

``` r

brand_gaps(foundation_shades, brand = "L'Oréal")
#> # A tibble: 3 × 5
#>   band   brand_shades brand_share market_share     gap
#>   <fct>         <int>       <dbl>        <dbl>   <dbl>
#> 1 Deep             29       0.190        0.160  0.0297
#> 2 Medium           72       0.471        0.457  0.0138
#> 3 Light            52       0.340        0.383 -0.0435
```

No band for L’Oréal is 5 or more points below the market. Its mix
mirrors the market, so it also shares the market’s thin spot in deep
shades, which is where the app points to as an opportunity.

## Limitations

The data show which shades are offered, not which ones sell, and every
product counts equally. A thin band may reflect low demand or unmet
demand, so treat gaps as leads for further research rather than launch
decisions. The data are a snapshot from early 2021, so brands may have
added or removed shades since, and the results describe the market at
that time rather than today. The band cut-offs and 5-point threshold are
analytical choices rather than standards.
