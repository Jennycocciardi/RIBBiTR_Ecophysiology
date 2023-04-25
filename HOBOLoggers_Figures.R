# Exploratory figures for HOBO logger data from study sites within RIBBiTR.
# Author: Jenny Cocciardi
# email: jmcoccia@olemiss.edu
# Date: 2023-April-25

# HOBO logger data should be combined into one file seperated by study site, sampling period,
# and deployment location (sun, shade, water, soil).

# Load necessary libraries
library(ggplot2)
library(tidyr)

# set working directory and load file
data <- read.csv('water.csv')

# Make sure date.time column is recognized as.date
data$date.time <- as.POSIXct(data$date.time, format = "%Y-%m-%d %H:%M:%S")
# data$date.time <- as.POSIXct(data$date.time, format = "%m/%d/%y %H:%M")
data$date.time <- force_tz(data$date.time, tzone = "Brazil/DeNoronha")

# Create line plot
ggplot(data, aes(x = date.time, y = temp.C, group = interaction(site, height), color = height)) +
  geom_line() +
  facet_grid(rows = vars(site)) +
  labs(x = "Date", y = "Temperature (C)", color = "Height/depth", title = "Brazil: water") +
  scale_color_manual(values = c("#336600", "#CC9900")) + #"#336600", "#CC9900", ##993300, #3399FF
  scale_x_datetime(date_labels =  "%b-%d-\n%Y", 
                   date_breaks = "2 weeks", 
                   minor_breaks = NULL) +
  scale_y_continuous(breaks=seq(10,30,5)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        panel.background = element_rect(fill = "white"),
        strip.background = element_rect(fill = "linen"))
