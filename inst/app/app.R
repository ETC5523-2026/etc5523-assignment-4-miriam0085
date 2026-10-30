library(shiny)
library(shaderange)

# ---- UI: what the user sees ----
ui <- fluidPage(
  titlePanel("Foundation Shade Supply Explorer"),
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        inputId = "target",
        label = "Target lightness range",
        min = 0, max = 1, value = c(0.20, 0.40), step = 0.01
      )
    ),
    mainPanel(
      plotOutput("market_plot"),
      tableOutput("target_summary")
    )
  )
)

# ---- Server: what happens when the user changes an input ----
server <- function(input, output, session) {

  # Shades inside the target range; recalculated when the slider moves
  target_shades <- reactive({
    foundation_shades |>
      dplyr::filter(
        lightness >= input$target[1],
        lightness <= input$target[2]
      )
  })

  # Market distribution with the target range highlighted
  output$market_plot <- renderPlot({
    ggplot2::ggplot(foundation_shades, ggplot2::aes(lightness)) +
      ggplot2::annotate(
        "rect",
        xmin = input$target[1], xmax = input$target[2],
        ymin = -Inf, ymax = Inf,
        fill = "#8B5E3C", alpha = 0.15
      ) +
      ggplot2::geom_histogram(
        binwidth = 0.025, fill = "#C9A07F", colour = "white"
      ) +
      ggplot2::labs(
        x = "Lightness (0 = black, 1 = white)",
        y = "Number of shades"
      ) +
      ggplot2::theme_minimal()
  })

  # How crowded is the target range?
  output$target_summary <- renderTable({
    data.frame(
      Shades = nrow(target_shades()),
      Products = dplyr::n_distinct(
        target_shades()$brand, target_shades()$product
      ),
      Brands = dplyr::n_distinct(target_shades()$brand)
    )
  })
}

shinyApp(ui, server)