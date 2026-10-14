#################################################################################
# Download HOSTRADA (Hochaufgel?ster st?ndlicher Rasterdatensatz)  hourly temperature data from DWD.
# HOSTRADA is available since 2004 and continuously updated at the end of the following month.
# HOSTRADA products are interpolated from station data using climate models and satellite data.
# Temporal resolution: 60 min, spatial resolution: 1 km, projection: EPSG:3034 (ETRS89 / LCC Europe), timezone: UTC.
# Air Temperature is measured at 2m height and represents instantaenous temperature values at the top of each hour.
# archive: https://opendata.dwd.de/climate_environment/CDC/grids_germany/hourly/hostrada/air_temperature_mean/
# For a detailed dataset description, see: https://opendatao.dwd.de/climate_environment/CDC/grids_germany/hourly/hostrada/DESCRIPTION_gridsgermany_hourly_hostrada_en.pdf
#################################################################################
# Caution: incomplete file download may occur, resulting in an error message. Affected files require a second download
# Proposed solution: Implement a download check that verifies downloaded file size. If the file size is less than100 Mb remove the incomplete file and repeat the download
#################################################################################
# Packages required
require("rdwd")
require("stringr")

# Download file index
# compose different link components to the FTP server of the DWD
base <- gridbase 
link <- "hourly/hostrada/air_temperature_mean" 
# Load indices for available HOSTRADA data
index <- indexFTP(link, base = base)

# Define start and end year, data acquisition and storage is performed in annual slices 
start_year <- 2024
end_year <- 2026 

# for-loop to iterate through the years
for (year in c(start_year: end_year)){
  
# Directory to save HOSTRADA data 
dir_dwd <- paste('D:/DWD_Grids/HOSTRADA/AirTemperature_2', year,sep="/")
dir.create(dir_dwd) # create directories for annual data packages

# Filter indices for a specific year
index_filtered <- index %>%
  str_extract("(?<=tas_1hr_HOSTRADA-v1-0_BE_gn_)\\d{10}") %>% # Extract first 10 digits 'd{10}' following the substring 'raa01-sf_10000-'
  as.POSIXct(format = "%Y%m%d%H", tz = "UTC") %>%
  format(,format="%Y") %>%
  as.numeric() %>%
  {index[(. == year)]} %>% # filter index
  na.omit() # 


# Download filtered files 
files <- dataDWD(
  url = index_filtered, 
  base = base, 
  joinbf = TRUE, 
  dir = dir_dwd, 
  read = FALSE
)

}
