# M02_merging_labelled_data.R
# a script that pulls in formatted hand-labelled data for the 3 states of interest and merges them with all existing metadata in
# order to allow for these tweets to be classified

# UPDATE 21/07/20:
# it appears that there was a problem with the string-ifying of the tweet ids when generating the original samples to be labelled.
# this occurs when long numbers (such as for the tweet ids) are somehow rounded when converting them to strings. 
# luckily, the original tweet ids still persist in the original csv files for the unlabelled samples. 

# based on this, it will be easier to move forward with how the paper should be written up. 
# NL, 17/07/20

library(dplyr)
library(ggplot2)
library(jsonlite)

LABELLED_TWEETS <- "Desktop/SENTIMENT/data/labelled_tweets/formatted/"
UNLABELLED_DATA <- "Desktop/SENTIMENT/data/samples_for_labelling/"
LOC_DISPERSION_DATA <- "Desktop/SENTIMENT/data/users_with_place_proportions/"
IDEOLOGY_DATA <- "Desktop/SENTIMENT/data/user_tweet_overviews/"
ALL_TWEETS <- "Desktop/SENTIMENT/data/located_users_tweets/"

DATA_OUT <- "Desktop/SENTIMENT/data/labelled_tweets/fmtd_with_metadata/"

# DATA IN
# labelled tweets
nh_labels_df <- read.csv(paste0(LABELLED_TWEETS, "new_hampshire.csv"), stringsAsFactors = F) %>% 
  mutate(external_id = as.character(external_id)) %>% 
  rename(id = external_id)
sc_labels_df <- read.csv(paste0(LABELLED_TWEETS, "south_carolina.csv"), stringsAsFactors = F) %>% 
  mutate(external_id = as.character(external_id)) %>% 
  rename(id = external_id)
ma_labels_df <- read.csv(paste0(LABELLED_TWEETS, "massachussets.csv"), stringsAsFactors = F) %>% 
  mutate(external_id = as.character(external_id)) %>% 
  rename(id = external_id)

# location dispersion
nh_loc_disp_df <- read.csv(paste0(LOC_DISPERSION_DATA, "new_hampshire.csv"), stringsAsFactors = F) %>% 
  mutate(X = NULL,
         X.1 = NULL,
         user_id = as.character(user_id)) %>% 
  select(user_id, pop_norm, pop_quantiles)
sc_loc_disp_df <- read.csv(paste0(LOC_DISPERSION_DATA, "south_carolina.csv"), stringsAsFactors = F)  %>% 
  mutate(X = NULL,
         X.1 = NULL,
         user_id = as.character(user_id)) %>% 
  select(user_id, pop_norm, pop_quantiles)
ma_loc_disp_df <- read.csv(paste0(LOC_DISPERSION_DATA, "massachusetts.csv"), stringsAsFactors = F)  %>% 
  mutate(X = NULL,
         X.1 = NULL,
         user_id = as.character(user_id)) %>% 
  select(user_id, pop_norm, pop_quantiles)

# user data
nh_user_data_df <- read.csv(paste0(IDEOLOGY_DATA, "new_hampshire_overview.csv"), stringsAsFactors = F) %>% 
  mutate(X = NULL,
         user_id = as.character(user_id))
  
sc_user_data_df <- read.csv(paste0(IDEOLOGY_DATA, "south_carolina_overview.csv"), stringsAsFactors = F) %>% 
  mutate(X = NULL,
         user_id = as.character(user_id))
ma_user_data_df <- read.csv(paste0(IDEOLOGY_DATA, "massachussets_overview.csv"), stringsAsFactors = F) %>% 
  mutate(X = NULL,
         user_id = as.character(user_id))

# unlabelled tweets
nh_unlabelled_csv_df <- read.csv(paste0(UNLABELLED_DATA, "nh_tweet_sample.csv"), colClasses = "character")
sc_unlabelled_csv_df <- read.csv(paste0(UNLABELLED_DATA, "sc_tweet_sample.csv"), colClasses = "character")
ma_unlabelled_csv_df <- read.csv(paste0(UNLABELLED_DATA, "ma_tweet_sample.csv"), colClasses = "character")

# nh_tweets_df <- stream_in(con = file(paste0(ALL_TWEETS, "new_hampshire_tweets.json")))
# nh_tweets_df <- flatten(nh_tweets_df)
# sc_tweets_df <- stream_in(con = file(paste0(ALL_TWEETS, "southcarolina_tweets.json")))
# sc_tweets_df <- flatten(sc_tweets_df)
# ma_tweets_df <- stream_in(con = file(paste0(ALL_TWEETS, "massachussets_tweets.json")))
# ma_tweets_df <- flatten(ma_tweets_df)

# merge all tweet and user info onto labelled tweets
nh_labels_df <- nh_labels_df %>% 
  left_join(nh_unlabelled_csv_df, by = "id") %>% 
  select(id, text, bernie_score, hillary_score, addressee, timestamp, user.id_str) %>% 
  rename(user_id = user.id_str) %>% 
  left_join(nh_user_data_df, by = "user_id") %>% 
  left_join(nh_loc_disp_df, by = "user_id")

sc_labels_df <- sc_labels_df %>% 
  left_join(sc_unlabelled_csv_df, by = "id") %>% 
  select(id, text, bernie_score, hillary_score, addressee, timestamp, user.id_str) %>% 
  rename(user_id = user.id_str) %>% 
  left_join(sc_user_data_df, by = "user_id") %>% 
  left_join(sc_loc_disp_df, by = "user_id")

ma_labels_df <- ma_labels_df %>% 
  left_join(ma_unlabelled_csv_df, by = "id") %>% 
  select(id, text, bernie_score, hillary_score, addressee, timestamp, user.id_str) %>% 
  rename(user_id = user.id_str) %>% 
  left_join(ma_user_data_df, by = "user_id") %>% 
  left_join(ma_loc_disp_df, by = "user_id")

# OUT
write.csv(nh_labels_df, paste0(DATA_OUT, "new_hampshire.csv"), row.names = F)
write.csv(sc_labels_df, paste0(DATA_OUT, "south_carolina.csv"), row.names = F)
write.csv(ma_labels_df, paste0(DATA_OUT, "massachussets.csv"), row.names = F)



