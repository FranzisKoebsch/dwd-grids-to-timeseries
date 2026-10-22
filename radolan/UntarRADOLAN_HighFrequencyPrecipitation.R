#################################################################################
# Unpacking of Historical RADOLAN RW Archives into Individually Gzipped Hourly Files
# This step is required between download and time series extraction
# to provide consistent input data for all years.

## 1. Input
# Monthly RADOLAN archives downloaded from the historical DWD archive
# (all years except the current and the previous year):
# https://opendata.dwd.de/climate_environment/CDC/grids_germany/hourly/radolan/historical/bin/

## 2. Background
# rdwd::readDWD() is intended to handle .tar.gz archives directly. In practice, however,
# only individually gzipped hourly files (.gz) could be read reliably; neither the
# archives nor uncompressed binary files worked. This script therefore converts all
# downloaded historical RADOLAN data into consistent .gz files, 
# matching the format of the recent data.
# Script has been tested for the historical RADOLAN RW product 2009-2024

## 3. Archive structure on the DWD server and processing (2009-2024)
# 06/2009 - 06/2014: .tar.gz monthly archives containing gzipped hourly files
#                    -> untarred, files are kept as .gz
# 07/2014 - 2022:    .tar monthly archives containing uncompressed hourly files
#                    -> untarred, files are gzipped (also saves storage space)
# 2023-2024          -> untarred twice, files are gzipped

## 4. Note
# The original archives are not deleted by this script. Remove them manually
# after checking that all hourly files have been extracted.
#################################################################################

# Packages required
library("utils")
library("R.utils")
#################################################################################
# User configurations

# Directory to read tar.gz RADOLAN data 
input_dir <- 'E:/DWD_Grids/RADOLAN/tarred'

# Directory to store untarred gz files 
output_dir <- 'E:/DWD_Grids/RADOLAN/untarred'

#################################################################################
# Start Data extraction
# Iterate over yearly subfolder in the untarred folder 
for(year in list.files(input_dir)){ 

  ## iterate over folders stored in each subdirectory
  for(folder in list.files(paste(input_dir, year, sep="/"))){

    # Construct full file dir for .tar.gz input file and .gz output file
    full_input_dir <- paste(input_dir, year, folder, sep="/") 
    full_output_dir <- paste(output_dir, year, sep="/") 
    
    #create subdirectory for each year in dir_gz output folder
    if(folder==list.files(paste(input_dir, year, sep="/"))[[1]]){
      dir.create(full_output_dir)}

    # untar
    untar(full_input_dir, exdir = full_output_dir)
    
    #check if folders are still tarred (due to nested tar-structures in the original data keeping)
    tar.files <- grep(".tar", list.files(full_output_dir), value = TRUE)    
    if(length(tar.files)>0){  
      tar.files <- paste(full_output_dir, tar.files, sep="/")
      for (tar.file in tar.files) {
        untar(tar.file, exdir = full_output_dir)
        unlink(tar.file)
      }}
      
    # compress all uncompressed files to gz.files
    # select non-gz files
    gz.files <- grep(".gz", list.files(full_output_dir), invert = TRUE, value = TRUE)    
    if(length(gz.files)>0){ 
    gz.files <- paste(full_output_dir, gz.files, sep="/")
    # compress to gz-files
    suppressMessages(sapply(gz.files, gzip))
    }
    
  }} # end of both for() loops
