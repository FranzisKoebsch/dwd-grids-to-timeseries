# dwd-grids-to-timeseries
Download DWD grids and extract time series of meteo data

This repository provides a documented, ready-to-use R workflow for obtaining hourly time series of meteorological variables from the DWD grid products RADOLAN and HOSTRADA - from downloading the gridded products to the extraction of a consistent (long-term) time series for a user-defined study area and its storage in a .csv file. It builds on the R package [`rdwd`](https://github.com/brry/rdwd) and complements it with:

* **Consistent file handling:** RADOLAN archive formats change over time. Depending on the period, historical data come as `.tar.gz` or `.tar` monthly archives, and in 2023 as nested archives (monthly archives containing daily archives). The RADOLAN unpacking script converts all downloaded files into individually gzipped hourly files, a uniform format for straightforward further processing.
* **Consistent hourly precipitation sums:** Since 2023, RADOLAN provides a hourly sum updated every 10 minutes, i.e. up to six overlapping files per hour. The radiaion sums are only extracted from the hourly sums ending at minute 50 (hh:50), consistent with the aggregation to the full hour as in the data before 2023.
* **Area of Interest (AOI masking):** the study area polygon is transformed to the respective DWD product's projection (polar stereographic (central meridian 10.0° E, standard parallel 60.0° N for RADOLAN and ETRS89-extended / LCC Europe, EPSG:3034 for HOSTRADA) to extract taylored information for the area of interest. The extraction also covers smaller AOIs < 1 km size.
  
## Covered Products
| Product | Variables | Resolution | Format | Details |
|---|---|---|---|---|
| **HOSTRADA** | Air temperature, global radiation | 1 km, hourly | NetCDF | [hostrada/README.md](hostrada/README.md) |
| **RADOLAN RW** | Precipitation (radar-based, gauge-adjusted) | 1 km, hourly | Binary (gzipped) | [radolan/README.md](radolan/README.md) |

## Workflow
### HOSTRADA
1. **Download** the monthly NetCDF files for a user-defined period
   ([DownloadHOSTRADA_HighFrequencyAirTemperature.R](DownloadHOSTRADA_HighFrequencyAirTemperature.R)), `hostrada/DownloadHOSTRADA_HighFrequencyRadiation.R`).
2. **Extract** the hourly time series for the study area
   (`hostrada/ExtractHOSTRADA_HighFrequencyAirTemperature.R`, `hostrada/ExtractHOSTRADA_HighFrequencyRadiation.R`).
### RADOLAN
1. **Download** the hourly files from the DWD server – from the `historical` folder (monthly archives) and/or the `recent` folder (individual files)
   (`radolan/DownloadRADOLAN_HighFrequencyPrecipitation_Historical.R`, `radolan/DownloadRADOLAN_HighFrequencyPrecipitation_Recent.R`).
2. **Unpack** the historical archives into individually gzipped hourly files (`.gz`), matching the format of the recent data
   (`radolan/UnpackRADOLAN_HighFrequencyPrecipitation.R`). This step is not needed for recent data.
3. **Extract** the hourly time series for the study area
   (`radolan/ExtractRADOLAN_HighFrequencyPrecipitation.R`).

For each product, the extraction step computes the area-weighted mean over all grid cells overlapping the AOI polygon. An example polygon of the AOI is provided in `Example_AOIFile.kmz` for testing. To use your own study area, create a polygon, e.g. in Google Earth, and save it as `.kmz`. 

The scripts have been tested for the years 2009–2026.

All data: Deutscher Wetterdienst (DWD), Climate Data Center (CDC), opendata.dwd.de. The data are provided under the Creative Commons BY 4.0 license. Please cite the datasets as described in the product READMEs.

The code in this repository is released under the MIT License (see `LICENSE`).

Citation
If you use this workflow, please cite it using the information in `CITATION.cff` (GitHub: "Cite this repository").
<!-- Once a DOI is available via Zenodo, add it here, e.g.:
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXXXX)
If you use these scripts for your work, please cite them as below:
cff-version: 1.2.0
title: "dwd-grids-to-timeseries: R workflow for hourly time series from DWD gridded products (HOSTRADA, RADOLAN)"
authors:
  - family-names: "Koebsch"
    given-names: "Franziska"
    orcid: "https://orcid.org/0000-0003-1045-7680"
    affiliation: "University of Greifswald"
version: 1.0.0
date-released: 2026-10-23
repository-code: "https://github.com/FranzisKoebsch/dwd-grids-to-timeseries"
license: MIT
