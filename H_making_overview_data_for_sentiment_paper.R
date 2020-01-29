# H_making_overview_data_for_sentiment_paper.R
# A script that combines geolocation data, tweet mention data, and user-level metadata
# to produce a summary stat overview 
# DATA IN: located_users, located_users_state_tweets, pabloscores
# DATA OUT: overview table at the user-level, viz
# NL, 28/01/20

library(dplyr)
library(ggplot2)
library(jsonlite)

# iMac
# LOCATED_USERS <- list.files("~/Desktop/sentiment_paper_repo/data/previously_located_users", full.names = T, pattern = ".csv")
# TWEETS <- list.files("~/Desktop/sentiment_paper_repo/data", full.names = T, pattern = ".json")
# PABLOSCORES <- list.files("~/Desktop/sentiment_paper_repo/data/pablo_scores", full.names = T, pattern = ".csv")

# MacBook
# LOCATED_USERS <- list.files("~/Desktop/Sentiment Paper/REDO_REPO/data/previously_located_users", full.names = T, pattern = ".csv")
# TWEETS <- list.files("~/Desktop/Sentiment Paper/REDO_REPO/data", full.names = T, pattern = ".json")
# PABLOSCORES <- list.files("~/Desktop/Sentiment Paper/REDO_REPO/data/pablo_scores", full.names = T, pattern = ".csv")

# HPC
LOCATED_USERS <- list.files("/scratch/nl1676/olympus_local/sentiment_paper_relevant_tweets/previously_located_users", full.names = T, pattern = ".csv")
TWEETS <- list.files("/scratch/nl1676/olympus_local/sentiment_paper_relevant_tweets/located_users_tweets", full.names = T, pattern = ".json")
PABLOSCORES <- list.files("/scratch/olympus/projects/dem_debate_1/pablo_scores", full.names = T, pattern = ".csv")
DATA_OUT <- "/scratch/nl1676/olympus_local/sentiment_paper_relevant_tweets/user_tweet_overviews/"

STATES <- c("massachussets", "new_hampshire", "south_carolina")

pablo_cutoffs <-  c(-0.3396343, 0.8026926)


# DATA IN

pabloscores_df <- NULL
for(i in 1:length(PABLOSCORES)){
  pos1_df <- read.csv(PABLOSCORES[i])
  pos1_df$id_str <- as.character(pos1_df$id_str)
  pabloscores_df <- rbind(pabloscores_df, pos1_df)
  rm(pos1_df)
  gc()
}

pabloscores_df <- pabloscores_df %>% 
  rename(user_id = id_str, pabloscore = theta)

# Do this on a state-by-state basis

for(i in 1:length(TWEETS)){
  # tweets
  tweets_df <- stream_in(con = file(TWEETS[i])) 
  tweets_df <- flatten(tweets_df)
  tweets_df <- tweets_df %>% 
    select(id_str, timestamp, user_id = user.id_str, text)
  
  # add mention-dummy for either candidate on to the tweets df
  tweets_df$hillary_mention <- grepl("hillary|clinton|rodham", tolower(tweets_df$text))
  tweets_df$bernie_mention <- grepl("bernie|sanders|bernard", tolower(tweets_df$text))

  # users
  users_df <- read.csv(LOCATED_USERS[i], colClasses = "character") %>% 
    select(user_id, municipality, admin, country, longitude, latitude)
  # merge pabloscores on to users
  users_df <- left_join(users_df, pabloscores_df, by = "user_id")
  users_df$ideology_bin <- NA
  users_df$ideology_bin[users_df$pabloscore<=pablo_cutoffs[1]] <- "liberal"
  users_df$ideology_bin[users_df$pabloscore>=pablo_cutoffs[2]] <- "conservative"
  users_df$ideology_bin[users_df$pabloscore>pablo_cutoffs[1] &
                          users_df$pabloscore<pablo_cutoffs[2]] <- "moderate"
  
  # merge users on to tweets
  tweets_df <- left_join(tweets_df, users_df, by = "user_id")
  
  # build overview dataframe for users that tweeted in the timeframe
  user_tweet_overview_df <- NULL
  for(j in 1:length(unique(tweets_df$user_id))){
    pos1_df <- tweets_df %>% 
      filter(user_id == unique(tweets_df$user_id)[j])
      newline_df <- data.frame(user_id = unique(tweets_df$user_id)[j],
                               municipality = pos1_df$municipality[1],
                               admin = pos1_df$admin[1],
                               county = pos1_df$country[1],
                               ideology_bin = pos1_df$ideology_bin[1],
                               n_tweets = nrow(pos1_df),
                               n_hillary = sum(pos1_df$hillary_mention),
                               n_bernie = sum(pos1_df$bernie_mention))
    
  }
  
  # write out 
  write.csv(user_tweet_overview_df, paste0(DATA_OUT, STATES[i], "_overview.csv"))
  
}
