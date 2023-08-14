# RIBBiTR_Ecophysiology :frog:

This repository contains important information for collecting, storing, and analyzing environmental data (via HOBO loggers) and thermal images for sites collected as part of RIBBiTR. 

___
## HOBO DATA - FOR FIELD TEAMS

HOBO data loggers will be deployed within all study systems to collect detailed measurements of amphibian-relevant microclimates, and to verify
temperatures downscaled from global temperature databases. HOBO data loggers will record microclimate at 3-5 key sites within each study system,
focusing on primary survey sites. 

***All HOBO logger metadata should be recorded in the ['HOBO logger deployment data'](https://docs.google.com/spreadsheets/d/1gfQ0dcc5GuQWfGMUiJk_oN1VKh7THmMT/edit?usp=sharing&ouid=106517242061380573521&rtpof=true&sd=true) spreadsheet
found within the Ecophysiology team's google drive folder.***

### Setting up HOBO loggers and downloading HOBO data

Hobo loggers can be set-up using HOBOware or using the waterproof data shuttle. 

***Important:***:bangbang: Please ensure that when setting up the loggers that your computer's clock and timezone are accurate (HOBOWare uses this to
set the clock on the loggers). Please also check that all loggers are setup using the same timezone *AND* that this timezone matches where you are deploying the loggers.
Please refer to the 'RIBBiTR: Core Protocols' document for more information on setting up and deploying HOBO loggers.

***Important***:bangbang:: Date and time of deployment and date and time the logger was removed from the field should be recorded in the ['HOBO logger deployment data'](https://docs.google.com/spreadsheets/d/1gfQ0dcc5GuQWfGMUiJk_oN1VKh7THmMT/edit?usp=sharing&ouid=106517242061380573521&rtpof=true&sd=true) spreadsheet
found within the Ecophysiology team's google drive folder.

### Storing HOBO data

**Storage** :file_folder:: Please store all files as **.hobo** files in the ['HOBO Logger Data'](https://drive.google.com/drive/folders/1oFI-eyaX6w-DHK5Gl44ThiE0Vf8JFNVv?usp=share_link) google drive folder. To standardize storage, please create a new folder within your study system's directory (i.e., Brazil, Panama, etc.) with the following naming convention... ```HOBOS_MonthYrDeployed-MonthYrStopped``` for example, *'HOBOs_Nov22-Feb23*'. All files for that sampling time-period/season can be housed within this newly-created directory.  :camera: All photos of HOBO loggers can also be placed within this directory.

**File naming system** :label:: Individal .hobo files should be named with the site ID, deployment location, and deployement depth/height as follows: 
```SiteID_DeployementLocation_depthORheight``` for example, *'Rio.Blanco_shade_25cm.hobo'*. 

***Important:***:bangbang: **This name should also match the 
'*hobo_name*' colomn in the ['HOBO logger deployment data'](https://docs.google.com/spreadsheets/d/1gfQ0dcc5GuQWfGMUiJk_oN1VKh7THmMT/edit?usp=sharing&ouid=106517242061380573521&rtpof=true&sd=true) spreadsheet.** 
Deployment location and height/depth categories are: 
  ```
     sun_0cm        shade_0cm         soil_-5cm       water_5cm
     sun_25cm       shade_25cm        soil_-10cm      water_20cm
     sun_50cm       shade_50cm                        water_35cm                 
  ```  

## HOBO DATA - FOR ECOPHYSIOLOGY TEAM

### Exporting HOBO files :inbox_tray:

The following steps will be completed by the Ecophysiology team.
The Ecophysiology team will export, trim, and combine the microclimate data collected by field teams for entry into the RIBBiTR Database. 

Use HOBOware Pro to 'bulk export' files from the ['HOBO Logger Data'](https://drive.google.com/drive/folders/1oFI-eyaX6w-DHK5Gl44ThiE0Vf8JFNVv?usp=share_link) google 
drive folder to a local directory. 
Settings for export in HOBOware should be as follows: Export file type = .csv; Date format = YMD; Date seperator = Slash(/); Time format = 24-Hour. All
other default settings can be used.

### Trimming HOBO data :scissors:

Before trimming data, we need to check that all files are logged in the same timezone. The format of data within the date-time column should also be standardized. To check the
timezone of files, standardize column names, standardize formats, and to trim data, use the ['*TrimHOBOFiles.R*'](https://github.com/Jennycocciardi/RIBBiTR_Ecophysiology/blob/main/TrimHOBOFiles.R) script. This script will create a new 'output' folder within your local directory, where it
will create a new *'.csv'* for each file with the naming convention: *'SiteID_DeployementLocation_depthORheight_trimmed.csv'* (for example, *'Admin_sun_50cm_trimmed.csv'*).

The ['*TrimHOBOFiles.R*'](https://github.com/Jennycocciardi/RIBBiTR_Ecophysiology/blob/main/TrimHOBOFiles.R) script requires an additional metadata file
that contains logger start and stop times to automate trimming. This file should be named '*trimming_info.csv*' and should be placed within the same
directory as the data files (there should be one for each study system per sampling period). It should be in the format:
```
hobo_name, start_date.time, stop_date.time
```
The ```hobo_name``` column will be the reference ID, so make sure this column matches the file names precisely. 
The ```start_date.time``` and ```stop_date.time``` information should be obtained from the ['HOBO logger deployment data'](https://docs.google.com/spreadsheets/d/1gfQ0dcc5GuQWfGMUiJk_oN1VKh7THmMT/edit?usp=sharing&ouid=106517242061380573521&rtpof=true&sd=true) spreadsheet.
I've found that the time recorded may not be exactly when the loggers were deployed/removed from the field, and so it's best to trim the data by an extra ~5 hrs 
to remove inaccuracies. Please see the ['*trimming_info.csv*'](https://github.com/Jennycocciardi/RIBBiTR_Ecophysiology/blob/main/trimming_info.csv) file in this repository 
for an example of how to format.

### Concatenating HOBO data

After trimming the data, the Ecophysiology team will combine data across sites for input into the RIBBiTR Database. 
The ['*CombineHOBOfiles.R*'](https://github.com/Jennycocciardi/RIBBiTR_Ecophysiology/blob/main/CombineHOBOFiles.R) script can be used to create an overall, 
*'combined.csv'*, in addition to one .csv file per deployement location for each study system (e.g., *'sun.csv'*, *'shade.csv'*). This script will use the
the newly created *'_trimmed.csv'* files in the 'output' directory and create columns based on the name of each file to add a ```Site```, ```Location```, and ```Height``` column, before 
combining files. This is why it is important to ensure that all files are named as: *'SiteID_DeployementLocation_depthORheight_trimmed.csv'*.

### Long-term storage

The *'combined.csv'* file will be sent to the RIBBiTR Database Manager for input into the database (rename the file to include study area and time period, for example,
*'PA_combined_Jul-Dec22.csv'*.

In addition, place the combined and individual .csv files for each study system and time period within the 
'RIBBiTR Study Sites_HOBO Logger Data' directory found in the 'Data' folder in the 'Ohmer Lab' google drive. Create a new folder for each time 
period within the relevant study area's directory. 

Raw .hobo files will also be stored on the Ohmer Lab's harddrive, as well as within the ['HOBO Logger Data'](https://drive.google.com/drive/folders/1oFI-eyaX6w-DHK5Gl44ThiE0Vf8JFNVv?usp=share_link) google drive folder in the 'Ecophyisology' team's google drive.

___
## THERMAL IMAGES :camera_flash: - FOR FIELD TEAMS

This [sign-out sheet](https://docs.google.com/spreadsheets/d/17hg0DTGzJy9akMPVVxuNyOvGWWmSTO8_/edit?usp=sharing&ouid=106517242061380573521&rtpof=true&sd=true) has information on where thermal camera's associated with
RIBBiTR are housed and which teams are using them. You can refer to it to organize obtaining a thermal camera for 
field sites and seasons.

### Setting up and Downloading thermal cameras :camera:

More information on setting up thermal cameras can be found in the 'RIBBiTR: Core Protocols' document.

### Metadata to collect in the field

Please use Fulcrum to record metadata for each image in the field. Metadata should include the **region, site ID, transect meter, and cardinal direction** of image. Record
the image # that will help us to link the metadata to each thermal photo. More information can be found in the 'RIBBiTR: Core Protocols' document.

### Storing thermal images

:file_folder: **Storage**: All thermal images/FLIR photos will be stored in the ['Thermal Images_FLIR photos'](https://drive.google.com/drive/folders/1_8dMZ86P7BmLn0GG9zTTS8RomSaohe_2?usp=sharing) google drive folder. To standardize
storage, please create a new folder within your study system (i.e., Brazil, Panama, etc.) directory with the fieldwork season/period as the
naming convention, for example, *'FLIR_Nov22-Feb23*'.

***Important:***:bangbang: Please make sure to add the relevant metadata for images to this folder.

## THERMAL IMAGES :camera_flash: - FOR ECOPHYSIOLOGY TEAM

### Organizing thermal images :file_folder:

If field teams decided to annotate notes for each photo, rather than use Fulcrum, we can extract the metadata for each photo using the ['*FLIR_ExtractMetadata.R*'](https://github.com/Jennycocciardi/RIBBiTR_Ecophysiology/blob/main/FLIR_Extract_Metadata.R) script.

### Long-term storage

TBD
