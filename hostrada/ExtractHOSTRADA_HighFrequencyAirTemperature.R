#################################################################################
# Extraction of Hourly Air Temperature Time Series for Specified Study Areas from HOSTRADA Grids

##1. Data Source: HOSTRADA grids 
# Downloaded from: https://opendata.dwd.de/climate_environment/CDC/grids_germany/hourly/hostrada/air_temperature_mean/
# Product description: https://opendata.dwd.de/climate_environment/CDC/grids_germany/hourly/hostrada/BESCHREIBUNG_gridsgermany_hourly_hostrada_de.pdf
# Data were downloaded from FTP server of the DWD using the script DownloadHOSTRADA_HighFrequencyAirTemperature.R

## 2. Data Characteristics
# Temporal Resolution: 60-minutes
# Spatial Resolution: 1 km x 1 km grid covering Germany
# Units: °C
# Projection: EPSG:3034 (ETRS89 / LCC Europe) 
  
## 3. Processing:
# This script extracts hourly temperatur time series for defined study areas from the downloaded HOSTRADA grids, assuming the data to be organized in folders of annual slices.
# Study area polygons are defined in a kmz polygon files (can be created in GoogleEarth).
# The script calculates the  air temperature averaged over all grid cells in each study area polygon for each hourly time step.
#################################################################################

# Packages required
library(sf)
library(terra)
library(ncdf4)

#################################################################################
# User configurations

# Directory to read HOSTRADA data 
input_dir <- 'path/to/downloaded/hostrada/temperature/data'

# Define spatial extent through a polygon mask from the study area
aoi_file <- unzip('path/to/Example_AOIFile.kmz', exdir = tempdir()) 

# Define output dir 
output_dir <- 'path/to/extracted/temperature/data'

# Define start year and end year for the extraction
years <- c(2009:2026)

#################################################################################
# polygon preparation
poly_aoi <- st_read(aoi_file) 
# convert to projection of HOSTRADA data
poly_aoi <- st_transform(poly_aoi, crs = 'EPSG:3034') 
# omit z dimension to avoid further complications in extract()
poly_aoi <- st_zm(poly_aoi, what = "ZM") 
# convert to terra object
poly_aoi <- vect(poly_aoi)  

# Iterate over years represented by subdirectories
#for(year in list.files(input_dir)){
for(year in years){ 
    
  
## iterate over files stored in each subdirectory
  for(file in list.files(file.path(input_dir, year), pattern = "\\.nc$", full.names = TRUE)){
    nc_data <- nc_open(file)

    # Create Timestamp
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
    r <- rast(file, subds = "tas")
    # Match polygon CRS exactly to the raster CRS (NetCDF CRS lacks an EPSG code,
    # so 'EPSG:3034' is not recognised as identical, causing a warning in extract())
    project_aoi <- project(poly_aoi, crs(r)) 
    # Extract means in the polygon area for every raster layer 
    extracted_means <- terra::extract(r, project_aoi, fun = mean, na.rm = TRUE, exact = TRUE)

    
    # create/add data.frame
    if(basename(file) == list.files(paste(input_dir, year, sep="/"))[[1]]){
    hostrada.df <- data.frame(timestamp = datetime, air_temp = as.numeric(extracted_means[1, -1]))}
    else{hostrada.df <- rbind(hostrada.df, data.frame(timestamp = datetime, air_temp = as.numeric(extracted_means[1, -1])))}
    
      } # end of loop for(file in list.files(paste(dir_hos, year, sep="/"))){

  # Save data in annual slices
  # create file name
  output_filename <- paste("HOSTRADA_HourlyAirTemp_", year, ".csv", sep="")
  write.csv(hostrada.df, paste(output_dir, output_filename, sep="/") , row.names = F)

} # end of loop for(year in list.files(input_dir)){
