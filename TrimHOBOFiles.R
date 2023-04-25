# Trim RIBBiTR HOBO files to date and time of deployement in field.
# Author: Jenny Cocciardi
# email: jmcoccia@olemiss.edu
# Date: 2023-April-19

# Before starting, make sure that all files are standardized to the same timezone of where
# the loggers were deployed.

library(dplyr)

# Set the directory path
directory <- "/path/to/folder/containing/hobo/data"

# Loop over files in the directory
for (filename in list.files(directory, pattern = "\\.csv$")) {
  # Read the .csv file (if files are exported as .xlsx, parts of this code will have to be modified to reflect that)
  data <- read.csv(file.path(directory, filename))
  
  # Rename the column, this will change based on timezone deployed
  colnames(data)[which(colnames(data) == "Date.Time..GMT.05.00")] <- "date.time.GMT.minus5"
  colnames(data)[which(colnames(data) == "Temp...C")] <- "temp.C"
  colnames(data)[which(colnames(data) == "RH...")] <- "RH"
  colnames(data)[which(colnames(data) == "DewPoint...C")] <- "dewpt.C"
  
  # Write the updated xlsx file
  write.csv(data, file.path(directory, filename), row.names = FALSE)
}

# Check to make sure all files have new 'date.time' column
file_list <- list.files(pattern = "*.csv")

for (file in file_list) {
  # read in the data
  data <- read.csv(file)
  
  # check if "date.time" is in the column names
  if ("date.time.GMT.minus2" %in% colnames(data)) {
    print(paste0("File ", file, " has the 'date.time' column."))
  } else {
    print(paste0("File ", file, " does not have the 'date.time' column."))
  }
}

library(tidyverse)
library(lubridate)
library(tools)
library(xts)

# To trim HOBO data based on when the logger was deployed and collected from the field,
# first create a single .csv file with the name of the each file, the time it was deployed,
# and the time is was removed from the field. It should be in the format:
  # 'file_name, start_date.time, stop_date.time'

trimming_info <- read.csv("trimming_info.csv")

# Make sure date and time are in a common format. This will depend on how data is exported
# from hoboWare and how the start and data time for deployement are inputted in the 
#'hobo deployement logger info' spreadsheet.
# For example, if date.time of start and stop for loggers is currently formatted to 
# mdy hms, we will need to change to YMD HMS. To change this: onvert the character 
# vector to POSIXct format (may need to try these formats depending on how they were inputted)
# into excel...tryFormats = c("%Y-%m-%d %H:%M:%OS","%Y/%m/%d %H:%M:%OS", "%Y-%m-%d %H:%M",
#                                "%Y/%m/%d %H:%M", "%Y-%m-%d", "%Y/%m/%d")

trimming_info$start_date.time <- as.POSIXct(trimming_info$start_date.time, 
                                            format = "%m/%d/%y %H:%M")
# This displays timezone as UTC, so change this based on timezone of data collection.
# Use the below function to do this, along with codes for the timezone as found in :
# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones 
trimming_info$start_date.time <- force_tz(trimming_info$start_date.time, 
                                          tzone = "Brazil/DeNoronha")
trimming_info$stop_date.time <- as.POSIXct(trimming_info$stop_date.time, 
                                            format = "%Y-%m-%d %H:%M")
trimming_info$stop_date.time <- force_tz(trimming_info$stop_date.time, 
                                         tzone = "Brazil/DeNoronha")


## Create and set output directory for new files - this insures that we are not overwriting the originals
 dir.create("output")
 # out_dir <- "/path/to/new/folder/for/output" --> if want to put files into new directory

# Loop over each file in the directory
file_list <- list.files(pattern = "*.csv")

for (file_name in file_list) {
  if (endsWith(file_name, ".csv") & file_name != "trimming_info.csv"
    & file_name != "BO01_sun_50cm.csv") {
    
    # Get the file name without extension
    file_name_without_ext <- file_path_sans_ext(basename(file_name))
    # Check if the file is included in the trimming information file
    if (file_name_without_ext %in% trimming_info$hobo_name) {
      # Read the data into R
      data <- read.csv(file_name)
  
  # Convert to POSIXct format (the name of data.time colomn in data files will differ
      # depending on the timezone and so will need to adjust to fit data)
  data$date.time.GMT.minus2 <- as.POSIXct(data$date.time.GMT.minus2, 
                                             format = "%y/%m/%d %H:%M:%S")
  data$date.time.GMT.minus2 <- force_tz(data$date.time.GMT.minus2, 
                                           tzone = "Brazil/DeNoronha")
  
  # Get the trimming information for this file
  trimming <- trimming_info[trimming_info$hobo_name == file_name_without_ext, ]
  
  # Filter the data based on the trimming start and end times
  # data.trimmed <- data[data$date.time.GMT.minus5 >= trimming$start_date.time &
  #                       data$date.time.GMT.minus5 <= trimming$stop_date.time, ]
  
  # If only one side needs trimming
  data.trimmed <- data[data$date.time.GMT.minus2 >= trimming$start_date.time, ]
  
  # Write the trimmed data to a new file
  write.csv(data.trimmed, file.path(out_dir, paste0(file_name_without_ext,"_trimmed.csv")))
    }
  }
}
