# Makefile for CoCT JPAL Data Pipeline

.PHONY: all install extract validate test clean

all: install extract validate test

install:
	Rscript scripts/requirements.R

extract:
	Rscript scripts/extract_hex_res8.R
	Rscript scripts/download_sr_data.R
	Rscript scripts/join_sr_to_hex.R
	Rscript scripts/get_bellville_centroid.R
	Rscript scripts/bellville-south-subsample.R
	Rscript scripts/download_wind_data.R

validate:
	Rscript scripts/validate_hex_level8.R
	Rscript scripts/validate_sr_join.R

test:
	Rscript tests/test_hex_extraction.R
	Rscript tests/test_join.R
	Rscript tests/test_unit_bellville.R
	Rscript tests/test_integration_bellville.R

clean:
	rm -f data/raw/*.geojson data/processed/*.geojson logs/*.txt
