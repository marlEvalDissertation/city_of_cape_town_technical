# Makefile for CoCT JPAL Data science challenge

.PHONY: all install extract validate test clean

all: install extract validate test

install:
	@echo "Installing R dependencies..."
	Rscript scripts/requirements.R

extract:
	@echo "Extracting and processing data..."
	Rscript scripts/extract_hex_res8.R
	Rscript scripts/download_sr_data.R
	Rscript scripts/join_sr_to_hex.R
	Rscript scripts/bellville-south-subsample.R
	Rscript scripts/download_wind_data.R
	Rscript scripts/join_bellville_wind.R
	Rscript scripts/anonymise_sr_data.R

validate:
	@echo "Running data validation..."
	Rscript scripts/validate_hex_level8.R
	Rscript scripts/validate_sr_join.R

test:
	@echo "Running tests..."
	Rscript tests/test_hex_extraction.R
	Rscript tests/test_join.R
	Rscript tests/test_unit_bellville.R
	Rscript tests/test_integration_bellville.R
	Rscript tests/test_wind_data.R
	Rscript tests/test_wind_join.R
	Rscript tests/test_anonymisation.R

clean:
	@echo "Cleaning up generated files..."
	rm -f data/raw/*.geojson data/processed/*.geojson
