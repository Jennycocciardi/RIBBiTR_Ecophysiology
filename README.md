# RIBBiTR_Ecophysiology :frog:

This repository contains important information for collecting, storing, and analyzing environmental data (via HOBO loggers) and thermal images for sites collected as part of RIBBiTR. 

___
## HOBO DATA

HOBO data loggers will be deployed within all study systems to collect detailed measurements of amphibian-relevant microclimates, and to verify
temperatures downscaled from global temperature databases. HOBO data loggers will record microclimate at 3-5 key sites within each study system,
focusing on primary survey sites. 

Please refer to the 'RIBBiTR: Core Protocols' document for setting up and deploying HOBO loggers. **All HOBO logger metadata should be recorded in the ['HOBO logger deployment data'](https://docs.google.com/spreadsheets/d/1gfQ0dcc5GuQWfGMUiJk_oN1VKh7THmMT/edit?usp=sharing&ouid=106517242061380573521&rtpof=true&sd=true) spreadsheet
found within the Ecophysiology team's google drive folder.**

### Downloading HOBO data

To download data from loggers, you can use the waterproof data shuttle (U-DTW-1 shuttle – NOTE: requires HOBOware Pro software) which can store 
data until you reach a computer, or the USB shuttle (BASE-U-4) directly connected to a computer. Bluetooth data loggers are launched and data can 
be downloaded via the HOBOconnect App.

### Storing HOBO data :file_folder:

:file_folder: **Storage**: Please store all HOBO data as .hobo files. All HOBO data will be stored in the ['HOBO Logger Data'](https://drive.google.com/drive/folders/1oFI-eyaX6w-DHK5Gl44ThiE0Vf8JFNVv?usp=share_link) google drive folder. To standardize storage, please create a new folder within the directory for your study system (i.e., Brazil, Panama, etc.) with the following naming convention... ```'HOBOS_MonthYrDeployed_MonthYrStopped'```. The date should be in the 'Month,Year' format (for example, Nov22), and all files for that sampling time-period/season can be housed within this newly-created directory.

:label: **File naming system**: Individal .hobo files should be named with the site number, deployment location, and deployement depth or height as follows: 
```SiteID_DeployementLocation_depthORheight``` for example, *'PA01_shade_15cm.hobo'*. **This name should also match the '*Hobo logger name*' colomn in the ['HOBO logger deployment data'](https://docs.google.com/spreadsheets/d/1gfQ0dcc5GuQWfGMUiJk_oN1VKh7THmMT/edit?usp=sharing&ouid=106517242061380573521&rtpof=true&sd=true) spreadsheet.** 

Deployment location and height/depth categories are: 
  ```
     sun_0cm        shade_0cm         soil_-5cm       water_5cm
     sun_25cm       shade_25cm        soil_-10cm      water_20cm
     sun_50cm       shade_50cm                        water_35cm                 
  ```  

### Trimming HOBO data :scissors:

It is very important to make sure that all files are standardized to the same timezone before trimming. This can be automated at some point, but 
I'm still figuring out how to loop this across all files within one folder where date-time column name differs. Also prior to trimming files, 
the date-time column in files should be standardized. This can be easily done using the ['*TrimHOBOFiles.R*'](https://github.com/Jennycocciardi/RIBBiTR_Ecophysiology/blob/main/TrimHOBOFiles.R) script, which includes code for standardizing the column name and
timezone across files, and code for trimming data.

The ['*TrimHOBOFiles.R*'](https://github.com/Jennycocciardi/RIBBiTR_Ecophysiology/blob/main/TrimHOBOFiles.R) script requires an additional metadata file
that contains logger start and stop times to automate trimming. This files should be named '*trimming_info.csv*' and should be placed within the same
directory as data files. It should be in the format:
```
file_name, start_date.time, stop_date.time
```
The file_name column will be the reference ID, so make sure this column matches the data file names precisely.

### Concatenating HOBO data

We will combine data across sites from the same deployement locations (e.g., sun, shade) for analysis purposes. Before starting, make sure that 
individual .hobo files are named *'SiteID_DeployementLocation_depthORheight'*. The ['*CombineHOBOfiles.R*'](https://github.com/Jennycocciardi/RIBBiTR_Ecophysiology/blob/main/CombineHOBOFiles.R) script can then be used to create one .csv file per deployemnet location for each study system. 

___
## THERMAL IMAGES

This [sign-out sheet](https://docs.google.com/spreadsheets/d/17hg0DTGzJy9akMPVVxuNyOvGWWmSTO8_/edit?usp=sharing&ouid=106517242061380573521&rtpof=true&sd=true) has information on where thermal camera's associated with
RIBBiTR are housed or which teams are using them. You can refer to it to organize obtaining a thermal camera for 
field sites and seasons.

### Setting up thermal cameras :camera:

More information on setting up thermal cameras can be found in the 'RIBBiTR: Core Protocols' document.

### Metadata to collect in the field

More information on setting up thermal cameras can be found in the 'RIBBiTR: Core Protocols' document.

### Downloading thermal images


### Storing thermal images 	:file_folder:

:file_folder: **Storage**: All thermal images/FLIR photos will be stored in the ['Thermal Images_FLIR photos'](https://drive.google.com/drive/folders/1_8dMZ86P7BmLn0GG9zTTS8RomSaohe_2?usp=sharing) google drive folder. To standardize
storage, please create a new folder within your study system (i.e., Brazil, Panama, etc.) directory with the following
naming convention... *'DATE_Site'*. The date should be the date the photos were taken in 'YR,MO,DAY' format (for example, 220725),
and the site should be the site name. 

:label: **File naming system**: Individal thermal images should be named with the Transect # or Site Name, the transect meter the photo
was taken at, the cardinal direction in which the photo was taken, and the photo ID as follows: *'Site_transect-m_direction_imageID'*. For example, a thermal image taken at Sante Fe at meter 60 along the transect and facing E should be *'SanteFe_60m_E_4790'*.


