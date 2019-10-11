library(shinydashboard)
library(googleVis)
library(leaflet)
library(ggplot2)
library(data.table)
library(readxl)
library(DT)

## ui.R ##
shinyUI(dashboardPage(
  dashboardHeader(
    title = "UK Waste Statistics 2018"
  ),
  dashboardSidebar(
    sidebarUserPanel("B Meier"), #, image = <link to Your Photo>),
    sidebarMenu(
      menuItem("Background", tabName = "intro", icon = icon("info-circle")),
      menuItem("Map", tabName = "map", icon = icon("map")), 
      menuItem("PieChart", tabName = "proportions", icon = icon("chart-pie")),
      menuItem("Data", tabName = "data", icon = icon("database"))
      ),
    
    selectizeInput(inputId = "waste_category",
                   label = "Waste Category",
                   choices = c("total", "population adjusted", "basic_waste_cat", "ewc_chapter"))
  ),
  dashboardBody(
    tabItems(
    tabItem(tabName = "map",
            "to be replaced with origin and dest map"
            #fluidRow(box(htmlOutput("map1")),  # gvisGeochart origin
            #         box(htmlOutput("map2")))), # gvisGeochart dest
            ),
    tabItem(tabName = "proportions",
            #"to be replaced with pie-chart"
            fluidRow(box(htmlOutput("Pie"), width = 12))
            ),
    tabItem(tabName = "data",
            #"to be replaced with datatable"
            fluidRow(box(DT::dataTableOutput("table"),
                         width = 12))
            ))
  )
))
