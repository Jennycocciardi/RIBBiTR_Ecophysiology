# Trim RIBBiTR HOBO files to date and time of deployement in field.
# Author: Jenny Cocciardi
# email: jmcoccia@olemiss.edu
# Date: 2023-April-19

library(dplyr)
library(tidyverse)


# Loop over each file in the directory to create a file list
file_list <- list.files(pattern = "*.csv")

# Before starting, make sure that all files are standardized to the same timezone by 
# checking timezone column.
for (file_name in file_list) {
  # Read the CSV file
  data <- read.csv(file_name)
  
  # Get the column names that start with the desired string
  desired_string <- "Date"
  filtered_columns <- names(data)[startsWith(names(data), desired_string)]
  
  # Print the filtered column names
  print(paste0(file_name, " is in timezone ", filtered_columns))
  
}

# Standardize to same timezone if needed.

# Now, loop over files to standardize columns
for (file_name in file_list) {
  if (endsWith(file_name, ".csv") & file_name != "trimming_info.csv") {
  # Read the .csv file (if files are exported as .xlsx, parts of this code will have to be modified)
  data <- read.csv(file_name)
  
  # Create column with timezone info
  data$timezone <- sub("\\.(.*)\\.", "-\\1:", sub(".*\\.(GMT\\..*)", "\\1", names(data)[1]))
  
  # Rename the columns
  colnames(data)[which(colnames(data) == grep("Date", names(data), value = TRUE))] <- "date.time"
  colnames(data)[which(colnames(data) == "Temp...C")] <- "Temperature"
  colnames(data)[which(colnames(data) == "RH...")] <- "RH"
  colnames(data)[which(colnames(data) == "DewPoint...C")] <- "DewPoint"
  colnames(data)[which(colnames(data) == "Intensity..Lux")] <- "Intensity.Lux"
  
  # Write the data to a new file
  write.csv(data, file_name)
  }
  }

# Check to make sure all files have new 'date.time' column
for (file in file_list) {
  # read in the data
  data <- read.csv(file)
  
  # check if "date.time" is in the column names
  if ("date.time" %in% colnames(data)) {
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
  # 'hobo_name, start_date.time, stop_date.time'

trimming_info <- read.csv("trimming_info.csv")

# I've found the field teams may not record exactly when the loggers are deployed/removed from the field,
# so it's best to trim the data by ~5 hrs to remove any inaccuracies. 

# Make sure date and time are in a common format and recognized as date in R. 
# To do this, use the as.POSIXct and specify the current format the date.time is in.
# For example, if date.time of start and stop for loggers is currently formatted to 
# m/d/y h:m, we will need to use format = "%m/%d/%Y %H:%M")
# This will depend on how data is exported from HOBOware and how the start and stop time for deployment 
# are inputted into the hobo deployment logger info' spreadsheet. 
# More info can be found here: https://www.stat.berkeley.edu/~s133/dates.html

trimming_info$start_date.time <- as.POSIXct(trimming_info$start_date.time, 
                                            format = "%m/%d/%y %H:%M")
# Change 'start_date.time' and 'stop_date.time' info based on timezone of data collection.
# Use this function OlsonNames()to check which timezones are recognized by force_tz.
# (This website https://en.wikipedia.org/wiki/List_of_tz_database_time_zones is also useful).

# 'force_tz' will not convert the time but it will force the timezone.

# options used for RIBBiTR data: "Etc/GMT+5", "Brazil/DeNoronha", "America/Los_Angeles", "America/Panama"

trimming_info$start_date.time <- force_tz(trimming_info$start_date.time, 
                                          tzone = "Etc/GMT+5")
trimming_info$stop_date.time <- as.POSIXct(trimming_info$stop_date.time, 
                                            format = "%m/%d/%y %H:%M")
trimming_info$stop_date.time <- force_tz(trimming_info$stop_date.time, 
                                         tzone = "Etc/GMT+5")


## Create and set output directory for new files - this insures that we are not overwriting the originals
 dir.create("output")
 out_dir <- "/path/to/new/folder/for/output"

# Loop over each file in the directory
file_list <- list.files(pattern = "*.csv")

for (file_name in file_list) {
  if (endsWith(file_name, ".csv") & file_name != "trimming_info.csv") {
    
    # Get the file name without extension
    file_name_without_ext <- file_path_sans_ext(basename(file_name))
    # Check if the file is included in the trimming information file
    if (file_name_without_ext %in% trimming_info$hobo_name) {
      # Read the data into R
      data <- read.csv(file_name)
  
  # Convert to POSIXct format to match trimming_info.csv file 
      # (the name of data.time colomn in data files will differ depending on the timezone)
  data$date.time <- as.POSIXct(data$date.time,format = "%y/%m/%d %H:%M:%S")
  data$date.time <- force_tz(data$date.time, tzone = "Etc/GMT+5")
  
  # Get the trimming information for this file
  trimming <- trimming_info[trimming_info$hobo_name == file_name_without_ext, ]
  
  # Filter the data based on the trimming start and end times
   data.trimmed <- data[data$date.time > trimming$start_date.time &
                       data$date.time < trimming$stop_date.time, ]
  
  # If only one side needs trimming (depending on whether loggers were started/stopped in field)
  # data.trimmed <- data[data$date.time >= trimming$start_date.time, ]
  
  # Write the trimmed data to a new file
  write.csv(data.trimmed, file.path(out_dir, paste0(file_name_without_ext,"_trimmed.csv")))
    }
  }
}
