# Get noise (only) raw data from 2010 to present, read into R, convert dates to POSIXct
# For data from 2004 thru 2009, download separate yearly CSVs elsewhere
# Click "View Data" at:
# https://nycopendata.socrata.com/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9
# Filter:
# Complaint Type --> contains --> Noise
# Created Date --> is before --> # I pick the day after the most recent quarter ending, eg. 07/01/2019 12:00:00 AM 
# Export as CSV
# The CSV is ~1.83GB (2010 to Q2 2019). If on a paid connection, consider sticking to the much smaller subsetted CSVs I post here. 
#
#
# Read into R ----

library(data.table)
options(scipen = 100, digits = 10) # scientific notation begone!

fileLoc <- "path/to/file/filename.csv" # path and filename you assigned

noise10to19Q2 <- fread(
  fileLoc,
  #nrows = 10000, #to get overview of table
  check.names = TRUE, # replaces space in col names w/ period
  colClasses = list(character = c(9, 25)), # sets ZIP & BBL cols as character
  na.strings = c("NA", "N/A", "", "null") # "Unspecified" not always = NA
)

# Convert dates and times to POSIXct ----

library(lubridate)
options(lubridate.fasttime = TRUE) 
# options(lubridate.verbose = TRUE) 

# Specify cols to be converted to POSIXct (all):

cols <- c("Created.Date", "Closed.Date", "Due.Date", "Resolution.Action.Updated.Date")

noise10to19Q2[, (cols) := lapply(.SD, function(x) mdy_hms(x, tz = "America/New_York")), .SDcols=cols]

# May get "x failed to parse" warning. Times that have strings where a number is expected. About 28 IIRC. On Linux it sets to NA silently.

# Subset cols if required ----
# Improves speed if RAM is 4GB or less

cols <- c("Created.Date", "Agency", "Complaint.Type", "Descriptor", "Community.Board", "Resolution.Description", "Borough")

noise10to19Q2 <- noise10to19Q2[, ..cols]

# Save ----

saveRDS(noise10to19Q2, "noise10to19Q2.rds")

rm(list = ls()) # Or not...
