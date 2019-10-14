## server.R ##

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
  
  for_map <- reactive({WD_UK_2018 %>% filter(., recorded_origin == input$recorded_origin_3) %>% 
      group_by(facility_sub_region) %>% 
      select(recorded_origin, origin_lon, origin_lat, facility_sub_region, site_lon, site_lat) %>% 
      unique()
  })
  
  
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
    gvisPieChart(data = basic_waste_cat_fate(), labelvar = colnames(basic_waste_cat_fate()[1]), numvar = "percent_waste", options = list(width=600, height=300))
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
  
  output$waste_route_map <- renderLeaflet({
    leaflet() %>%
    addTiles() %>%
    addPolygons(data=map_UK, stroke = FALSE) %>% addProviderTiles("Esri.WorldStreetMap") %>% 
      addCircles(data=for_map(), lng = for_map()$site_lon, lat= for_map()$site_lat,color = "red")  %>%
    addCircles(data=for_map(), lng = for_map()$origin_lon, lat = for_map()$origin_lat, color = "green") 
  })

 
})