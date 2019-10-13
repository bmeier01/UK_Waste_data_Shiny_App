library(shiny)
library(shinydashboard)
library(googleVis)
library(leaflet)
library(dplyr)
library(ggplot2)
library(data.table)
#library(readxl)
library(DT)
library(sp)
library(geojsonio)


WD_UK_2018 <- fread(file= "WD_UK_2018_clean.csv")
map_UK <- geojson_read("./uk_local_areas/uk_la.geojson", what = "sp")

#leaflet_UK <- leaflet() %>%
#  addTiles() %>%
#  addPolygons(data=map_UK, stroke = FALSE) %>% addProviderTiles("Esri.WorldStreetMap")
