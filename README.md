# dwd-grids-to-timeseries
Download DWD grids and extract time series of meteo data

This repository provides a documented, ready-to-use R workflow for obtaining hourly time series of meteorological variables from the DWD grid products RADOLAN and HOSTRADA - from downloading the gridded products to the extraction of a consistent (long-term) time series for a user-defined study area. It builds on the R package rdwd and adresses several pitfalls in handling these data (see known pitfalls). 

Two DWD products are covered:
Product	Variables	Resolution	Format	Details
HOSTRADA	Air temperature, global radiation	1 km, hourly	NetCDF	hostrada/README.md
RADOLAN RW	Precipitation (radar-based, gauge-adjusted)	1 km, hourly	Binary	radolan/README.md

Workflow
HOSTRADA
Download the monthly NetCDF files for a user-defined period.
Extract the hourly time series for the study area.
RADOLAN
Download the hourly files – from the `historical` folder (monthly archives) and/or the `recent` folder (individual files) on the DWD server.
Unpack the historical archives into individually gzipped hourly files (`.gz`), matching the format of the recent data. This step is not needed for recent data.
Extract the hourly time series for the study area.
For each product, the extraction step computes the area-weighted mean over all grid cells overlapping the study area polygon. This also works for areas smaller than one grid cell or spanning cell borders. Results are written as one CSV file per year, with timestamps in UTC.

An example polygon of the area of interest (AOI) is provided in `example/example_aoi_huetelmoor.kmz` for testing. To use your own study area, create a polygon, e.g. in Google Earth, and save it as `.kmz` or `.kml`. The file must contain exactly one polygon.
The scripts have been tested for the years 2009–2026 (HOSTRADA) and 2009–2024 (RADOLAN historical data) plus the recent RADOLAN data.

Known pitfalls
These are the issues the workflow takes care of – and the main reasons why it goes beyond a plain `rdwd` call:
- RADOLAN archive formats change over time. Depending on the period, historical data come as `.tar.gz` or `.tar` monthly archives, and in 2023 as nested archives (monthly archives containing daily archives). In practice, `rdwd::readDWD()` could only read individually gzipped hourly files reliably, so all periods are converted into this uniform format.

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
