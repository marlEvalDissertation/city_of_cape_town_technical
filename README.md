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

## File Structure

```
├── data/
│ ├── raw/ # Unprocessed data files
│ └── processed/ # Cleaned and joined datasets
│
├── img/ # City of Cape Town Logo
│
├── logs/ # logs of download and processing times and errors
|
├── scripts/ # All scripts for execution of project tasks and data validation
│ ├── requirements.R
│ ├── extract_hex_res8.R
│ ├── download_sr_data.R
│ ├── join_sr_to_hex.R
│ ├── get_bellville_centroid.R
│ ├── bellville-south-subsample.R
│ ├── download_wind_data.R
│ ├── join_bellville_wind.R
│ ├── anonymise_sr_data.R
│ ├── validate_hex_level8.R
│ └── validate_sr_join.R
│
├── tests/ # R scripts for unit and integration tests of the above scripts
│ ├── test_hex_extraction.R
│ ├── test_join.R
│ ├── test_unit_bellville.R
│ ├── test_integration_bellville.R
│ ├── test_wind_data.R
│ ├── test_wind_join.R
│ └── test_anonymisation.R
|
├── Makefile # Workflow automation
├── README.md # Project overview
├── .gitignore
├── LICENSE
├── city_of_cape_town_technical.Rproj
```

## Script Details

This section provides details as to the contents of the scripts and what they achieve.

### requirements.R

Automatically installs all R packages required for execution of this project.

### extract_hex_res8.R

Downloads and stores the AWS H3 resolution 8 data from city-hex-polygons-8-10.geojson. Stores this in data/processed/city-hex-polygons-8(new).geojson.
Logs errors and download times in logs/extraction_log.txt.

### validate_hex_level8.R

Compares data downloaded in hex_polygons_8.geojson (the supplied validation file) to the data extract stored in city-hex-polygons-8(new).geojson.
All data should be resolution 8. Logs the result of the validation in logs/validation_log.txt.

### download_sr_data.R

Downloads the City of Cape Town 2020 service request datasets off of AWS. These are stored in data/raw/sr_hex.csv.gz and data/raw/sr.csv.gz for later use.
Logs the download times and errors in logs/download_sr_log.txt

### join_sr_to_hex.R

Joins the City of Cape Town 2020 service request data from data/raw/sr.csv.gz to the hex level 8 data in data/processed/city-hex-polygons-8(new).geojson.
Outputs the results of the join to data/processed/sr_with_hex.csv.gz. Logs times, errors and join success rate to logs/join_log.txt.
The recorded join joined 729267 of 941634 data entries (77.45% success). A join error threshhold of 25% was used. We assume this to be an acceptable threshhold due to municipal data gaps or errors in municipal data being commonplace.
Additionally the observed join failure rate was 22.55% so we apply a slight margin of error to this and assume a 25% threshhold. The join was performed on coordinate data. If this data was missing a 0 value was recorded in place of the geospatial index.
The data was joined using a spatial join function from the `sf` package. This converts the coordinates from the service request data into H3 level 8 geospatial data and matches this with the H3 data from the extracted geojson file.

### validate_sr_join.R

This validates the sr_with_hex.csv.gz with the provided data/raw/sr_hex.csv.gz file. The validation, error and time logs are stored in logs/validation_sr_log.txt.

### get_bellville_centroid.R

Derives geospatial centroid latitude and longitude of Bellville South from service request data. Stores this in data/processed/bellville_centroid.csv.
Logs timing and errors in logs/centroid_log.txt. This calculates the centroid using a data oriented approach.
The script takes the service request data from data/processed/sr_with_hex.csv.gz, identifies all Bellville South service requests and aggregates across the latitudes and longitudes to calculate the coordinates of the centroid for Bellville South.
The resultant centroid has coordinates of `latitude = -33.91728051899133` and `longitude = 18.642285211212553`.
This data centered approach could be replaced by a standardised coordinate choice from Elevation Map [2] which yields `Latitude = -33.916111` and `longitude = 18.644444`. The coordinates of an 'administrative polygon' may thus be preferred to our data centred approach.
We note the similarity of our aggregated result to the one found online up to two decimal places. 


### bellville-south-subsample.R

Samples data from the sr_hex.csv.gz that is within 1 minute of the centroid of the Bellville south suburb. Stores these records in data/processed/sr_bellville_south_subsample.csv.gz and logs errors and timing in logs/subsample_log.txt.
We assume 1 minute is equivalent to one minute of latitude in distance. Since 1° of latitude has 60 minutes and since 1° spans approximately 111.32km [3] then 111.32/60 ≈ 1.85 km/minute is the distance per minute. 
We acknowledge other interpretations of 1 minute such as one minute in travelling distance for various modes of transport. This is not explored here. A Haversine distance formula [4] is used to calculate distance in this script. This accounts for the curvature of the Earth.

### download_wind_data.R

Downloads and cleans the 2020 wind speed and direction data for Bellville South. Stores this in data/processed/wind_bellville_2020.csv.gz 
and logs errors and timings in logs/wind_download_log.txt. The wind data is obtained from Open Meteo [1]. Data is obtained with careful consideration of the UTC and UTC+2 timezone differences in the datasets.
All data is stored in UTC+2.

### join_bellville_wind.R

Joins the Bellville South subsample, in sr_bellville_south_subsample.csv.gz, with 2020 wind data in wind_bellville_2020.csv.gz. The join is performed by matching the nearest previous hour of the service requests creation times with the wind data times (in UTC+2).
The combined dataset is stored in data/processed/sr_wind_joined.csv.gz and logs are stored in logs/join_wind_log.txt.

### anonymise_sr_data.R

Anonymises the Bellville South service request data with wind dataset. Stores this in data/processed/sr_wind_anonymised.csv.gz and logs errors and times in logs/anonymise_log.txt.
Location accuracy is anonymised to be within 500m and creation time accuracy is anonymised to be within 6 hours of the original request via flooring to the nearest 6 hour window (UTC+2 timezone).
This prevents linking service request events to individuals through highly specific temporal data while preserving meaningful weather-related patterns.
As the H3 level 8 data geospatial index assumes coordinates with approximately 500m this is used as the location data. 
This ensures spatial accuracy suitable for neighborhood-level analysis, while obscuring the exact location of the requester
Furthermore assumed quasi-identifiers are removed from the dataset. Variables removed include the notification_number and reference_number which are potentially traceable, the completion_timestep and latitude and longitude data.
The variables retained for analysis are thus the directorate, department, branch, section, code_group, code, cause_code_group, cause_code, the  h3_level8_index spatial index and the anonymised_time.
These variables pertain not to the requestor but to the response behaviour and service category.

## Testing Scripts

The testing scripts provide some unit and integration tests to test the output of the above scripts. `make test` runs these. 

## References

[1] Open-Meteo. (n.d.). *Free Weather API for non-commercial use*. Retrieved from [Open-Meteo](https://open-meteo.com/)

[2] ElevationMap.net. (n.d.). Elevation of Bellville South, City of Cape Town, South Africa. Retrieved from [elevation map](https://elevationmap.net/bellville-south-city-of-cape-town-za-1011483330)

[3] Wikipedia. (n.d.). Latitude. Retrieved from [wikipedia](https://en.wikipedia.org/wiki/Latitude)

[4] Movable Type Scripts. (n.d.). Calculate distance, bearing and more between Latitude/Longitude points. Retrieved from [movable-type](https://www.movable-type.co.uk/scripts/latlong.html)





