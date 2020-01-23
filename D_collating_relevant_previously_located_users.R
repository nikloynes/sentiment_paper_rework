# D_collating_relevant_previously_located_users.R
# a script that merges previously_located users from M01 and M02, and writes out all users
# that had previously been located, for the 3 states of interest, MA, IA and SC
# DATA IN: previously_located (m1 & m2)
# DATA OUT: previously_located.csv
# NL, 22/01/20

library(dplyr)

DATA_PATH <- "~/Desktop/Sentiment Paper/REDO_UNIQUE_USERS/"

M01_previously_located_df <- read.csv(paste0(DATA_PATH, "sentiment_rework_already_located_M01.csv"))
M02_previously_located_df <- read.csv(paste0(DATA_PATH, "sentiment_rework_already_located_M02.csv"))

all_located_users_df <- rbind(M01_previously_located_df, M02_previously_located_df) %>% 
  distinct(user_id, .keep_all = T)

rm(M01_previously_located_df, M02_previously_located_df)
gc()

IA_df <- all_located_users_df %>% 
  filter(country == "United States") %>% 
  filter(admin == "Iowa")

MA_df <- all_located_users_df %>% 
  filter(country == "United States") %>% 
  filter(admin == "Massachusetts")

SC_df <- all_located_users_df %>% 
  filter(country == "United States") %>% 
  filter(admin == "South Carolina")

write.csv(IA_df, paste0(DATA_PATH, "iowa.csv"))
write.csv(MA_df, paste0(DATA_PATH, "massachussets.csv"))
write.csv(SC_df, paste0(DATA_PATH, "south_carolina.csv"))

