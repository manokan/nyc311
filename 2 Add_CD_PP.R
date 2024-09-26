library(data.table)
library(sf)

# Set file paths
rds_file <- "/Users/manomini/Downloads/Pradhyumna-local/SRs_2020.rds"
council_districts_shapefile <- "/Users/manomini/Downloads/Pradhyumna-local/nyccwi_24c/nyccwi.shp"
police_precincts_shapefile <- "/Users/manomini/Downloads/Pradhyumna-local/nypp_24c/nypp.shp"
output_file <- "/Users/manomini/Downloads/Pradhyumna-local/SRs_2020_with_CD_PP.rds"

# Load the shapefiles for council districts and police precincts
council_districts <- st_read(council_districts_shapefile)
police_precincts <- st_read(police_precincts_shapefile)

# Transform the shapefiles to the same CRS as the latitude and longitude data
council_districts <- st_transform(council_districts, crs = 4326)
police_precincts <- st_transform(police_precincts, crs = 4326)

# Function to add council district and police precinct based on latitude and longitude
add_spatial_info <- function(data, council_districts, police_precincts) {
  # Ensure that longitude and latitude columns exist
  if (!("Longitude" %in% names(data)) | !("Latitude" %in% names(data))) {
    stop("Longitude and Latitude columns are required in the data.")
  }
  
  # Initialize the new columns with NA for rows without lat/long info
  data[, council_district := NA_integer_]
  data[, police_precinct := NA_integer_]
  
  # Filter only the rows with latitude and longitude information for spatial joins
  valid_rows <- data[!is.na(Longitude) & !is.na(Latitude)]
  
  # Convert the valid rows to an sf object
  data_sf <- st_as_sf(valid_rows, coords = c("Longitude", "Latitude"), crs = 4326, remove = FALSE)
  
  # Perform spatial joins
  data_with_cd <- st_join(data_sf, council_districts, join = st_intersects)
  data_with_cd_pp <- st_join(data_with_cd, police_precincts, join = st_intersects)
  
  # Convert back to data.table and remove geometry column
  data_with_cd_pp_dt <- as.data.table(st_drop_geometry(data_with_cd_pp))
  
  # Retain only the necessary columns and add council district and police precinct
  data_with_cd_pp_dt <- data_with_cd_pp_dt[, .(Longitude, Latitude, CounDist, Precinct)]
  setnames(data_with_cd_pp_dt, c("CounDist", "Precinct"), c("council_district", "police_precinct"), skip_absent = TRUE)
  
  # Merge the updated columns back into the original dataset
  data[data_with_cd_pp_dt, on = .(Longitude, Latitude), `:=`(council_district = i.council_district, police_precinct = i.police_precinct)]
  
  return(data)
}

# Load the RDS file
SRs_2020 <- readRDS(rds_file)

# Split data into smaller batches to process
batch_size <- 500000  # Adjust this size based on memory capacity
num_batches <- ceiling(nrow(SRs_2020) / batch_size)

for (i in 1:num_batches) {
  start_index <- (i - 1) * batch_size + 1
  end_index <- min(i * batch_size, nrow(SRs_2020))
  SRs_batch <- SRs_2020[start_index:end_index]
  
  # Add spatial information to the batch
  SRs_batch <- add_spatial_info(SRs_batch, council_districts, police_precincts)
  
  # Save each batch to a file  or combine them
  if (i == 1) {
    saveRDS(SRs_batch, output_file)
  } else {
    # Append to the output file
    existing_data <- readRDS(output_file)
    combined_data <- rbind(existing_data, SRs_batch)
    saveRDS(combined_data, output_file)
  }
  
  rm(SRs_batch)  # Clean up memory
  gc()  # Run garbage collection
}
rm(SRs_2020, council_districts, police_precincts)
gc() 