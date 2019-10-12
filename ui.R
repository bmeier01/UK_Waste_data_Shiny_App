library(shinydashboard)
library(googleVis)
library(leaflet)
library(data.table)
library(readxl)
library(DT)
library(tidyverse)

## ui.R ##
shinyUI(dashboardPage(
  dashboardHeader(
    title = "UK Waste Statistics 2018"
  ),
  dashboardSidebar(
    sidebarUserPanel("B Meier"), #, image = <link to Your Photo>),
    sidebarMenu(
      menuItem("Topic Background", tabName = "intro", icon = icon("info-circle")),
      menuItem("Map", tabName = "map", icon = icon("map")), 
      menuItem("Waste Data Overview", tabName = "proportions", icon = icon("chart-pie")),
      menuItem("Detailed Analysis", tabName = "data", icon = icon("database"))
      )#,
    
#    selectizeInput(inputId = "waste_category",
#                   label = "Waste Category",
#                   choices = c("total", "population adjusted", "basic_waste_cat", "ewc_chapter"))
  ),
  dashboardBody(
    tabItems(
    tabItem(tabName = "map",
            "to be replaced with origin and dest map"
            #fluidRow(box(htmlOutput("map1")),  # gvisGeochart origin
            #         box(htmlOutput("map2")))), # gvisGeochart dest
            ),
    tabItem(tabName = "proportions",
            # pie-chart
            fluidPage(
            #fluidRow(
              box(selectizeInput(inputId = "waste_category",
                                 label = "Waste Category",
                                 choices = c("basic_waste_cat", "ewc_chapter"))),
              
            
            # Output: Tabset w/ plot, summary, and table ----
            #tabsetPanel(
            #tabPanel("Plot", htmlOutput("Pie")),
             #tabPanel("Table", DT::dataTableOutput("table")))
            
              box(htmlOutput("Pie"), width = 12)#, 
            #br(),
            
            #  box(DT::dataTableOutput("table"), height= 300, width = 12)
            
            )),

    tabItem(tabName = "data",
            fluidRow(
            box(selectizeInput(inputId = "basic_waste_cat",
                               label= "Waste Type",
                               choices = unique(WD_UK_2018$basic_waste_cat)),

                selectizeInput(inputId = "recorded_origin",
                               label = "origin",
                               choices = unique(WD_UK_2018$recorded_origin)))),

#              box(DT::dataTableOutput("table"),
#                         width = 12), 
               box(plotOutput("bargraph"), width=12)
            ))
  )
))
