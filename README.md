# City of Cape Town x JPAL DataScience Challenge

<img src="img/city_emblem.png" alt="City Logo"/>

![R version](https://img.shields.io/badge/R-≥%204.1.0-blue?logo=r)
![License](https://img.shields.io/badge/license-MIT-green)
![Makefile](https://img.shields.io/badge/built%20with-Make-blue)
![Test Coverage](https://img.shields.io/badge/tests-passing-brightgreen)
![Project Status](https://img.shields.io/badge/status-active-success)

This project combines City of Cape Town service request data for the 2020 calendar year with level 8 H3 geospatial indexing data. 
The Bellville South service requests are then combined with time-accurate wind speed and direction data from Open-Meteo [1]. This subsample is then anonymised according to principles of differential privacy for potential further use.
The project includes timing, logging of times, logging of errors, validation tests against provided validation sets as well as unit tests and even integration tests.

## Prerequisites

Before running the project, ensure you have the following installed:

- **R** (≥ 4.1.0) — to run the data processing scripts  
- **Git** — to clone the repository  
- **Make** — to run the automated pipeline via the `Makefile`  
- **R packages** (automatically installed via `scripts/requirements.R`, but listed here for reference):
  - `tidyverse`, `lubridate`, `httr`, `jsonlite`, `fs`, `tictoc`, `data.table`, `h3jsr`, `testthat`, `aws.s3`, `sf`, `dplyr`, `readr`, `geosphere`


## Installation

To install clone the repository and cd into the directory as follows:

``` bash
# Clone the repository
git clone https://github.com/marlEvalDissertation/city_of_cape_town_technical.git
cd city_of_cape_town_technical
```

## Workflow and Execution

### QuickStart

Run the following:

```
# Run the full workflow
make
```

This runs the full data pipeline that:

1. Downloads the City of Cape Town service request data
2. Joins this with the level 8 H3 geospatial index data
3. Subsamples a dataset of service requests from Bellville South
4. Downloads relevant wind data from Open-Meteo [1]
5. Joins the time-relevant wind data with the Bellville South subsample
6. Anonymises the joined dataset per privacy specifications
7. Validation of the City data sets against provided data sets
8. Unit and integration tests of all scripts.

### Package Installation

If code is to be run in a step-by-step manner then relevant R packages can be installed using the following.

``` bash
make install
```

### Data Extraction and Transformation

All relevant data transformations and extractions can be run using:

``` bash
make extract
```

### Data Validation

To perform data validation of the extracted resolution 8 H3 polygon data against `city-hex-polygons-8.geojson` and data validation of the joined service request data with the relevant level 8 H3 data as compared to `sr_hex.csv.gz` run the following:

``` bash
make validate
```
### Script Testing

To perform relevant unit and integration tests that check the code run:

``` bash
make test
```

### Removing Data Files

To remove all downloaded and processed data files run:

``` bash
make clean
```
## Details

## File Structure

## Script Content

## References

[1] Open-Meteo. (n.d.). *Free Weather API for non-commercial use*. Retrieved from [Open-Meteo](https://open-meteo.com/)