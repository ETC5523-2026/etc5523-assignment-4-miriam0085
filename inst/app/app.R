library(shiny)
library(bslib)
library(shaderange)

# ---- Setup ----
brand_choices <- sort(unique(foundation_shades$brand))

# One sans-serif font for everything; serif only for the question
app_theme <- bs_theme(
  version = 5,
  bg = "#F7F4EF", fg = "#1F1D1B", primary = "#8A4B32",
  base_font = font_google("Inter", wght = c(400, 600)),
  heading_font = font_google("Inter", wght = c(400, 600)),
  font_scale = 0.9,
  "border-radius" = "4px"
)

# Custom styles, added directly to the page
app_css <- "
  .bslib-page-title, .navbar-brand { font-family: Inter, sans-serif;
                                     font-weight: 400; font-size: 1rem; }
  .question { font-family: 'Cormorant Garamond', Georgia, serif;
              font-size: 1.4rem; line-height: 1.25; margin-bottom: .5rem; }
  .takeaway { font-size: 1rem; font-weight: 600; margin-bottom: .25rem; }
  .caution  { color: #9A5B00; font-size: .85rem; }
  .stat-strip { display: flex; gap: 2rem; padding: .6rem 0;
                border-top: 1px solid #D8CFC4;
                border-bottom: 1px solid #D8CFC4; margin: .75rem 0 1rem; }
  .stat-label { color: #7A7066; font-size: .85rem; margin-right: .4rem; }
  .stat-value { font-weight: 600; font-variant-numeric: tabular-nums; }
  .card { background: #FFFDF9; border-color: #E4DBD0; }
  .bslib-card .card-header { background: transparent; border-bottom: none;
                             font-weight: 400 !important; font-size: .9rem;
                             color: #1F1D1B; }
  .table { font-variant-numeric: tabular-nums;
           --bs-table-bg: transparent;
           --bs-table-striped-bg: transparent; }
  .table > :not(caption) > * > * { background-color: transparent; }
  .table th { font-weight: 400; color: #7A7066; white-space: nowrap; }
"

# Assign each shade to a band, using the same labels as shade_supply()
band_of <- function(lightness, breaks) {
  cut(lightness, breaks = c(0, breaks, 1),
      labels = c("Deep", "Medium", "Light"), include.lowest = TRUE)
}

# Gaps smaller than this (in share) are not treated as meaningful
gap_threshold <- -0.05

# ---- UI ----
ui <- page_sidebar(
  title = "Foundation shade supply",
  theme = app_theme,
  fillable = FALSE,
    tags$head(
    tags$link(
      rel = "stylesheet",
      href = "https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@500&display=swap"
    ),
    tags$style(HTML(app_css))
  ),
  sidebar = sidebar(
    width = 280,
    selectInput("brand", "Your brand",
                choices = brand_choices, selected = "L'Oréal"),
    checkboxGroupInput("retailer", "Retailer",
                       choices = c("Sephora", "Ulta"),
                       selected = c("Sephora", "Ulta")),
    accordion(
      open = FALSE,
      accordion_panel(
        "Adjust shade bands",
        sliderInput("breaks", "Deep ends · Light begins",
                    min = 0.20, max = 0.90, value = c(0.45, 0.70),
                    step = 0.01),
        p(class = "small text-muted",
          "Shades darker than the left handle count as deep; lighter than ",
          "the right handle count as light. Move them to check whether a ",
          "gap still holds under a different definition.")
      )
    )
  ),

  # Who the app is for, the question, and the answer for this brand
  p(class = "text-muted small mb-1",
    "For product strategy managers planning their next foundation launch"),
  div(class = "question",
      "Where is our foundation shade range thinner than the market?"),
  uiOutput("takeaway"),

  # Supporting numbers in one slim row
  div(
    class = "stat-strip",
    div(span(class = "stat-label", "Shades"),
        span(class = "stat-value", textOutput("n_shades", inline = TRUE))),
    div(span(class = "stat-label", "Products"),
        span(class = "stat-value", textOutput("n_products", inline = TRUE))),
    div(span(class = "stat-label", "Largest gap"),
        span(class = "stat-value", textOutput("largest_gap", inline = TRUE)))
  ),

  card(
    card_header("Your brand vs the market"),
    plotOutput("compare_plot", height = "300px")
  ),
  layout_columns(
    card(card_header("Share of shades by band"),
         tableOutput("gap_table")),
    card(card_header(textOutput("benchmark_title", inline = TRUE)),
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

  # Which band the benchmark table should focus on, and why
  focus <- reactive({
    w <- worst()
    if (w$gap > gap_threshold) {
      # No meaningful gap: point to the band the whole market supplies least
      g <- gaps()
      list(band = g$band[which.min(g$market_share)], mode = "opportunity")
    } else {
      # A real gap: point to the brand's weakest band
      list(band = w$band, mode = "catch_up")
    }
  })


  # A one-sentence answer that changes with the selected brand
  output$takeaway <- renderUI({
    if (!has_data()) return(NULL)
    w <- worst()
    pts <- abs(round(w$gap * 100))
    n <- nrow(brand_shades())

    message <- if (w$gap > gap_threshold) {
      paste0("The ", input$brand, " shade mix closely matches the market: ",
             "no band is more than 5 points below its market share.")
    } else if (w$brand_shades == 0) {
      paste0(input$brand, " offers no ", tolower(w$band), " shades, ",
             pts, " points below the market.")
    } else {
      paste0("The largest gap for ", input$brand, " is in ",
             tolower(w$band), " shades, ", pts, " points below the market.")
    }

       tagList(
      p(class = "takeaway", message),
      if (n < 10) {
        p(class = "caution",
          paste0("Caution: ", input$brand, " has only ", n,
                 if (n == 1) " shade" else " shades",
                 " in this selection, so these comparisons are unreliable."))
      }
    )
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
    if (w$gap > gap_threshold) return("None")
    paste0(w$band, " ", sprintf("%+.0f", w$gap * 100), " pts")
  })

  output$compare_plot <- renderPlot({
    brand_data <- brand_shades()  # run the checks before building the plot
    plot_data <- rbind(
      data.frame(group = "Market", lightness = market()$lightness),
      data.frame(group = "Your brand", lightness = brand_data$lightness)
    )
    note <- if (nrow(brand_data) < 2) {
      "Too few shades to draw a curve for your brand."
    }
    ggplot2::ggplot(plot_data,
                    ggplot2::aes(lightness, colour = group)) +
      ggplot2::geom_density(linewidth = 1) +
      ggplot2::geom_vline(xintercept = input$breaks,
                          linetype = "dashed", colour = "#7A7066") +
      ggplot2::scale_colour_manual(
        values = c("Market" = "#B9AFA4", "Your brand" = "#8A4B32")
      ) +
      ggplot2::labs(x = "Lightness (0 = black, 1 = white)",
                    y = "Share of shades", colour = NULL,
                    caption = note) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(
        legend.position = "top",
        legend.justification = "left",
        axis.text.y = ggplot2::element_blank(),
        panel.grid.minor = ggplot2::element_blank(),
        plot.background = ggplot2::element_rect(fill = "transparent",
                                                colour = NA),
        panel.background = ggplot2::element_rect(fill = "transparent",
                                                 colour = NA),
        legend.background = ggplot2::element_rect(fill = "transparent",
                                                  colour = NA),
        legend.key = ggplot2::element_rect(fill = "transparent",
                                           colour = NA)
      )
  }, bg = "transparent")

  output$gap_table <- renderTable({
    g <- gaps()
    data.frame(
      Band = g$band,
      Yours = sprintf("%.1f%%", g$brand_share * 100),
      Market = sprintf("%.1f%%", g$market_share * 100),
      `Gap (pts)` = sprintf("%+.1f", g$gap * 100),
      check.names = FALSE
    )
  }, align = "lrrr")

   output$benchmark_title <- renderText({
    if (!has_data()) return("Benchmark products")
    f <- focus()
    band <- tolower(f$band)
    if (f$mode == "opportunity") {
      paste0("Market opportunity: ", band, " shades")
    } else {
      paste0("Catch-up priority: ", band, " shades")
    }
  })

  output$benchmark_table <- renderTable({
    f <- focus()
    out <- market() |>
      dplyr::filter(brand != input$brand) |>
      dplyr::mutate(band = band_of(lightness, input$breaks)) |>
      dplyr::filter(band == f$band) |>
      dplyr::count(brand, product, name = "n", sort = TRUE) |>
      head(5) |>
      dplyr::transmute(`Competitor product` = paste(brand, "·", product),
                       Shades = n)
    out
  }, align = "lr")
}

shinyApp(ui, server)