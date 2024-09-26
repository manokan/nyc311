# If these libraries are not already installed, RStudio will prompt you to install them. Please go ahead and do so
library(data.table)
library(lubridate)

# Set file paths
csv_file <- "/Users/pradhyumnaadusumilli/Desktop/311_Service_Requests_2023.csv"

# Load the CSV file into a data.table
SRs_2023 <- fread(
  csv_file,
  check.names = TRUE, # Replaces spaces in column names with periods
  keepLeadingZeros = TRUE, # Keeps leading zeros(as they have information value) in ZIP and BBL columns
  na.strings = c("NA", "N/A", "Unspecified", "", "null") # Define NA strings
)
# Formatting date columns since the dates are supplied in text format
date_cols <- c("Created.Date", "Closed.Date", "Due.Date", "Resolution.Action.Updated.Date")
SRs_2023[, (date_cols) := lapply(.SD, function(x) mdy_hms(x, tz = "America/New_York")), .SDcols = date_cols]
# Save the dataset as an RDS file called “SRs_2011.rds”
saveRDS(SRs_2023, "/Users/pradhyumnaadusumilli/Desktop/SRs_2023.rds")

# Clean up the environment
rm(SRs_2023)
