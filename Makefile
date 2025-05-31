# Makefile for CoCT JPAL Data Pipeline

.PHONY: all install extract validate test clean

all: install extract validate test

install:
	Rscript scripts/requirements.R

extract:
	Rscript scripts/extract_hex_res8.R

validate:
	Rscript scripts/validate_hex_level8.R

test:
	Rscript scripts/tests/test_hex_extraction.R

clean:
	rm -f data/raw/*.geojson data/processed/*.geojson logs/*.txt
