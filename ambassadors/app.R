library(shiny)
shinyApp(

  ui = fluidPage(
    sidebarLayout(
      sidebarPanel(
        sliderInput('n', 'Sample size', 1000, 80000, 1000),
        sliderInput('theta', 'Rotate', 0, round(2 * pi, 4), 0),
        sliderInput('asp', 'Aspect ratio', .05, 1, 1),
        sliderInput('zoom', 'Scale', 0, 100, 0)
      ),
      mainPanel(
        plotOutput('full', brush = 'full_brush'),
        plotOutput('sub', height = '600px')
      )
    )
  ),

  server = function(input, output) {

    # raw data
    ambassadors = readRDS('ambassadors.rds')

    # rotate points by theta counter clockwise
    rotate = function(m, theta) {
      as.matrix(m) %*% matrix(c(cos(theta), -sin(theta), sin(theta), cos(theta)), 2)
    }

    # plot a sample of the original painting, just for fun
    output$full = renderPlot({
      par(mar = c(4, 4, 0, 0))
      ambassadors1 = ambassadors[sample(nrow(ambassadors), input$n), ]
      ambassadors1 = ambassadors1[order(ambassadors1$color), ]
      with(ambassadors1, plot(x, y, col = color, cex = 1.5, pch = 19))
    })

    # select data points under the brush
    sub_data = reactive({
      if (is.null(b <- input$full_brush)) return()
      i = with(ambassadors, x >= b$xmin & x <= b$xmax & y >= b$ymin & y <= b$ymax)
      ambassadors[i, , drop = FALSE]
    })

    # zoom [r1, r2] by a percentage z
    zoom_range = function(r, z) {
      d = (r[2] - r[1])/100 * z/2
      c(r[1] + d, r[2] - d)
    }

    # manipulate the sub plot (rotate, change aspect ratio, and zoom)
    output$sub = renderPlot({
      ambassadors2 = sub_data()
      if (is.null(ambassadors2)) return()
      par(mar = c(4, 4, 1, 0))
      ambassadors2[, 1:2] = rotate(ambassadors2[, 1:2], input$theta)
      with(
        ambassadors2,
        plot(x, y, col = color, pch = 20, asp = input$asp,
             xlim = zoom_range(range(x), input$zoom))
      )
    })

  }
)
