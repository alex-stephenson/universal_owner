library(tidyverse)
library(shiny)
library(rsconnect)






ui <- fluidPage(
  titlePanel("Download data"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file1", "Choose .txt file",
                multiple = F,
                accept = c(".txt")),
      textInput('energy_co', 'Name of energy company'),
      textInput('asset', 'name of Asset Manager'),
      downloadButton("downloadData", "Download")
    ),
    
    mainPanel(
      tableOutput("table")
    )
    
  )
)


options(shiny.maxRequestSize=30*1024^2)

server <- function(input, output, session) {
  
  company_data <- reactive({
    req(input$file1,input$asset,input$energy_co)
    
    data <- read_lines(input$file1$datapath)
    text_df <- as_data_frame(data)
    
    company_data <- text_df %>% 
      filter(str_detect(value, input$asset)) %>%   
      filter(str_detect(value, input$energy_co)) %>% 
      distinct(.)
    company_data
  })
  
  
  output$table <- renderTable({  
    
    company_data()
    
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(company_data(), ".csv", sep = "")
    },
    content = function(file) {
      write.csv(company_data(), file, row.names = FALSE)
    }
  )
  
}


shinyApp(ui, server)