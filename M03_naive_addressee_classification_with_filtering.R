# M03_naive_addressee_classification_with_filtering.R
# for the purpose of spreading the categorical 'is_mentioning' / 'addressee' variable to all (unlabelled) data,
# there are two approaches: using ML, or by filtering the tweet text for the candidate names. 
# In this script, we filter by candidate names. This can later be compared to text-based classification.
# NL, 21/07/20

library(jsonlite)

FULL_TWEET_SETS <- list.files("Desktop/SENTIMENT/data/located_users_tweets/", pattern = "json", full.names = T)
states <- c("massachussets", "new_hampshire", "south_carolina")
DATA_OUT <- "Desktop/SENTIMENT/data/located_users_tweets/with_mention_dummies/"

for(i in 1:length(FULL_TWEET_SETS)){
  tweets_df <- stream_in(con = file(FULL_TWEET_SETS[i]))
  
  # add mention-dummy for either candidate on to the tweets df
  tweets_df$hillary_mention <- grepl("hillary|clinton|rodham", tolower(tweets_df$text))
  tweets_df$bernie_mention <- grepl("bernie|sanders|bernard|bern", tolower(tweets_df$text))
  
  stream_out(tweets_df, con = file(paste0(DATA_OUT, states[i], ".json")))
}


