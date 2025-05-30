# requirements.R
#CoCT x JPAL challenge

required_packages <- c(
  "aws.s3",     # S3 data access
  "sf",         # spatial data
  "jsonlite",   # JSON handling
  "tictoc",     # timing/logging
  "fs"          # file system handling
)

install_if_missing <- function(packages) {
  to_install <- packages[!packages %in% rownames(installed.packages())]
  if (length(to_install)) {
    install.packages(to_install, repos = "https://cloud.r-project.org/")
  }
  invisible(lapply(packages, library, character.only = TRUE))
}

install_if_missing(required_packages)