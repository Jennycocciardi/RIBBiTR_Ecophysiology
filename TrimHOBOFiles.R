# Trim RIBBiTR HOBO files to date and time of deployement in field.
# Author: Jenny Cocciardi
# email: jmcoccia@olemiss.edu
# Date: 2023-April-19

# Before starting, make sure that all files are standardized to the same timezone and that
# the 'datetime' column is named the same.
  # This can be automated at some point, but I'm still figuring out how to automate this across 
  # all files within one folder where date-time column name differs.
library(readxl)
library(openxlsx)

# Set the directory path
directory <- "/Users/jennycocciardi/Desktop/HOBOs_Aug22-Oct22"

# Loop over files in the directory
for (filename in list.files(directory, pattern = "\\.xlsx$")) {
  # Read the xlsx file
  data <- read_excel(file.path(directory, filename))
  
  # Rename the column
  colnames(data)[which(colnames(data) == "Date-Time (PDT)")] <- "date.time"
  
  # Write the updated xlsx file
  write.xlsx(data, file.path(directory, filename), row.names = FALSE)
}

# Check to make sure all files have new 'date.time' column
file_list <- list.files(pattern = "*.xlsx")

for (file in file_list) {
  # read in the data
  data <- read_excel(file)
  
  # check if "date.time" is in the column names
  if ("date.time" %in% colnames(data)) {
    print(paste0("File ", file, " has the 'date.time' column."))
  } else {
    print(paste0("File ", file, " does not have the 'date.time' column."))
  }
}

library(tidyverse)
library(readxl)
library(lubridate)

# To trim HOBO data based on when the logger was deployed and collected from the field,
# first create a single .csv file with the name of the each file, the time it was deployed,
# and the time is was removed from the field. It should be in the format:
  # 'file_name, date.time.start, date.time.stop'

trimming_info <- read.csv("trimming_info.csv")

# Make sure date and time are in a common format. This may depend on how it was inputed
# by the field team so may differ between study areas.
# For example, Sierra Nevada date.time of start and stop for loggers is currently
# formatted as: mdy hms. To change this:
# Convert the character vector to POSIXct format
trimming_info$date.time_start <- as.POSIXct(trimming_info$date.time_start, 
                                            format = "%m/%d/%y %H:%M", tz="UTC")
trimming_info$date.time_stop <- as.POSIXct(trimming_info$date.time_stop, 
                                            format = "%m/%d/%y %H:%M", tz="UTC")
trimming_info$date.time_start <- ymd_hms(trimming_info$date.time_start)
trimming_info$date.time_stop <- ymd_hms(trimming_info$date.time_stop)

## Set output directory for new files - this insures that we are not overwriting the originals
# out_dir <- "/path/to/new/folder/for/output" --> if want to put files into new directory

# Loop over each file in the directory
file_list <- list.files(pattern = "*.xlsx")

for (file_name in file_list) {
  if (endsWith(file_name, ".xlsx") & file_name != "trimming_info.csv") {
    # Check if the file is included in the trimming information file
    if (file_name %in% trimming_info$file_name) {
      # Read the data into R
      data <- read_excel(file_name)
  
  # Convert to POSIXct format
  data$date.time <- ymd_hms(data$date.time, tz = "UTC")
  
  # Get the trimming information for this file
  trimming <- trimming_info[trimming_info$file_name == file_name, ]
  
  # Filter the data based on the trimming start and end times
  data.trimmed <- data[data$date.time >= trimming$date.time_start &
                         data$date.time <= trimming$date.time_stop, ]
  
  # Write the trimmed data to a new file
  write_xlsx(data.trimmed, paste0("trimmed_", file_name))
    }
  }
}

