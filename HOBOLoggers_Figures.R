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
data <- read.csv('sun.csv')

# Make sure date.time column is recognized as.date
# check structure
str(data) #make sure variables are recognized as they should be
# data$site <- as.character(data$site)
# data$date.time <- as.POSIXct(data$date.time, format = "%Y-%m-%d %H:%M:%S")
data$date.time <- as.POSIXct(data$date.time, format = "%m/%d/%y %H:%M")
data$date.time <- force_tz(data$date.time, tzone = "America/Los_Angeles") 
  # "Etc/GMT+4", "Brazil/DeNoronha", "America/Los_Angeles", "America/Panama"

# Line plot by site and deployment location
ggplot(data, aes(x = date.time, y = temp.C, group = interaction(site, height), color = height)) +
  geom_line() +
  facet_grid(rows = vars(site)) +
  labs(x = "Date", y = "Temperature (C)", color = "Height/depth", title = "Brazil: sun") +
  scale_color_brewer(palette = "YlOrBr") +
  scale_x_datetime(date_labels =  "%b-%d-\n%Y", 
                   date_breaks = "2 weeks", 
                   minor_breaks = NULL) +
  scale_y_continuous(breaks=seq(10,30,5)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        panel.background = element_rect(fill = "white"),
        strip.background = element_rect(fill = "linen"))

library(RColorBrewer)
display.brewer.all(colorblindFriendly = TRUE)
library(gridExtra)

data <- subset(data, hobo_name != "70470_sun_50cm")
data <- subset(data, hobo_name != "70449_sun_50cm")
data <- subset(data, hobo_name != "52127_sun_50cm")

# Line plot by deployment location
ggplot(data = subset(data, grepl("\\b50cm\\b", height)), # when need to subset data based on height/depth
# ggplot(data, 
  aes(x = date.time, y = temp.C, group = interaction(site, height), color = site, linetype = height)) +
  geom_line() +
  labs(x = "", y = "Temperature (C)", color = "Sites", title = "Sierra Nevada, sun (50cm)") +
  guides(color = guide_legend(ncol=2),
         linetype = "none") +
  scale_x_datetime(date_labels =  "%b-%d-%y", 
                   breaks = seq(min(data$date.time), max(data$date.time), by ="2 weeks"),
                   expand = c(0, 0)) +
  scale_y_continuous(breaks=seq(-10,55,5),limits = c(-10,55)) +
  # scale_color_brewer(palette = "Greens", direction=-1) + # for shade
  # scale_color_manual(values = c("#663300","#993300", "#CC6600", "#CC9900", "#FFCC66" )) + #for soil, 
  # scale_color_brewer(palette = "Blues", direction=-1) + # for water
  scale_color_brewer(palette = "YlOrRd", direction=-1) + # for sun
  # scale_color_manual(values = colorRampPalette(brewer.pal(9, "Blues"))(11)) + #for water, if more variables then allowed for pallet
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.title = element_text(size=9),
        axis.text.x = element_text(size=8),
        plot.title = element_text(size=11, face="bold"),
        legend.text = element_text(size=8),
        legend.title = element_text(size=9),
        legend.position = c(0.99, 0.99),
        legend.justification = c("right", "top"),
        legend.key.size = unit(0.5, 'lines'))

# Use the 'here' package to keep figures organized in github directory
# library(here)
ggsave(here("/Users/jennycocciardi/Desktop", "SN_sun_50cmB.png"), 
       width=5, height=3, dpi=300) #setting plot width to reflect timeline of data


# Line plot by deployment location within one site

# set working directory and load file
data <- read.csv('combined.csv')

# Make sure date.time column is recognized as.date
# check structure
str(data) #make sure variables are recognized as they should be
# data$site <- as.character(data$site)
data$date.time <- as.POSIXct(data$date.time, format = "%Y-%m-%d %H:%M:%S")
# data$date.time <- as.POSIXct(data$date.time, format = "%m/%d/%y %H:%M")
data$date.time <- force_tz(data$date.time, tzone = "Etc/GMT+4") 
# "Etc/GMT+4", "Brazil/DeNoronha", "America/Los_Angeles", "America/Panama"

# plot for combined and smoothed data
ggplot(data = subset(data, grepl("RV", site) & grepl("\\b0cm\\b|\\b5cm\\b|\\b-5cm\\b", height)), # when need to subset one site data
       # ggplot(data, 
       aes(x = date.time, y = temp.C, group = interaction(location, height), color = location)) +
  geom_smooth(se = FALSE) +
  labs(x = "", y = "Temperature (C)", color = "Location", title = "Microhabitat temperature data
Pennsylvania (RV)") +
  scale_x_datetime(date_labels =  "%b-%d-%y", 
                   breaks = seq(min(data$date.time), max(data$date.time), by ="2 weeks"),
                   expand = c(0, 0)) +
  scale_y_continuous(breaks=seq(2.5,22.5,2.5),limits = c(2.5,22.5)) +
  scale_color_manual(breaks = c("shade", "sun", "soil", "water"),
                     values = c("#FFCC00","#009900","#993300","#0066cc"),
                     labels = c("sun", "shade", "soil", "water")) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.title = element_text(size=9),
        axis.text.x = element_text(size=8, angle = 45 ,hjust = 1),
        plot.title = element_text(size=11, face="bold"),
        legend.text = element_text(size=8),
        legend.title = element_text(size=9),
        legend.position = c(0.99, 0.99),
        legend.justification = c("right", "top"),
        legend.key.size = unit(0.5, 'lines'))

ggsave(here("/Users/jennycocciardi/GitHub/RIBBiTR_Ecophysiology/Figures", "PA_RV_combined.png"), 
       width=4, height=4, dpi=300) #setting plot width to reflect timeline of data

# plot for smoothed data seperated by height at the same site
ggplot(data = subset(data, grepl("RV", site) & grepl("soil", location)), # when need to subset one site data
       # ggplot(data, 
       aes(x = date.time, y = temp.C, group = height, color = height)) +
  geom_smooth(se = FALSE) +
  labs(x = "", y = "Temperature (C)", color = "Height", title = "Soil: Pennsylvania (RV)") +
  scale_x_datetime(date_labels =  "%b-%d-%y", 
                   breaks = seq(min(data$date.time), max(data$date.time), by ="2 weeks"),
                   expand = c(0, 0)) +
  scale_y_continuous(breaks=seq(2.5,22.5,2.5),limits = c(2.5,22.5)) +
  scale_color_manual(breaks = c("-5cm","-10cm"),
                     values = c("#993300", "#CC6600")) + 
  theme_bw() +
  theme(panel.grid = element_blank(),
        axis.title = element_text(size=8),
        axis.text.x = element_text(size=8, angle = 45 ,hjust = 1),
        plot.title = element_text(size=10, face="bold"),
        legend.text = element_text(size=8),
        legend.title = element_text(size=9),
        legend.position = c(0.99, 0.99),
        legend.justification = c("right", "top"),
        legend.key.size = unit(0.5, 'lines'))

ggsave(here("/Users/jennycocciardi/GitHub/RIBBiTR_Ecophysiology/Figures", "PA_RV_soil.png"), 
       width=3, height=3, dpi=300) #setting plot width to reflect timeline of data
