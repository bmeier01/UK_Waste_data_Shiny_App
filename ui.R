
## ui.R ##
shinyUI(dashboardPage(skin = "blue",
                      
  dashboardHeader(
    title = "UK Waste Statistics 2018"
  ),
  
  dashboardSidebar(
    sidebarUserPanel("Bettina Meier"), #, image = <link to Your Photo>),
    sidebarMenu(
      menuItem("Topic Background", tabName = "intro", icon = icon("info-circle")),
      menuItem("Waste Data Overview", tabName = "proportions", icon = icon("chart-pie")),
      menuItem("Waste Diposal", tabName = "fate", icon = icon("recycle")),
      menuItem("Waste Routes - Details", tabName = "data", icon = icon("truck")),
      menuItem("Waste Routes - Map", tabName = "map", icon = icon("map"))
      )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "intro",
              img(src="waste_truck_m.jpg", width = 700),
              h6("flickr Image by Jeffrey Beall; Creative Commons Licence: Attribution-NoDerivs 2.0 Generic (CC BY-ND 2.0)", align = "right"),
              br(),
              h2("Where Does Our Waste Go?", align = "center"),
              p(h4("Waste management has become an increasingly widely discussed topic in the media,
                from how much waste we produce to how it is disposed of. What happens to our household
                waste once it is picked up by our local council? How much does household or industry waste
                contribute to our overall waste production as a society?")),
              
              p(h4("I wanted to look at waste data information to visualize the different types of waste produced, where waste is processed,
                   and how it is processed.")),
              
              p(h4("I therefore chose the Waste Data Interrogator 2018 published by the UK Government,
                   Department for Environment, Food and Rural Affairs, as a resource. This data set contains
                   comprehensive information on the quantities and types of waste received as well as information
                   on waste sent on to other facilities by the ~6,000 operators of regulated waste management
                   facilities in England. The database does not contain information on regulated waste management
                   facilities in Wales and Scotland as environmental regulation responsibilities for these are being
                   held by Natural Resources Wales (NRW) and the Scottish Environment Protection Agency (SEPA), respectively.")),
              
              p(h4("Waste types are categorized based on the European Waste Catalogue (EWC), a hierarchical list of waste descriptions
                   established by the European Commission. Reporting for the Waste Data Interrogator 2018 resource uses two
                   hierarchical levels: a basic system with three main categories – (1) inert/construction and demolition, (2)
                   household/industrial and commercial, and (3) hazardous - and a detailed system with specific EWC descriptors."))
      ),
    tabItem(tabName = "map",
            fluidPage(box(selectizeInput(inputId = "recorded_origin_3",
                                         label = "Origin",
                                         choices = sort(unique(WD_UK_2018$recorded_origin))), width=12),
    
                      column(12, leafletOutput("waste_route_map"))#,  # leaflet map
            #         box(DT::dataTableOutput("longest_distance"), width = 12))) # gvisGeochart dest
            )),
    tabItem(tabName = "proportions",
            fluidPage(
              box(selectizeInput(inputId = "waste_category",
                                 label = "Waste Category",
                                 choices = list("Basic Waste Category" = "basic_waste_cat",
                                                "Waste Types (European Waste Catalogue)" = "ewc_chapter")), width = 12),
              box(htmlOutput("Pie"), width = 12), 
              br(),
              box(DT::dataTableOutput("table"), width = 12)
            )),
    tabItem(tabName = "fate",
            fluidPage(
              box(selectizeInput(inputId = "basic_waste_cat",
                                 label= "Basic Waste Category",
                                 choices = sort(unique(WD_UK_2018$basic_waste_cat))), width = 12),
              box(plotOutput("bargraph_disposalsite"), width = 12
              ),
              br(),
              box(plotOutput("bargraph_disposaltype"),
                  htmlOutput("pie_1_disposal"), width = 12
              )

            )),
    tabItem(tabName = "data",
            fluidRow(
            box(
              selectizeInput(inputId = "recorded_origin_1",
                               label = "Origin",
                               choices = sort(unique(WD_UK_2018$recorded_origin))),
              selectizeInput(inputId = "basic_waste_cat_2",
                               label= "Basic Waste Category",
                               choices = sort(unique(WD_UK_2018$basic_waste_cat))), width = 5),
               column(7, plotOutput("bargraph_1"))),
            
            br(),
            
            fluidRow(
              box(
                selectizeInput(inputId = "recorded_origin_2",
                                 label = "Origin",
                                 choices = sort(unique(WD_UK_2018$recorded_origin))),
                selectizeInput(inputId = "ewc_chapter",
                                        label= "Waste Types (European Waste Catalogue)",
                                        choices = sort(unique(WD_UK_2018$ewc_chapter))), width = 5),
              column(7, plotOutput("bargraph_2")))
            )
            ))
  )
)
