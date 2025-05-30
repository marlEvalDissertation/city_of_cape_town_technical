# scripts/requirements.R
#CoCT x JPAL challenge

required_packages <- c(
  "aws.s3",     
  "sf",         
  "jsonlite",   
  "tictoc",    
  "fs"    ,      
  "dplyr",
  "testthat"
)

install_if_missing <- function(packages) {
  to_install <- packages[!packages %in% rownames(installed.packages())]
  if (length(to_install)) {
    install.packages(to_install, repos = "https://cloud.r-project.org/")
  }
  invisible(lapply(packages, library, character.only = TRUE))
}

install_if_missing(required_packages)
