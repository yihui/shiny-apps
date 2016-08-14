library(shiny)
shinyApp(
  ui = fluidPage(
    singleton(tags$head(
      tags$script(src="//cdnjs.cloudflare.com/ajax/libs/annyang/1.4.0/annyang.min.js"),
      includeScript('init.js')
    )),
    div(
      style = 'display: block; margin: auto; width: 100%; max-width: 500px',
      plotOutput('foo'),
      helpText(
        'You are recommended to use Google Chrome to play with this app.',
        'To change the title, say something that starts with "title", e.g.',
        '"title I love the R language", or "title Good Morning".',
        'To change the color of points, say something that starts with "color",',
        'e.g. color "blue", or color "green". When the app is unable to recognize the color,',
        'the points will turn gray.',
        'To add a regression line, say "regression".',
        'To make the points bigger or smaller, say "bigger" or "smaller".'
      ),
      helpText(HTML(
        'The source code of this app is <a href="https://github.com/yihui/shiny-apps/tree/master/voice">on Github</a>.',
        'You may also see <a href="http://vimeo.com/yihui/shiny-voice">my demo</a> of playing with this app.'
      ))
    )
  ),
  server = function(input, output) {
    lm_line = reactive({
      input$yes
      fit = lm(dist ~ speed, data = cars)
      lines(cars$speed, predict(fit, cars), lwd = 2)
    })
    output$foo = renderPlot({
      col = input$color
      if (length(col) == 0 || !(col %in% colors())) col = 'gray'
      plot(cars, main = input$title, col = col, cex = input$bigger, pch = 19)
      lm_line()
    })
  }
)
