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
# requires sign up to Google Cloud Platform and an API key 
# register_google(key = "key code")

head(sources_df)
colnames(sources_df) <- c("recorded_origin", "origin_lon", "origin_lat")
sources_df$recorded_origin = gsub(pattern = ", UK", replacement = "", x = sources_df$recorded_origin) # remove to match with original DF
View(sources_df)
nrow(sources_df)

# Hinckley & Bosworth has been geocoded incorrectly, currently US, correct is 52.6303° N, 1.4115° W
sources_df$origin_lon[which(sources_df$recorded_origin == "Hinckley & Bosworth")] <- as.numeric("-1.4115")
sources_df$origin_lat[which(sources_df$recorded_origin == "Hinckley & Bosworth")] <- as.numeric("52.6303")

# East Midlands have not been geocoded as usually Midlands East, correct is 52.8700° N, 0.9950° W
sources_df$origin_lon[which(sources_df$recorded_origin == "East Midlands")] <- as.numeric("-0.9950")
sources_df$origin_lat[which(sources_df$recorded_origin == "East Midlands")] <- as.numeric("52.8700")

# Southampton UA has been geocoded incorrectly, currently US, correct is 52.6303° N, 1.4115° W
sources_df$origin_lon[which(sources_df$recorded_origin == "Southampton UA")] <- as.numeric("-1.4115")
sources_df$origin_lat[which(sources_df$recorded_origin == "Southampton UA")] <- as.numeric("52.6303")

#Newark & Sherwood has been geocoded incorrectly, currently US, correct is 53.0851° N, 0.9522° W
sources_df$origin_lon[which(sources_df$recorded_origin == "Newark & Sherwood")] <- as.numeric("-0.9522")
sources_df$origin_lat[which(sources_df$recorded_origin == "Newark & Sherwood")] <- as.numeric("53.0851")

# Kensington & Chelsea has been geocoded incorrectly, currently US, correct is 51.4991° N, 0.1938° W
sources_df$origin_lon[which(sources_df$recorded_origin == "Kensington & Chelsea")] <- as.numeric("-0.1938")
sources_df$origin_lat[which(sources_df$recorded_origin == "Kensington & Chelsea")] <- as.numeric("51.4991")

# Shrewsbury & Atcham has been geocoded incorrectly, currently US, correct is 52.6650° N, 2.7690° W
sources_df$origin_lon[which(sources_df$recorded_origin == "Shrewsbury & Atcham")] <- as.numeric("-2.7690")
sources_df$origin_lat[which(sources_df$recorded_origin == "Shrewsbury & Atcham")] <- as.numeric("52.6650")

# Weymouth & Portland has been geocoded incorrectly, currently US, correct is 50.6067° N, 2.4645° W
sources_df$origin_lon[which(sources_df$recorded_origin == "Weymouth & Portland")] <- as.numeric("-2.4645")
sources_df$origin_lat[which(sources_df$recorded_origin == "Weymouth & Portland")] <- as.numeric("50.6067")

# Perth & Kinross has been geocoded incorrectly, currently US, correct is 56.3954° N, 3.4284° W
sources_df$origin_lon[which(sources_df$recorded_origin == "Perth & Kinross")] <- as.numeric("-3.4284")
sources_df$origin_lat[which(sources_df$recorded_origin == "Perth & Kinross")] <- as.numeric("56.3954")

# Neath Port Talbot UA has not been geocoded, 51.6917° N, 3.7347° W
sources_df$origin_lon[which(sources_df$recorded_origin == "Neath Port Talbot UA")] <- as.numeric("-3.7347")
sources_df$origin_lat[which(sources_df$recorded_origin == "Neath Port Talbot UA")] <- as.numeric("51.6917")

# Outside UK has been geocoded, remove
sources_df$origin_lat[which(sources_df$recorded_origin == "Outside UK")] <- NA
sources_df$origin_lon[which(sources_df$recorded_origin == "Outside UK")] <- NA

sources_df$origin_lat[which(sources_df$recorded_origin == "South West")] <- NA
sources_df$origin_lon[which(sources_df$recorded_origin == "South West")] <- NA

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

# NN17 3JG has been geocoded incorrectly, 52.4888° N 0.6434° W
waste_facility_lon_lat$site_lon[which(waste_facility_lon_lat$sitepc == "NN17 3JG")] <- as.numeric("-0.6434")
waste_facility_lon_lat$site_lat[which(waste_facility_lon_lat$sitepc == "NN17 3JG")] <- as.numeric("52.4888")

# PE6 7TH has been geocoded incorrectly, 52.5998° N, 0.1848° W
waste_facility_lon_lat$site_lon[which(waste_facility_lon_lat$sitepc == "PE6 7TH")] <- as.numeric("-0.1848")
waste_facility_lon_lat$site_lat[which(waste_facility_lon_lat$sitepc == "PE6 7TH")] <- as.numeric("52.5998")

# PE8 6NH has been geocoded incorrectly, 52.5858° N, 0.4362° W
waste_facility_lon_lat$site_lon[which(waste_facility_lon_lat$sitepc == "PE8 6NH")] <- as.numeric("-0.4362")
waste_facility_lon_lat$site_lat[which(waste_facility_lon_lat$sitepc == "PE8 6NH")] <- as.numeric("52.5858")

# SS16 4UH has been geocoded incorrectly, 51.5401° N, 0.5253° E
waste_facility_lon_lat$site_lon[which(waste_facility_lon_lat$sitepc == "SS16 4UH")] <- as.numeric("0.5253")
waste_facility_lon_lat$site_lat[which(waste_facility_lon_lat$sitepc == "SS16 4UH")] <- as.numeric("51.5401")

# RM13 9DA postcode no longer in use, has been geocoded incorrectly, 51.2917° N 0.1121° E
waste_facility_lon_lat$site_lon[which(waste_facility_lon_lat$sitepc == "RM13 9DA")] <- as.numeric("0.0922")
waste_facility_lon_lat$site_lat[which(waste_facility_lon_lat$sitepc == "RM13 9DA")] <- as.numeric("51.2917")

# DL5 6NB, 54°35'27.6"N 1°33'38.6"W
waste_facility_lon_lat$site_lon[which(waste_facility_lon_lat$sitepc == "DL5 6NB")] <- as.numeric("-1.3338")
waste_facility_lon_lat$site_lat[which(waste_facility_lon_lat$sitepc == "DL5 6NB")] <- as.numeric("54.3527")

# TS25 2BS

# TS6 6UG, TS2 1UE, TS23 4HS, NE21 4SX, BL2 4LT, BL9 8QZ, PR4 0XE, WA11 0RN, SL3 0LP, RG30 3XA, RG10 9YB,
# MK18 2HF, SL2 3SD, HP9 1XD, MK3 5JU, DA2 8EB, OX14 4PW, OX29 5BJ, RH1 4ER, GU10 1PG, RH12 4QD, RH12 3DH,
# GL52 4DG, GL52 7RT, SN11 8RE, SN4 7SB, CB23 9HH, CB23 9HH, YO41 4DB, DN40 1QR, DN38 6AE, DN15 9AP, DN15 0BD,
# YO7 3RB, YO17 8JA, DN14 0RL



# PE18 8EJ postcode no longer in use, 52.1911° N 0.0922° W 
waste_facility_lon_lat$site_lon[which(waste_facility_lon_lat$sitepc == "PE18 8EJ")] <- as.numeric("-0.0922")
waste_facility_lon_lat$site_lat[which(waste_facility_lon_lat$sitepc == "PE18 8EJ")] <- as.numeric("52.1911")



write.csv(waste_facility_lon_lat, file = "waste_facility_lon_lat.csv")


# 3. JOIN LON - LAT INFORMATION TO DF
WD_UK_2018_ori_ll <- dplyr::left_join(WD_UK_2018, sources_df, by="recorded_origin")
WD_UK_2018_ori_ll_dest_ll <- dplyr::left_join(WD_UK_2018_ori_ll, waste_facility_lon_lat, by="sitepc")


## GET DISTANCE ####
WD_UK_2018_ori_ll_dest_ll$ori_dest_distance <- distGeo(WD_UK_2018_ori_ll_dest_ll[26:27], WD_UK_2018_ori_ll_dest_ll[28:29])

# create new columns to calculate in km and convert to miles
WD_UK_2018_ll_dist <- WD_UK_2018_ori_ll_dest_ll %>%
  dplyr::mutate(Dist_in_Kilometres = round(ori_dest_distance/1000, 1),  # calculate km from m
    Dist_in_Miles = round(Dist_in_Kilometres * 0.621371, 1)  # convert to miles
  )

write.csv(WD_UK_2018_ll_dist, file = "WD_UK_2018_clean.csv")
