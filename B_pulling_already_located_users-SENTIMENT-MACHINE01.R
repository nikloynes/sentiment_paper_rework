# B_pulling_already_located_users-SENTIMENT-MACHINE01.R
# a script that reads in all unique users identified as having mentioned Bernie / Hillary
# during the timeframe relevant to the sentiment paper, and writes out the users that have already
# been located using the NL geolocation pipeline.
# DATA IN: ../data/raw/unique_users.txt
# DATA OUT: ../data/out/sentiment_rework_already_located_M01.csv
# NL, 28 June 19
# NL, 26 Nov 19 -- updated for debate 05
# NL, 11 Nov 19 -- updated for debate 04
# NL, 17 Jan 20 -- updated for debate 06 and 07
# NL, 21 Jan 20 -- updated for sentiment paper rework

library(dplyr)
library(RMySQL)

# PATHS!
########

# remote
DATA_PATH <- "/home/nl_sentiment_paper_rework/data/raw/"
# local
#DATA_PATH <- "~/Desktop/SMAPP_2020/data/raw/"

# remote
DATA_OUT <- "/home/nl_sentiment_paper_rework/data/out/"
# local
#DATA_OUT <- "~/Desktop/SMAPP_2020/data/out"

# SQL!
########

print("Connecting to MySQL server")

# - connecting to MySQL server
# note: this will only work on the machine that runs the SQL dbs

con <- dbConnect(MySQL(),
                 user="root",
                 # - DEVELOPLEMT
                 #password = "", 
                 # - PRODUCTION
                 password='~`ruYm4AZ+@R"z%5', 
                 dbname="main", host="localhost")

# DATA IN!
##########

users <- readLines(paste0(DATA_PATH, "unique_users.txt"))

# QUERIES!
#########

# 1 - get all matching users in the users table
query_01 <- paste0("SELECT * FROM users WHERE user_id IN (",
                   paste0("'", users, "'", collapse = ", "), ");")

already_located_users_df <- dbGetQuery(con, query_01)

# 2 - get all unique raw_location ids and all unique location ids

unique_raw_loc_ids <- unique(already_located_users_df$raw_location_id)
# deleting NAs
unique_raw_loc_ids <- unique_raw_loc_ids[!(unique_raw_loc_ids %in% NA)]
unique_loc_ids_01 <- unique(already_located_users_df$primary_location_id)

query_02 <- paste0("SELECT * FROM raw_locations WHERE id IN (",
                   paste0(unique_raw_loc_ids, collapse = ", "), ");")

unique_raw_locations_df <- dbGetQuery(con, query_02)

unique_loc_ids_02 <- unique(unique_raw_locations_df$location_id)
unique_loc_ids <- unique(c(unique_loc_ids_01, unique_loc_ids_02))
unique_loc_ids <- unique_loc_ids[!(unique_loc_ids %in% NA)]

query_03 <- paste0("SELECT * FROM locations WHERE id IN (",
                   paste0(unique_loc_ids, collapse = ", "), ");")

unique_locations_df <- dbGetQuery(con, query_03)

# renaming vars so they can easily be merged
unique_locations_df <- unique_locations_df %>% 
  rename(location_id = id)
unique_raw_locations_df <- unique_raw_locations_df %>% 
  rename(raw_location_id = id)

# merge
unique_locations_df <- left_join(unique_locations_df, unique_raw_locations_df, by = "location_id")

# merge on to users dataframe
already_located_users_df <- already_located_users_df %>% 
  rename(location_id = primary_location_id)

# split users into those that were census-located and those that were
# network-located

census_users_df <- already_located_users_df %>% 
  filter(is.na(network_estimated_country) & 
           is.na(network_estimated_admin) &
           is.na(network_estimated_municipality))

network_users_df <- already_located_users_df %>% 
  filter(!is.na(network_estimated_country) &
           !is.na(network_estimated_admin) &
           !is.na(network_estimated_municipality))

rm(already_located_users_df, query_01, query_02, query_03, unique_raw_locations_df, unique_raw_loc_ids,
   unique_loc_ids_01, unique_loc_ids_02, unique_loc_ids, users)
# flush memory!
gc()

unique_locations_01_df <- unique_locations_df %>% 
  mutate(location_id = NULL)

census_users_df <- left_join(census_users_df, unique_locations_01_df, by = "raw_location_id") %>% 
  mutate(type="census")

unique_locations_02_df <- unique_locations_df %>% 
  distinct(location_id, .keep_all = T) %>% 
  mutate(raw_location_id = NULL)

network_users_df <- left_join(network_users_df, unique_locations_02_df, by = "location_id") %>% 
  mutate(type="network")

already_located_users_df <- rbind(census_users_df, network_users_df) 

already_located_users_df <- already_located_users_df %>% 
  distinct(user_id, .keep_all = T) %>% 
  filter(country!="NA")

write.csv(already_located_users_df, paste0(DATA_OUT, "sentiment_rework_already_located_M01.csv"))


