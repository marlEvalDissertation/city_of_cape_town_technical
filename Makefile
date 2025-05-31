# Makefile for CoCT JPAL Data Pipeline

.PHONY: all install extract validate test clean

all: install extract validate test

install:
	Rscript scripts/requirements.R

extract:
	Rscript scripts/extract_hex_res8.R
	Rscript scripts/download_sr_data.R
	Rscript join_sr_to_hex.R

validate:
	Rscript scripts/validate_hex_level8.R
	Rscript scripts/validate_sr_join.R

test:
	Rscript scripts/tests/test_hex_extraction.R
	Rscript scripts/tests/test_join.R

clean:
	rm -f data/raw/*.geojson data/processed/*.geojson logs/*.txt
