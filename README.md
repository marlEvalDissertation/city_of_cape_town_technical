# City of Cape Town x JPAL DataScience Challenge

<img src="img/city_emblem.png" alt="City Logo"/>

This project combines City of Cape Town service request data for the 2020 calendar year with level 8 H3 geospatial indexing data. 
The Bellville South service requests are combined with time-accurate wind speed and direction data from Open-Meteo [1]. This subsample is then anonymised according to principles of differential privacy for further use.

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

To run the full data pipeline that:

1. Downloads the City of Cape Town service request data
2. Joins this with the level 8 H3 geospatial index data
3. Subsamples a dataset of service requests from Bellville South
4, Downloads relevant wind data from Open-Meteo [1]
2. Joins the time-relevant wind data with the Bellville South subsample
3. Anonymises the joined dataset per privacy specifications.

Run the following:

```
# Run the full workflow
make
```


## References

[1] Open-Meteo. (n.d.). *Free Weather API for non-commercial use*. Retrieved from [https://open-meteo.com/](https://open-meteo.com/)