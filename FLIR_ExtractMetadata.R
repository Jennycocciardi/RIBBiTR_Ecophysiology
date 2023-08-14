# Script to extract metadata from FLIR images as a backup/if needed.
# Authors: Jenny Cocciardi and Michel Ohmer

setwd("")
library(exiftoolr)

files <- list.files(pattern = "*.jpg")
dat <- exif_read(files)

# Make a new dataset with important information we want 
metadata=0

#The original FLIR file name ex: FLIR1232.jpg
metadata$FileName<-dat$FileName

#The habitat notes or what is in the FLIR image
metadata$FLIRhabitat<-dat$ImageDescription

#Creates Date and Time variables
metadata$DateTime <- as.POSIXct(dat$DateTimeOriginal,format="%Y:%m:%d %H:%M")
metadata$DateTime[1]
metadata$SurveyDate <- as.Date(dat$DateTimeOriginal, format = "%Y:%m:%d")

#Get coordinates
metadata$GPSLatitude <- as.numeric(dat$GPSLatitude)
metadata$GPSLongitude <- as.numeric(dat$GPSLongitude)
metadata$GPSTimeStamp < as.character(dat$GPSTimeStamp)


#Get environmental variables needed to create the FLIR temperature matrix using Thermimage R
metadata$FLIRtemp<-dat$AtmosphericTemperature
metadata$FLIRhumidity<-dat$RelativeHumidity
metadata$FLIRdistance<-dat$ObjectDistance


write.csv(metadata, file="metadata.csv")
