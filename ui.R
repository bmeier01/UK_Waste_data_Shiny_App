
## ui.R ##
shinyUI(dashboardPage(skin = "black",
                      
  dashboardHeader(
    title = "UK Waste Statistics 2018"
  ),
  
  dashboardSidebar(
    sidebarUserPanel("Bettina Meier"), #, image = <link to Your Photo>),
    sidebarMenu(
      menuItem("Topic Background", tabName = "intro", icon = icon("info-circle")),
      menuItem("Waste Data Overview", tabName = "proportions", icon = icon("chart-pie")),
      menuItem("Waste Diposal", tabName = "fate", icon = icon("recycle")),
      menuItem("Waste Routes - Details", tabName = "data", icon = icon("truck"))
      )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "intro",
              h4("Where does our waste go?")
              #fluidRow(box(htmlOutput("map1")),  # gvisGeochart origin
              #         box(htmlOutput("map2")))), # gvisGeochart dest
      ),
#    tabItem(tabName = "map",
#            "to be replaced with origin and dest map"
            #fluidRow(box(htmlOutput("map1")),  # gvisGeochart origin
            #         box(htmlOutput("map2")))), # gvisGeochart dest
#            ),
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
              box(plotOutput("bargraph_disposal"), width = 12
              ),
              br(),
              box(htmlOutput("pie_1_disposal"), width = 12) 
# 

             

#              box(htmlOutput("Pie_2"), width = 12), 
#              br(),
#              box(DT::dataTableOutput("table_2"), width = 12)
              
            )),
    tabItem(tabName = "data",
            fluidRow(
            box(
              selectizeInput(inputId = "recorded_origin_1",
                               label = "Origin",
                               choices = sort(unique(WD_UK_2018$recorded_origin))),
              selectizeInput(inputId = "basic_waste_cat",
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
