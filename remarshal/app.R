download.file('https://bootstrap.pypa.io/ez_setup.py', 'ez_setup.py')
system('python ez_setup.py --user; python setup.py install --user')

library(shiny)
shinyApp(

  ui = fluidPage(
    fluidRow(
      tags$head(tags$style(
        type = 'text/css',
        '.shiny-input-container:not(.shiny-input-container-inline) {width: auto;}'
      )),
      column(5, textAreaInput('str_src', 'Input', width = '100%', height = '90vh')),
      column(
        2,
        selectInput('from', 'From', c('toml', 'yaml', 'json'), selectize = FALSE),
        selectInput('to', 'To', c('yaml', 'toml', 'json'), selectize = FALSE),
        actionButton('convert', 'Convert')
      ),
      column(5, textAreaInput('str_out', 'Output', width = '100%', height = '90vh'))
    )
  ),

  server = function(input, output, session) {
    f1 = tempfile()
    f2 = tempfile()
    observeEvent(input$convert, {
      from = input$from; to = input$to
      if (from == to) return()
      writeLines(input$str_src, f1)
      system('chmod +x remarshal.py')
      system(paste(
        './remarshal.py', '-i', shQuote(f1), '-o', shQuote(f2),
        '-if', from, '-of', to
      ))
      updateTextAreaInput(
        session, 'str_out', value = paste(readLines(f2), collapse = '\n')
      )
    })
  }
)
