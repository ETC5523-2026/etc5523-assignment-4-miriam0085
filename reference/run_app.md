# Launch the foundation shade gap explorer

Opens an interactive Shiny app that helps beauty product strategy
managers compare a brand's foundation shades with the market. The app
shows where the brand offers a smaller share of deep, medium or light
shades than the market, and which competitor products lead either the
brand's weakest band or the band the whole market supplies least.

## Usage

``` r
run_app()
```

## Value

Called for its side effect of launching the app.

## Examples

``` r
if (interactive()) {
  run_app()
}
```
