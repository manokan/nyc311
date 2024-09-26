# Install and load necessary packages
required_packages <- c("data.table", "ggplot2", "reshape2")

installed_packages <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!pkg %in% installed_packages) {
    install.packages(pkg, dependencies = TRUE)
  }
}

library(data.table)
library(ggplot2)
library(reshape2)

# Set file path
rds_file <- "/Users/pradhyumnaadusumilli/Desktop/Full Yearly with CD PP/SRs_2023_with_CD_PP.rds"

# Load the RDS file into a data.table
SRs_2023_with_CD_PP <- readRDS(rds_file)

# Remove rows where council_district or police_precinct is NA
SRs_2023_with_CD_PP <- SRs_2023_with_CD_PP[!is.na(council_district) & !is.na(police_precinct)]

# Define the percentage of the sample you want to take (e.g., 5%)
sample_percentage <- 0.05

# Take a random sample of the data (5% of rows)
set.seed(123)  # Set seed for reproducibility
sampled_data <- SRs_2023_with_CD_PP[sample(.N, .N * sample_percentage)]

# Save the sampled dataset as an RDS file (or you can save it as CSV)
saveRDS(sampled_data, "/Users/pradhyumnaadusumilli/Desktop/SRs_2023_with_CD_PP_sampled.rds")

# Clean up the environment
rm(list = ls())
