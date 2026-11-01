# Foundation shades sold at Sephora and Ulta

Foundation shades scraped from the Sephora and Ulta websites, with the
colour of each shade's swatch summarised as HSL values. Each row is one
shade of one product.

## Usage

``` r
foundation_shades
```

## Format

A data frame with 6,774 rows and 8 columns:

- brand:

  Brand name

- product:

  Product name

- retailer:

  Retailer the product was collected from: `"Sephora"` or `"Ulta"`

- shade:

  Shade description as shown on the product page

- hex:

  Hexadecimal code of the most prevalent colour in the shade's swatch
  image

- hue:

  HSL hue, in degrees from 0 to 360

- sat:

  HSL saturation, from 0 to 1

- lightness:

  HSL lightness, from 0 (black) to 1 (white)

## Source

The Pudding, "The Naked Truth" (2021), by Ofunne Amaka and Amber Thomas,
<https://pudding.cool/2021/03/foundation-names/>. Data released under
the MIT licence at <https://github.com/the-pudding/data>, accessed via
TidyTuesday (2021-03-30),
<https://github.com/rfordatascience/tidytuesday/tree/main/data/2021/2021-03-30>.

## Details

The data were collected in early 2021 and reflect the products listed on
each retailer's website at that time. Colour values come from swatch
images rather than measured product colour, so they are approximate.
Shades listed twice within the same product were removed during
preparation; see `data-raw/foundation_shades.R`.

The data describe shade *supply* only. They contain no information on
sales, prices or the number of customers with each skin tone.
