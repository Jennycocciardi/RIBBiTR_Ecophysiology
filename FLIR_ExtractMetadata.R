# Script to extract metadata from FLIR images as a backup/if needed.
# Author: Michel Ohmer

setwd("")
library(exiftoolr)
files <- list.files(pattern = "*.jpg")
dat <- exif_read(files)

#Takes important information from dat  
MetaData=0
#The original FLIR file name ex: FLIR1232.jpg
MetaData$FileName<-dat$FileName
#The time the FLIR image was take in character string (Note: this is converted to a time below)
MetaData$Date<-dat$DateTimeOriginal

#There the environmental variables need to create the FLIR temperature matrix using Thermimage R
MetaData$FLIRtemp<-dat$AtmosphericTemperature
MetaData$FLIRhumidity<-dat$RelativeHumidity
MetaData$FLIRdistance<-dat$ObjectDistance

#The habitat notes or what is in the FLIR image
MetaData$FLIRhabitat<-dat$ImageDescription

#Identifies the site the FLIR image was taken (Note the term "FIX" is used for items that need to be
# fix in the csv file that is created)
# for(i in 1:length(dat$FileName)){
#   site<-substr(dat$ImageDescription[i],1,3)
#   
#   if(is.na(site)){
#     site<-"FIX"}
#   if(site == "sl "){
#     site<-"la2"}
#   if(site == "ks "){
#     site<-"la3"}
#   if(site == "la "){
#     site<-"FIX"}
#   
#   MetaData$Site[i]<-site
# }

#Creates Date and Time variables
MetaData$datetime<- as.character(dat$DateTimeOriginal)
MetaData$datetime[1]
MetaData$DateOnly<-as.Date(MetaData$datetime, format = "%Y:%m:%d")
MetaData$DateOnly[1]
MetaData$SurveyDate<-MetaData$DateOnly
MetaData$DateTime<-as.POSIXct(MetaData$datetime,format="%Y:%m:%d %H:%M")
MetaData$DateTime[1]

#Creates time variable needed for computations below
d1<- c("1985:07:20 00:00:00")
da1<-toString(d1)
day1<-as.POSIXct(da1,format="%Y:%m:%d %H:%M")
d2<- c("1985:07:20 11:00:00")
da2<-toString(d2)
day2<-as.POSIXct(da2,format="%Y:%m:%d %H:%M")
d3<- c("1985:07:21 00:00:00")
da3<-toString(d3)
day3<-as.POSIXct(da3,format="%Y:%m:%d %H:%M")
d4<- c("1985:07:20 19:00:00")
da4<-toString(d4)
day4<-as.POSIXct(da4,format="%Y:%m:%d %H:%M")
d5<- c("1985:07:20 08:00:00")
da5<-toString(d5)
day5<-as.POSIXct(da5,format="%Y:%m:%d %H:%M")

#Fixes the FLIR date with the Survey Date if taken after midnight
for(j in 1:length(dat$FileName)){
  mid <- c(substring(MetaData$datetime[j],1,10), "00:00:00")
  mn<-toString(mid)
  midnight<-as.POSIXct(mn,format="%Y:%m:%d, %H:%M")
  if(MetaData$DateTime[j]-midnight < (day2-day1) ){
    MetaData$SurveyDate[j]<-MetaData$DateOnly[j]-(day3-day1)
  }
  
  #FIX
  #Determines in it was a Day or Night survery
  if(MetaData$DateTime[j]-midnight < (day4-day1) && MetaData$DateTime[j]-midnight > day5-day1){
    MetaData$DayNigt[j]<-"Day"} # for times close to midnight this makes a day (FIX)
    else{
      MetaData$DayNigt[j]<-"Night"
  }
}

#Identifies Macro/Micro FLIR image types
# for(h in 1:length(dat$FileName)){
#   MetaData$ImageType[h]<- "Micro"}
# MetaData$ImageType[grep("macro", MetaData$FLIRhabitat)]<-"Macro"

#colnames(MetaData) <- c("File Name","Date Time","Temperature","Humidity","Location","Distance",)

write.csv(MetaData, file="test.csv")

