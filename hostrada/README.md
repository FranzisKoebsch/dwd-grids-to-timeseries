# HOSTRADA – Hourly Time Series from DWD Grids

R scripts to download hourly gridded meteorological data (HOSTRADA) from the German Weather Service (DWD) and extract spatially averaged time series for user-defined study areas.

## About the dataset

HOSTRADA (High-resolution grids of hourly variables for Germany) is provided by the DWD via its Open Data server. It is based on the interpolation of hourly station data from the official DWD measurement network, with satellite data (CM-SAF) and model data used as additional predictors.

| Property | Value |
|---|---|
| Spatial coverage | Germany (land surface) |
| Temporal coverage | 1995 – present |
| Temporal resolution | 1 hour |
| Time reference | Instantaneous values at the start of the hour (UTC); global radiation is the sum over the preceding hour |
| Spatial resolution | 1 km × 1 km (resolution of the underlying DEM, see note below) |
| Projection | ETRS89 / LCC Europe (EPSG:3034) |
| Format | NetCDF |
| Updates | Monthly; a new file for the previous month is added at the end of each month (time lag ≈ 1 month) |
| Scaling | None |
**Note on effective resolution:** Although all grids are provided at 1 km, the effective resolution depends on station density and predictor resolution. Cloud cover and radiation have an effective resolution of roughly 25 km; wind speed and direction about 3 km.
 
### Variables
 
| Variable | Unit | Height |
|---|---|---|
| Air temperature | °C | 2 m |
| Dew point temperature | °C | 2 m |
| Relative humidity | % | 2 m |
| Water vapour mixing ratio | – | 2 m |
| Air pressure (station level and sea level) | hPa | – |
| Global radiation | W/m² | – |
| Cloud cover | 1/8 | – |
| Wind speed | m/s | 10 m |
| Wind direction | ° | 10 m |
 
 
## Scripts
 
This folder currently covers **air temperature** and **global radiation**.
 
### 1. Download
 
| Script | Variable | DWD source |
|---|---|---|
| `DownloadHOSTRADA_HighFrequencyAirTemperature.R` | Air temperature | [air_temperature_mean](https://opendata.dwd.de/climate_environment/CDC/grids_germany/hourly/hostrada/air_temperature_mean/) |
| `DownloadHOSTRADA_HighFrequencyRadiation.R` | Global radiation | [radiation_downwelling](https://opendata.dwd.de/climate_environment/CDC/grids_germany/hourly/hostrada/radiation_downwelling/) |
 
The scripts download the monthly NetCDF files starting from **2009**. Files follow the DWD naming scheme, e.g. `tas_1hr_HOSTRADA-v1-0_BE_gn_1995010100-1995013123.nc`.
 
### 2. Time series extraction
 
| Script | Variable |
|---|---|
| `ExtractHOSTRADA_HighFrequencyAirTemperature_Huetelmoor.R` | Air temperature |
| `ExtractHOSTRADA_HighFrequencyRadiation_Huetelmoor.R` | Global radiation |
 
The scripts use the Hütelmoor peatland (NE Germany) as an example study area and can be adapted to any other area by replacing the polygon file.
 
**Input**
 - Downloaded NetCDF files for the respective variable
- A `.kmz` file with the study area polygon(s), e.g. created in Google Earth (example: `HuetelmoorExtent.kmz`)
  
**Procedure**
1. Raster data are loaded with `raster::stack()`.
2. Values are spatially averaged over all grid cells within each study area polygon.
3. Timestamps are read with `ncdf4::ncvar_get(nc_data, "time")`; the time unit is taken from `ncdf4::ncatt_get(nc_data, "time", "units")$value`.
   
**Output**
 Hourly time series of the meteorological variable, spatially averaged per study area polygon (timestamps in UTC).
 
## Requirements
- R
- Packages: `raster`, `ncdf4`
  
## Data source and license
 
Data: Deutscher Wetterdienst (DWD), Climate Data Center (CDC), [opendata.dwd.de](https://opendata.dwd.de/climate_environment/CDC/grids_germany/hourly/hostrada/).
Use of the data is subject to the [GeoNutzV](http://www.geodatenzentrum.de/docpdf/geonutzv_eng.pdf) and the [DWD copyright terms](http://www.dwd.de/EN/service/copyright/copyright_artikel.html).
 
Please cite the dataset as:
 
> HOSTRADA – High-resolution grids of hourly variables for Germany, Version 1.0. Deutscher Wetterdienst.
 
and the method paper:
 
> Krähenmann S, Walter A, Imbery F, Brienen S, Matzarakis A (2018): High-resolution grids of hourly meteorological variables for Germany. *Theoretical and Applied Climatology*. [doi:10.1007/s00704-016-2003-7](https://doi.org/10.1007/s00704-016-2003-7)
 
Full dataset description: [DESCRIPTION_gridsgermany_hourly_hostrada_en.pdf](https://opendata.dwd.de/climate_environment/CDC/grids_germany/hourly/hostrada/DESCRIPTION_gridsgermany_hourly_hostrada_en.pdf)
