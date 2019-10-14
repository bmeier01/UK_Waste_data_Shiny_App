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


#WD_UK_2018 <- fread(file= "WD_UK_2018_clean.csv")
WD_UK_2018 <- fread(file= "WD_UK_2018_cleaned.csv")

# file info: https://blog.exploratory.io/making-maps-for-uk-countries-and-local-authorities-areas-in-r-b7d222939597
# downloaded from https://exploratory.io/map, UK Local Administrative Areas, uk_la.geojson file 11.6 MB
map_UK <- geojson_read("./uk_local_areas/uk_la.geojson", what = "sp")


