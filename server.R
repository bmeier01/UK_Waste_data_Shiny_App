library(shinydashboard)
library(googleVis)
library(leaflet)
library(ggplot2)
library(data.table)
library(readxl)
library(DT)

shinyServer(function(input, output){
  
  # Return the selected dataset column ----
  datasetInput <- reactive({
    switch(input$selected,
           "total" = tonnes_received,
           "population_adjusted" = pressure,
           "basic_waste_cat" = basic_waste_cat,
           "ewc_chapter" = ewc_chapter)
  })
  
#  output$map1 <- renderGvis({
#    gvisGeoChart(state_stat, "state.name", input$selected,
#                 options=list(region="US", displayMode="regions",
#                              resolution="provinces",
#                              width="auto", height="auto"))
    # using width="auto" and height="auto" to
    # automatically adjust the map size
#  })
#  output$map2 <- renderGvis({
#    gvisGeoChart(state_stat, "state.name", input$selected,
#                 options=list(region="US", displayMode="regions",
#                              resolution="provinces",
#                              width="auto", height="auto"))
    # using width="auto" and height="auto" to
    # automatically adjust the map size
#  })
  
#  output$proportions <- renderPieChart({
#    datatable(state_stat, rownames=FALSE) %>%
#      formatStyle(input$selected,
#                  background="skyblue", fontWeight='bold')
  # Highlight selected column using formatStyle
#})
    
  output$Pie <- renderGvis({
    waste_in_percent <- WD_UK_2018 %>%
      group_by(ewc_chapter) %>% # replace by input
      summarize(.,waste_in_tonnes = sum(tonnes_received)) %>% 
      mutate(.,percent_waste = round(waste_in_tonnes*100/sum(waste_in_tonnes),2)) %>%
      arrange(desc(percent_waste))
    
    gvisPieChart(data = waste_in_percent, labelvar = "ewc_chapter", numvar = "percent_waste")
  })

  output$table <- DT::renderDataTable({
    
    waste_in_percent_tbl <- WD_UK_2018 %>%
      group_by(ewc_chapter) %>% # replace by input
      summarize(.,waste_in_tonnes = sum(tonnes_received)) %>% 
      mutate(.,percent_waste = round(waste_in_tonnes*100/sum(waste_in_tonnes),2)) %>%
      arrange(desc(percent_waste)) #%>%
      #formatStyle(columns = percent_waste, background="skyblue", fontWeight='bold') # replace by input
    return(waste_in_percent_tbl)
    
   # datatable(state_stat, rownames=FALSE) %>%
   #   formatStyle(input$selected,
    #              background="skyblue", fontWeight='bold')
    # Highlight selected column using formatStyle
  })
  
  
  
})