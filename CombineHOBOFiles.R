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

# Set working directory to folder containing the Excel files - this should be a new 
# directory called 'output' as specified in the trimmining script.
setwd("/path/to/folder/containing/excel/files")

# Set output directory for new files - this insures that we are not overwriting the originals
out_dir <- "/path/to/new/folder/for/output"

# Extract the site, deployment location, and height/depth from each file and create new columns.
# List all .csv files in the folder
file_list <- list.files(pattern = "*.csv")

# Loop over files and extract the desired part of the file name to make new column
for (file_name in file_list) {
  # Read the Excel file
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
  
  # Save the modified data to a new Excel file with a modified file name, and in a new directory
  write.csv(data, paste0("new_", file_name))
}


# Combine files by deployment location so that we have one file per location (e.g., sun, shade, 
# water, etc.)

# List all files in the folder. Will need to do this again since we have a new folder.
file_list <- list.files(pattern = "new_*")

# Combine the data frames into one data frame, adding the grouping variable
combined_df <- bind_rows(dfs, .id = "file_name") %>%
  select(hobo_name, site, location, height, everything())

# Split the combined data frame into separate data frames based on the grouping variable
split_dfs <- split(combined_df, f = combined_df$location)

# Write each data frame to a separate file based on the grouping variable
walk(split_dfs, ~ write.csv(.x, paste0(.x$location[1], ".csv")))


