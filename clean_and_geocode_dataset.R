library("ggplot2")
library("dplyr") 
library("tidyr")
library(readxl)
library(xlsx)
library(ggmap) # geocoding
#library(gmapsdistance) # get distance between locations
library(geosphere) # get distance between locations using lon lat
library(oce) # get distance between locations using lon lat


## CLEAN DATA ####

WD_UK_2018 <- read_excel("2018_WDI_Extract.xlsx", skip = 8)
colnames(WD_UK_2018) <- tolower(colnames(WD_UK_2018))
colnames(WD_UK_2018) <- gsub(" ", "_", colnames(WD_UK_2018))
colnames(WD_UK_2018)

WD_UK_2018$ewc_chapter = gsub(pattern = " WASTES", replacement = "", x = WD_UK_2018$ewc_chapter)
WD_UK_2018$ewc_chapter = gsub(pattern = " WASTE$", replacement = "", x = WD_UK_2018$ewc_chapter)
WD_UK_2018$ewc_chapter = substr(x = WD_UK_2018$ewc_chapter, start = 6, stop = 50)
WD_UK_2018$ewc_chapter <- tolower(WD_UK_2018$ewc_chapter)
unique(WD_UK_2018$ewc_chapter)

# fix some of the catgories
WD_UK_2018$ewc_chapter = gsub(pattern = "paint, adhesive, sealant and ink manufacturin", replacement = "paint, adhesive, sealant, ink manufacturing", x = WD_UK_2018$ewc_chapter)
WD_UK_2018$ewc_chapter = gsub(pattern = "shaping and physical treatment of metals and ", replacement = "shaping and physical treatment of metals", x = WD_UK_2018$ewc_chapter)
WD_UK_2018$ewc_chapter = gsub(pattern = "packaging, absorbents , wiping cloths etc n.o", replacement = "packaging, absorbents, wiping cloths etc", x = WD_UK_2018$ewc_chapter)  
WD_UK_2018$ewc_chapter = gsub(pattern = "not otherwise specified in the list", replacement = "not otherwise specified", x = WD_UK_2018$ewc_chapter)    

# remove (Ltd's), too detailed info for origin and not identifyable in geocoding
WD_UK_2018$recorded_origin = gsub(pattern = " \\(.*\\)", replacement = "", x = WD_UK_2018$recorded_origin) 

WD_UK_2018$basic_waste_cat = gsub(pattern = "Hhold/Ind/Com", replacement = "Household/Industrial/Commercial", x = WD_UK_2018$basic_waste_cat)
#WD_UK_2018$basic_waste_cat = gsub(pattern = "\\C+\\)", replacement = "\\Construction+\\", x = WD_UK_2018$basic_waste_cat)
unique(WD_UK_2018$basic_waste_cat)

WD_UK_2018$fate = gsub(pattern = "\\(R\\)", replacement = "\\(Recovery\\)", x = WD_UK_2018$fate)
WD_UK_2018$fate = gsub(pattern = "\\(D\\)", replacement = "\\(Disposal\\)", x = WD_UK_2018$fate)

WD_UK_2018$facility_sub_region = gsub(pattern = "Bath, Bristol and S Glo", replacement = "Bath, Bristol, S Glouchester", x = WD_UK_2018$facility_sub_region)


write.csv(WD_UK_2018, file = "WD_UK_2018_step1.csv")


## GEOCODE THE WASTE FACILITIES AND WASTE ORIGINS ####
#library(ggmap)

# 1. USE ORIGIN NAMES FOR ORIGIN GEOCODING
sources_1 <- distinct(WD_UK_2018, recorded_origin)
sources_recorded_origin <- as.data.frame(sources_1)

# Fix for geocoding, SOME ORIGINS NOT UNIQUE AND WERE INITIALLY REPLACED BY US CITIES
sources_recorded_origin$recorded_origin = paste0(sources_recorded_origin$recorded_origin, ", UK") # add UK to origin

sources_df <- mutate_geocode(sources_recorded_origin, recorded_origin)
head(sources_df)
colnames(sources_df) <- c("recorded_origin", "origin_lon", "origin_lat")
str(sources_df)
sources_df$recorded_origin = gsub(pattern = ", UK", replacement = "", x = sources_df$recorded_origin) # remove to match with original DF

# Newark & Sherwood have not been geocoded correctly, currently US
# correct is 53.0851° N, 0.9522° W
#sources_df$origin_lon[which(sources_df$recorded_origin == "Newark & Sherwood")] <- as.numeric("0.9522")
#sources_df$origin_lat[which(sources_df$recorded_origin == "Newark & Sherwood")] <- as.numeric("53.0851")

write.csv(sources_df, file = "recorded_origin_lon_lat.csv")

# 2. USE GIVEN POSTCODES FOR WASTE FACILITY GEOCODING RATHER THAN EASTING AND NORTHING INFO
waste_facilities <- distinct(WD_UK_2018, sitepc)
wf_df <- as.data.frame(waste_facilities)

# Remove 1 NA column to prepare for geocoding
wf_df_1 <- na.omit(wf_df)
str(wf_df_1)
head(wf_df_1)

waste_facility_lon_lat <- mutate_geocode(wf_df_1, sitepc)
colnames(waste_facility_lon_lat) <- c("sitepc", "site_lon", "site_lat")
head(waste_facility_lon_lat)

write.csv(waste_facility_lon_lat, file = "waste_facility_lon_lat.csv")


# 3. JOIN LON - LAT INFORMATION TO DF
WD_UK_2018_ori_ll <- dplyr::left_join(WD_UK_2018, sources_df, by="recorded_origin")
WD_UK_2018_ori_ll_dest_ll <- dplyr::left_join(WD_UK_2018_ori_ll, waste_facility_lon_lat, by="sitepc")


## GET DISTANCE ####
WD_UK_2018_dest_ll_origin_ll$ori_dest_distance <- distGeo(WD_UK_2018_dest_ll_origin_ll[26:27], WD_UK_2018_dest_ll_origin_ll[28:29])

# create new columns to calculate in km and convert to miles
WD_UK_2018_ll_dist <- WD_UK_2018_dest_ll_origin_ll %>%
  dplyr::mutate(Dist_in_Kilometres = round(ori_dest_distance/1000, 1),  # calculate km from m
    Dist_in_Miles = round(Dist_in_Kilometres * 0.621371, 1)  # convert to miles
  )

write.csv(WD_UK_2018_ll_dist, file = "WD_UK_2018_clean.csv")
