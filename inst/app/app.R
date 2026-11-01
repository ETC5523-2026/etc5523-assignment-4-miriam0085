library(shiny)
library(bslib)
library(shaderange)

# ---- Setup ----
brand_choices <- sort(unique(foundation_shades$brand))

# One sans-serif font for everything; serif only for the question
app_theme <- bs_theme(
  version = 5,
  bg = "#F7F4EF", fg = "#1F1D1B", primary = "#A33B57",
  base_font = font_google("Inter", wght = c(400, 600)),
  heading_font = font_google("Inter", wght = c(400, 600)),
  font_scale = 1,
  "border-radius" = "4px"
)

# Custom styles, added directly to the page
app_css <- "
  /* ---- Page title: spaced capitals, like a wordmark ---- */
  .bslib-page-title, .navbar-brand {
    font-family: Inter, sans-serif; font-weight: 400; font-size: .8rem;
    letter-spacing: .22em; text-transform: uppercase; color: #1F1D1B; }

  /* ---- Header area ---- */
  .accent { width: 28px; height: 2px; background: #A33B57;
            margin-bottom: .75rem; }
  .eyebrow { font-size: .72rem; letter-spacing: .12em;
             text-transform: uppercase; color: #7A7066;
             margin-bottom: .35rem; }
  .question { font-family: 'Cormorant Garamond', Georgia, serif;
              font-size: 1.4rem; line-height: 1.25; margin-bottom: 1rem; }
  .takeaway { font-size: 1rem; font-weight: 600; margin-bottom: .25rem; }
  .caution  { color: #9A5B00; font-size: .85rem; }
  .stat-strip { display: flex; gap: 2rem; padding: .6rem 0;
                border-top: 1px solid #D8CFC4;
                border-bottom: 1px solid #D8CFC4; margin: .75rem 0 1rem; }
  .stat-label { color: #7A7066; font-size: .85rem; margin-right: .4rem; }
  .stat-value { font-weight: 600; font-variant-numeric: tabular-nums; }

  /* ---- Labels: one style for sidebar, card and section titles ---- */
  .bslib-sidebar-layout > .sidebar .control-label,
  .bslib-card .card-header,
  .accordion-button {
    font-size: .78rem !important; font-weight: 400 !important;
    letter-spacing: .12em; text-transform: uppercase; color: #7A7066; }

  /* ---- Cards: hairline border, no shadow ---- */
  .bslib-card { background: #FBF8F3; border: 1px solid #DCD3C8;
                border-radius: 2px; box-shadow: none !important; }
  .bslib-card .card-header { background: transparent; border-bottom: none;
                             padding-bottom: 0; }
  .bslib-card .card-body { padding-top: .5rem; }
  .bslib-page-sidebar .main > .container-fluid,
  .bslib-sidebar-layout > .main { max-width: 1200px; }

  /* ---- Plot legend: keep brand names in their own case ---- */
  .legend-item { font-size: .8rem; color: #7A7066; margin-left: 1rem;
                 display: inline-flex; align-items: center; gap: .4rem;
                 text-transform: none; letter-spacing: normal; }
  .legend-line { width: 18px; height: 2px; background: #A33B57;
                 display: inline-block; }
  .legend-area { width: 14px; height: 8px; background: #CEC7BE;
                 display: inline-block; }

  /* ---- Tables ---- */
  .table { font-variant-numeric: tabular-nums;
           --bs-table-bg: transparent;
           --bs-table-striped-bg: transparent; }
  .table > :not(caption) > * > * { background-color: transparent; }
  .table th { font-weight: 400; color: #7A7066; white-space: nowrap; }
  .gap-flag { color: #A33B57; font-weight: 600; }

  /* ---- Notes section at the bottom ---- */
  .notes li { margin-bottom: .4rem; font-size: .9rem; }
  .text-muted { color: #7A7066 !important; }
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
  div(class = "accent"),
  p(class = "eyebrow",
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
    card_header(
      class = "d-flex justify-content-between align-items-center",
      span("Your brand vs the market"),
      uiOutput("plot_legend", inline = TRUE)
    ),
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
    pts <- abs(round(w$gap * 100, 1))
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
    paste0(w$band, " ", sprintf("%+.1f", w$gap * 100), " pts")
  })

     # A simple legend in the card header: a line for the brand, a block for
  # the market
  output$plot_legend <- renderUI({
    if (!has_data()) return(NULL)
    div(
      class = "d-flex align-items-center",
      span(class = "legend-item", span(class = "legend-line"), input$brand),
      span(class = "legend-item", span(class = "legend-area"), "Market")
    )
  })

  output$compare_plot <- renderPlot({
    brand_data <- brand_shades()  # run the checks before building the plot
    b <- input$breaks

    # Background bands: clearly darker fill for darker shades
    bands <- data.frame(
      xmin = c(0, b[1], b[2]),
      xmax = c(b[1], b[2], 1),
      label = c("Deep", "Medium", "Light"),
      fill = c("#E2DDD6", "#ECE8E2", "#F4F2EE")
    )

    note <- if (nrow(brand_data) < 2) {
      "Too few shades to draw a curve for your brand."
    }

    ggplot2::ggplot() +
      ggplot2::geom_rect(
        data = bands,
        ggplot2::aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf),
        fill = bands$fill
      ) +
      # Thin white dividers between bands
      ggplot2::geom_vline(xintercept = b, colour = "#FBF8F3", linewidth = 0.8) +
      ggplot2::geom_text(
        data = bands,
        ggplot2::aes(x = (pmax(xmin, 0.12) + xmax) / 2, y = Inf,
                     label = label),
        vjust = 1.8, size = 4.2, colour = "#7A7066"
      ) +
      # Market as a soft filled area in the background
      ggplot2::geom_density(
        data = market(), ggplot2::aes(lightness),
        fill = "#CEC7BE", colour = NA, alpha = 0.8
      ) +
      # The selected brand as the main line
      ggplot2::geom_density(
        data = brand_data, ggplot2::aes(lightness),
        colour = "#A33B57", linewidth = 0.8
      ) +
      ggplot2::scale_x_continuous(breaks = c(0.25, 0.5, 0.75),
                                  expand = c(0, 0)) +
      ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = c(0, 0.2))) +
      ggplot2::coord_cartesian(xlim = c(0.12, 1)) +
      ggplot2::labs(x = "Lightness (0 = black, 1 = white)",
                    y = NULL, caption = note) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(
        axis.text.y = ggplot2::element_blank(),
        axis.text.x = ggplot2::element_text(colour = "#7A7066"),
        axis.title = ggplot2::element_text(colour = "#7A7066", size = 11),
        panel.grid = ggplot2::element_blank(),
        plot.background = ggplot2::element_rect(fill = "transparent",
                                                colour = NA),
        panel.background = ggplot2::element_rect(fill = "transparent",
                                                 colour = NA)
      )
  }, bg = "transparent", res = 96)

    output$gap_table <- renderTable({
    g <- gaps()
    gap_text <- sprintf("%+.1f", g$gap * 100)

    # Highlight the weakest band, but only when the gap is meaningful
    worst_row <- which.min(g$gap)
    if (g$gap[worst_row] <= gap_threshold) {
      gap_text[worst_row] <- paste0('<span class="gap-flag">',
                                    gap_text[worst_row], '</span>')
    }

    data.frame(
      Band = g$band,
      Yours = sprintf("%.1f%%", g$brand_share * 100),
      Market = sprintf("%.1f%%", g$market_share * 100),
      `Gap (pts)` = gap_text,
      check.names = FALSE
    )
  }, align = "lrrr", sanitize.text.function = function(x) x)

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