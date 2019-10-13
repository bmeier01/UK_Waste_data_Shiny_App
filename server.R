library(shinydashboard)
library(googleVis)
library(leaflet)
library(ggplot2)
library(data.table)
library(readxl)
library(DT)

shinyServer(function(input, output){
#  # session
#  #updateSelectizeInput(session, 'foo', choices = data, server = TRUE)
#  # Return the selected dataset column ----
  columnName <- reactive({
#    # switch(input$waste_category,
#    #        "total" = tonnes_received,
#    #        "population_adjusted" = pressure,
#    #        "basic_waste_cat" = basic_waste_cat,
#    #        "ewc_chapter" = ewc_chapter)
#    # 
    if (input$waste_category == "basic_waste_cat"){
      WD_UK_2018 %>% group_by(basic_waste_cat) %>% 
      summarize(.,waste_in_tonnes = sum(tonnes_received)) %>% 
        mutate(.,percent_waste = round(waste_in_tonnes*100/sum(waste_in_tonnes),2)) %>%
        arrange(desc(percent_waste)) -> temporary
    } else if (input$waste_category == "ewc_chapter"){
      WD_UK_2018 %>% group_by(ewc_chapter) %>% 
        summarize(.,waste_in_tonnes = sum(tonnes_received)) %>% 
        mutate(.,percent_waste = round(waste_in_tonnes*100/sum(waste_in_tonnes),2)) %>%
        arrange(desc(percent_waste)) -> temporary
    }
    temporary
 })
  
  destin_waste_origin_basic_cat <- reactive({
    WD_UK_2018 %>% filter(., recorded_origin == input$recorded_origin_1 & basic_waste_cat == input$basic_waste_cat) %>% 
      group_by(facility_sub_region) %>% 
      summarize(.,waste_in_tonnes = sum(tonnes_received)) %>% 
      mutate(.,percent_waste = round(waste_in_tonnes*100/sum(waste_in_tonnes),2)) %>% 
      arrange(desc(percent_waste))
  })  
  
  destin_waste_origin_ewc_type <- reactive({
    WD_UK_2018 %>% filter(., recorded_origin == input$recorded_origin_2 & ewc_chapter == input$ewc_chapter) %>% 
      group_by(facility_sub_region) %>% 
      summarize(.,waste_in_tonnes = sum(tonnes_received)) %>% 
      mutate(.,percent_waste = round(waste_in_tonnes*100/sum(waste_in_tonnes),2)) %>% 
      arrange(desc(percent_waste))
    })
  
  basic_waste_cat_site <- reactive({
    WD_UK_2018 %>% filter(., basic_waste_cat == input$basic_waste_cat) %>% 
    group_by(facility_sub_region) %>% 
    summarize(.,waste_in_tonnes = sum(tonnes_received)) %>% 
    mutate(.,percent_waste = round(waste_in_tonnes*100/sum(waste_in_tonnes),2)) %>% 
    arrange(desc(percent_waste))
  })
  
  basic_waste_cat_fate <- reactive({
    WD_UK_2018 %>% filter(., basic_waste_cat == input$basic_waste_cat) %>% 
      group_by(fate) %>% 
      summarise(waste_in_tonnes = sum(tonnes_received)) %>% 
      mutate(.,percent_waste = round(waste_in_tonnes*100/sum(waste_in_tonnes),2)) %>% 
      arrange(desc(percent_waste))

  })
  
  
  #  output$map1 <- renderGvis({
  #    gvisGeoChart(state_stat, "state.name", input$selected,
  #                 options=list(region="US", displayMode="regions",
  #                              resolution="provinces",
  #                              width="auto", height="auto"))
  
  #  })
  #  output$map2 <- renderGvis({
  #    gvisGeoChart(state_stat, "state.name", input$selected,
  #                 options=list(region="US", displayMode="regions",
  #                              resolution="provinces",
  #                              width="auto", height="auto"))
  
  #  })
  
  output$Pie <- renderGvis({
    waste_in_percent <- columnName()
    gvisPieChart(data = waste_in_percent, labelvar = colnames(waste_in_percent[1]), numvar = "percent_waste", options = list(width=600, height=300))
  })
  
  output$table <- DT::renderDataTable({
    columnName()
  })
  
  output$bargraph_disposal <- renderPlot({
    basic_waste_cat_site() %>% 
      ggplot(aes(x=facility_sub_region, y=waste_in_tonnes)) +
      geom_bar(stat="identity", fill='goldenrod1') + 
      theme_light() +
      theme(axis.text.x = element_text(angle = 90, hjust=0), plot.title = element_text(hjust = 0.5)) +
      labs(title="Waste Disposal Sites", x ="", y = "Waste in Tonnes")
  })
  
  output$pie_1_disposal <- renderGvis({
    gvisPieChart(data = basic_waste_cat_fate(), labelvar = colnames(waste_in_percent[1]), numvar = "percent_waste", options = list(width=600, height=300))
  })
  
  output$bargraph_1 <- renderPlot({
    destin_waste_origin_basic_cat() %>% 
    ggplot(aes(x=facility_sub_region, y=waste_in_tonnes)) +
      geom_bar(stat="identity", fill='royalblue1') +
      theme_light() +
      theme(axis.text.x = element_text(size= 12, angle = 90, hjust=0)) +
      xlab("") +
      ylab("Waste in Tonnes")
  })
  
  output$bargraph_2 <- renderPlot({
    destin_waste_origin_ewc_type() %>% 
      ggplot(aes(x=facility_sub_region, y=waste_in_tonnes)) +
      geom_bar(stat="identity", fill='darkolivegreen4') +
      theme_light() +
      theme(axis.text.x = element_text(size= 12, angle = 90, hjust=0)) +
      xlab("") +
      ylab("Waste in Tonnes")
  })

 
})