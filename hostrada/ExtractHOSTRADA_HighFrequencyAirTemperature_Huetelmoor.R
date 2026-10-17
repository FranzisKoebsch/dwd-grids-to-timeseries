#################################################################################
# Extraction of Hourly Air Temperature Time Series for Specified Study Areas from HOSTRADA Grids

##1. Data Source: HOSTRADA grids 
# Downloaded from: https://opendata.dwd.de/climate_environment/CDC/grids_germany/hourly/hostrada/air_temperature_mean/
# Product description: https://opendata.dwd.de/climate_environment/CDC/grids_germany/hourly/hostrada/BESCHREIBUNG_gridsgermany_hourly_hostrada_de.pdf
# Data were downloaded from FTP server of the DWD using the script DownloadHOSTRADA_HighFrequencyAirTemperature.R

## 2. Data Characteristics
# Temporal Resolution: 60-minutes
# Spatial Resolution: 1 km x 1 km grid covering German
# Units: °C
# Projection: EPSG:3034 (ETRS89 / LCC Europe) 
  
## 3. Processing:
# This script extracts hourly temperatur time series for defined study areas from the downloaded HOSTRADA grids.
# Study area polygons are defined in a shapefile named "[shapefile name]".
# The script calculates the  air temperature averaged over all grid cells in each study area polygon for each hourly time step.
#################################################################################

# Packages required
require("stringr") 
require("sf")
require("terra")
require("lubridate")
require("ncdf4")
require("R.utils")
require("raster")


#################################################################################
# User configurations

# Directory to read HOSTRADA data 
dir_hos <- 'D:/DWD_Grids/HOSTRADA/AirTemperature_2'

# Define spatial extent through a polygon mask from the study area
huemo_poly <- unzip("C:/Users/franz/Sync/Job/EddyData/Huetelmoor/EnvParameter/DWD_Grid/HuetelmoorExtent.kmz") 

# Define output dir 
output_dir <- "C:/Users/franz/Sync/Job/EddyData/Huetelmoor/EnvParameter/DWD_Grid/HOSTRADA"

#################################################################################
# polygon preparation
huemo_poly <- st_read(huemo_poly) 
# convert to projection of HOSTRADA data
huemo_poly <- st_transform(huemo_poly, crs = 'EPSG:3034') 
# omit z dimension to avoid further complications in extract()
huemo_poly <- st_zm(huemo_poly, what = "ZM") 

# Iterate over years represented by subdirectories
#for(year in list.files(dir_hos)){
for(year in 2009:2024){ 
    
  
## iterate over files stored in each subdirectory
  for(file in list.files(paste(dir_hos, year, sep="/"))){
    
    # Construct file dir
    file_dir <- paste(dir_hos, year, file, sep="/") 
    
      #tryCatch( # some files files cannot be read, catch and handle the error
      #{ 
      # disable trCatch(): after solving the download issue no further errors due to incomplete download should occur.
      # remaining file integrity issues need to be identified
    
      # retrieve time information from the hdf file
      
      nc_data <- nc_open(file_dir)
      
      time <- ncvar_get(nc_data, "time")
      # convert time information to common POSIXct timestamp
      time_units <- ncatt_get(nc_data, "time", "units")$value
      time_origin <- strsplit(time_units, "days since ")[[1]][2]
      time_origin <- as.POSIXct(time_origin, format= "%Y-%m-%dT%H:%M:%S", tz= "GMT")
      datetime <- as.POSIXct(time* 24 * 60 * 60 + time_origin)
      nc_close(nc_data)
      
    # Status message
    cat("Processing ",  format(datetime[1], format = "%b"), format(datetime[1], format = "%Y"), "\n")
    
    # Retrieve met variables by loading netcdf as raster stack
    r_stack <- raster::stack(file_dir, varname = "tas")
    # Extract means in the polygon area for every raster layer in stack
    extracted <- lapply(1:nlayers(r_stack), function(j) {
    rasterlayer <- r_stack[[j]]
    raster::extract((rasterlayer), huemo_poly, fun=mean)})
    extracted_val <- do.call(rbind, extracted) 
     # }, # end of first tryCatch() part
    
    # second part of tryCatch() part: in case an error occurs
       # error = function(e) {
          # error message
        #  print(paste("Fehler beim Einlesen von", file, ":", e$message))
          # alternative way to retrieve time information from file name
          # extract start and end date
        #  start_date <- as.POSIXct(substr(file, 66, 75), format = "%Y%m%d%H", tz="GMT")
         # end_date <- as.POSIXct(substr(file, 77, 86), format = "%Y%m%d%H", tz="GMT")
          # Create a sequence of hourly timestamps from start to end
          #datetime <- seq(start_date, end_date, by = "hour")
          # for missing met variable: create a vector of NAs with the same length as datetime
          #extracted_val <- rep(NA, length(datetime))
          
    #}) # end of tryCatch() 
     
     # create/add data.frame
      if(file == list.files(paste(dir_hos, year, sep="/"))[[1]]){
      hostrada.df <- data.frame(timestamp = datetime, air_temp = extracted_val)}
      else{hostrada.df <- rbind(hostrada.df, data.frame(timestamp = datetime, air_temp = extracted_val))}
    
      } # end of loop for(file in list.files(paste(dir_hos, year, sep="/"))){

  # Save data in annual slices
  # create file name
  output_filename <- paste("HOSTRADA_HourlyAirTemp_", year, ".csv", sep="")
  write.csv(hostrada.df, paste(output_dir, output_filename, sep="/") , row.names = F)

} # end of loop for(year in list.files(dir_hos)){
