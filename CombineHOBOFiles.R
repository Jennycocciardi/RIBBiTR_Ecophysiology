# Combine RIBBiTR HOBO files into one file, organized by deployment location and for each 
# study system, also add in a column for height or depth of each logger.
# Author: Jenny Cocciardi
# Date: 2023-April-18

# Load required packages
library(tidyverse)
library(readxl)
library(writexl)
library(dplyr)

# Set working directory to folder containing the Excel files
setwd("/path/to/folder/containing/excel/files")

# Set output directory for new files - this insures that we are not overwriting the originals
out_dir <- "/path/to/new/folder/for/output"

# Extract the site, deployment location, and height/depth from each file and create new columns.
# List all Excel files in the folder
file_list <- list.files(pattern = "*.xlsx")

# Loop over files and extract the desired part of the file name to make new column
for (file_name in file_list) {
  # Read the Excel file
  data <- read_excel(file_name)

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
  # Adding in a column for file name to conserve in case we need to reference original files
  # This needs to be different from file_name, which is a used as apart of a function for file_list
  data$file <- file_name
  
  # Save the modified data to a new Excel file with a modified file name, and in a new directory
  write_xlsx(data, paste0(out_dir, "new_", file_name))
}


# Combine files by deployment location so that we have one file per location (e.g., sun, shade, 
# water, etc.)

# Set working directory to new folder
setwd("/path/to/new/folder")
# List all Excel files in the folder. Will need to do this again since we have a new folder.
file_list <- list.files(pattern = "*.xlsx")

# Create a list of data frames, with each data frame corresponding to one Excel file
dfs <- lapply(file_list, read_excel)

# Combine the data frames into one data frame, adding the grouping variable
combined_df <- bind_rows(dfs, .id = "file_name") %>%
  select(site, location, height, file, everything())

# Split the combined data frame into separate data frames based on the grouping variable
split_dfs <- split(combined_df, f = combined_df$location)

# Write each data frame to a separate file based on the grouping variable
walk(split_dfs, ~ write_csv(.x, paste0(.x$location[1], ".csv")))
