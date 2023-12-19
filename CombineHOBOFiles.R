# Combine RIBBiTR HOBO files into one file, organized by deployment location and for each 
# study system, also add in a column for height or depth of each logger.
# Author: Jenny Cocciardi
# email: jmcoccia@olemiss.edu
# Date: 2023-April-18

# Load required packages
library(tidyverse)
library(readxl)
library(writexl)
library(dplyr)

# Set working directory to folder containing data files - this should be a new 
# directory called 'output' as specified in the trimming script.
setwd("/path/to/folder/containing/files")


# Extract the site, deployment location, and height/depth from each file and create new columns.
# List all .csv files in the folder
file_list <- list.files(pattern = "*.csv")


# Loop over files and extract the desired part of the file name to make new column
for (file_name in file_list) {
  # Read the file
  data <- read.csv(file_name)

  # Extract site from file name *note, this will only work if files names are 
  # standardized in the format: 'Site_DeploymentLocation_heightORdepth'
  site <- sub("(.*?)_.*", "\\1", basename(file_name))
    
  # Extract deployment location from file name *note, this will only work if files names are 
  # standardized in the format: 'Site_DeploymentLocation_heightORdepth'
  location <- sub(".*?_(.*?)_.*", "\\1", basename(file_name))
  
  # Extract height from file name *note, this will only work if files names are 
  # standardized in the format: 'Site_DeploymentLocation_heightORdepth'
  height <- sub(".*?_.*?_(.*?)_.*", "\\1", basename(file_name))
  
  # Create new columns in the data and assign the extracted part of the file name
  data$site <- site
  data$location <- location
  data$height <- height
  # Adding in a column for hobo logger/file name to conserve as a link to metadata and original files
  # This needs to be different from file_name, which is a part of a the function for file_list
  # Get the file name without extension
  file_name_without_ext <- file_path_sans_ext(basename(file_name))
  data$hobo_name <- file_name_without_ext
  data$hobo_name <- gsub("\\_trimmed", "", data$hobo_name)
  
  # Save the modified data to a new file with a modified file name
  write.csv(data, paste0("new_", file_name))
}



# Combine files

# List all files in the folder. Will need to do this again since we have newly created files.
file_list <- list.files(pattern = "new_*")

# Combine the data frames into one data frame, adding the grouping variable
combined_df <- bind_rows(lapply(file_list, read.csv)) %>%
  select(hobo_name, site, location, height, everything())

# if we cannot bind because the rows are not the same 'character/integar' type... use this command:
  # combined_df <- bind_rows(lapply(file_list, function(file) read.csv(file, colClasses = "character"))) %>%
  # select(hobo_name, site, location, height, everything())



# Prepare the combined.csv file for input into RIBBiTR database
    # combined_df should have these columns in this order: 
    # StudyArea, hobo_name, Site, Location, Height, DateTime, Temperature, TimeZone, Intensity.Lux, RH, DewPoint
    # Select these columns to keep:
columns_to_keep <- c("StudyArea","hobo_name", "Site", "Location", "Height", "DateTime", 
                     "Temperature", "TimeZone", "Intensity.Lux", "RH", "DewPoint")
    
    # Rename columns and get rid of extra columns, add in StudyArea
combined_df_database_ready <- combined_df %>%
  rename(
    Site = site,
    Location = location,
    Height = height,
    DateTime = date.time,
    Temperature = temperature,
    TimeZone = timezone,
    Intensity.Lux = intensity.lux,
    RH = rh,
    DewPoint = DewPt...C)  %>%
  mutate(StudyArea = 'PA') %>% #add a new column 'StudyArea' to indicate which study system the data 
                           #is for - either PA, Brazil, Panama, SierraNevada 
  select(columns_to_keep) #select the columns to keep

# Write one overall dataframe
write.csv(combined_df_database_ready, file = "combined.csv", row.names = FALSE)

# Split the combined data frame into separate data frames based on the grouping variable
split_dfs <- split(combined_df, f = combined_df$location)

# Write each data frame to a separate file based on the grouping variable
walk(split_dfs, ~ write.csv(.x, paste0(.x$location[1], ".csv")))


