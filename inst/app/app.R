library(shiny)
library(bslib)
library(shaderange)

# ---- Setup ----
brand_choices <- sort(unique(foundation_shades$brand))

app_theme <- bs_theme(
  version = 5,
  bg = "#F7F4EF", fg = "#1F1D1B", primary = "#8A4B32",
  base_font = font_google("Inter"),
  heading_font = font_google("Cormorant Garamond"),
  "border-radius" = "2px"
)

# Assign each shade to a band, using the same labels as shade_supply()
band_of <- function(lightness, breaks) {
  cut(lightness, breaks = c(0, breaks, 1),
      labels = c("Deep", "Medium", "Light"), include.lowest = TRUE)
}

# ---- UI ----
ui <- page_sidebar(
  title = "Foundation shade supply",
  theme = app_theme,
  sidebar = sidebar(
    width = 300,
    selectInput("brand", "Your brand",
                choices = brand_choices, selected = "L'Oréal"),
    checkboxGroupInput("retailer", "Retailer",
                       choices = c("Sephora", "Ulta"),
                       selected = c("Sephora", "Ulta")),
    sliderInput("breaks", "Lightness cut-offs (deep | medium | light)",
                min = 0.20, max = 0.90, value = c(0.45, 0.70), step = 0.01)
  ),
  layout_columns(
    value_box(title = "Your shades", value = textOutput("n_shades")),
    value_box(title = "Your products", value = textOutput("n_products")),
    value_box(title = "Largest gap", value = textOutput("largest_gap"))
  ),
  card(
    card_header("Your brand vs the market"),
    plotOutput("compare_plot", height = "280px")
  ),
  layout_columns(
    card(card_header("Share of shades by band"),
         tableOutput("gap_table")),
    card(card_header("Benchmark products in your largest gap"),
         tableOutput("benchmark_table"))
  )
)

# ---- Server ----
server <- function(input, output, session) {

  # The market after the retailer filter
  market <- reactive({
    foundation_shades |>
      dplyr::filter(retailer %in% input$retailer)
  })

   # Is there anything to compare under the current selection?
  has_data <- reactive({
    length(input$retailer) > 0 && input$brand %in% market()$brand
  })

  # The selected brand's shades within that market
  brand_shades <- reactive({
    validate(
      need(length(input$retailer) > 0,
           "Select at least one retailer to see results.")
    )
    validate(
      need(input$brand %in% market()$brand,
           paste0(input$brand, " has no shades at the selected retailer. ",
                  "Tick the other retailer or choose another brand."))
    )
    market() |>
      dplyr::filter(brand == input$brand)
  })

  # Brand vs market comparison, from the package function
  gaps <- reactive({
    brand_shades()  # run the checks above before comparing
    brand_gaps(market(), brand = input$brand, breaks = input$breaks)
  })

  # The band where the brand falls furthest below the market
  worst <- reactive({
    g <- gaps()
    g[which.min(g$gap), ]
  })

    output$n_shades <- renderText({
    if (!has_data()) return("–")
    nrow(brand_shades())
  })

  output$n_products <- renderText({
    if (!has_data()) return("–")
    dplyr::n_distinct(brand_shades()$product)
  })

  output$largest_gap <- renderText({
    if (!has_data()) return("–")
    w <- worst()
    paste0(w$band, " (", sprintf("%+.0f", w$gap * 100), " pts)")
  })

  output$compare_plot <- renderPlot({
    brand_data <- brand_shades()  # run the checks before building the plot
    plot_data <- rbind(
      data.frame(group = "Market", lightness = market()$lightness),
      data.frame(group = "Your brand", lightness = brand_data$lightness)
    )
    ggplot2::ggplot(plot_data,
                    ggplot2::aes(lightness, colour = group)) +
      ggplot2::geom_density(linewidth = 1) +
      ggplot2::geom_vline(xintercept = input$breaks,
                          linetype = "dashed", colour = "#7A7066") +
      ggplot2::scale_colour_manual(
        values = c("Market" = "#B9AFA4", "Your brand" = "#8A4B32")
      ) +
      ggplot2::labs(x = "Lightness (0 = black, 1 = white)",
                    y = "Share of shades (density)", colour = NULL) +
      ggplot2::theme_minimal(base_size = 13) +
      ggplot2::theme(legend.position = "top")
  })

  output$gap_table <- renderTable({
    g <- gaps()
    data.frame(
      Band = g$band,
      `Your shades` = g$brand_shades,
      `Your share` = sprintf("%.0f%%", g$brand_share * 100),
      `Market share` = sprintf("%.0f%%", g$market_share * 100),
      `Gap (pts)` = sprintf("%+.1f", g$gap * 100),
      check.names = FALSE
    )
  })

  output$benchmark_table <- renderTable({
    market() |>
      dplyr::filter(brand != input$brand) |>
      dplyr::mutate(band = band_of(lightness, input$breaks)) |>
      dplyr::filter(band == worst()$band) |>
      dplyr::count(brand, product, name = "Shades in band", sort = TRUE) |>
      head(5) |>
      dplyr::rename(Brand = brand, Product = product)
  })
}

shinyApp(ui, server)