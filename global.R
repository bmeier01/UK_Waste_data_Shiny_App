library(shinydashboard)
library(googleVis)
library(leaflet)
library(tidyverse)
library(data.table)
library(readxl)
library(DT)

#waste <- fread(file= ".csv") 
WD_UK_2018 <- read_excel("2018_WDI_Extract.xlsx", skip = 8)
colnames(WD_UK_2018) <- tolower(colnames(WD_UK_2018))
colnames(WD_UK_2018) <- gsub(" ", "_", colnames(WD_UK_2018))
colnames(WD_UK_2018)

WD_UK_2018$ewc_chapter = gsub(pattern = " WASTES", replacement = "", x = WD_UK_2018$ewc_chapter)
WD_UK_2018$ewc_chapter = gsub(pattern = " WASTE$", replacement = "", x = WD_UK_2018$ewc_chapter)
WD_UK_2018$ewc_chapter = substr(x = WD_UK_2018$ewc_chapter, start = 6, stop = 50)
WD_UK_2018$ewc_chapter <- tolower(WD_UK_2018$ewc_chapter)
unique(WD_UK_2018$ewc_chapter)

WD_UK_2018$ewc_chapter[1] <- "paint, adhesive, sealant, ink manufacturing"
WD_UK_2018$ewc_chapter[8] <-"shaping and physical treatment of metals"
WD_UK_2018$ewc_chapter[9] <- "packaging, absorbents, wiping cloths etc"
WD_UK_2018$ewc_chapter[15] <- "not otherwise specified"

unique(WD_UK_2018$basic_waste_cat)

WD_UK_2018$basic_waste_cat = gsub(pattern = "Hhold/Ind/Com", replacement = "Household/Industrial/Commercial", x = WD_UK_2018$basic_waste_cat)
WD_UK_2018$basic_waste_cat = gsub(pattern = "*C+D", replacement = "Construction and Demolition", x = WD_UK_2018$basic_waste_cat)
unique(WD_UK_2018$basic_waste_cat)