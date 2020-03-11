# J_creating_samples_for_human_labelling.R
# a script that generates samples of n=1000 tweets by unique users from the right of the distribution, i.e. as close to the
# date of the primaries as possible. 
# NL, 06/03/2020

library(dplyr)
library(ggplot2)
library(jsonlite)

USER_OVERVIEWS <- list.files("Desktop/SENTIMENT/data/user_tweet_overviews/", full.names = T)
TWEETS <- list.files("Desktop/SENTIMENT/data/located_users_tweets/", full.names = T)
DATA_OUT <- "Desktop/SENTIMENT/data/samples_for_labelling/"
PLOT_PATH <- "Desktop/SENTIMENT/plots/"

STATES <- c("Massachusetts", "New Hampshire", "South Carolina")

ma_users_df <- read.csv(USER_OVERVIEWS[1]) %>% 
  mutate(user_id = as.character(user_id),
         X = NULL)
nh_users_df <- read.csv(USER_OVERVIEWS[2]) %>% 
  mutate(user_id = as.character(user_id),
         X = NULL)
sc_users_df <- read.csv(USER_OVERVIEWS[3]) %>% 
  mutate(user_id = as.character(user_id),
         X = NULL)

set.seed(1234)

# USER_ID samples for each state
ma_indeces <- sample(1:nrow(ma_users_df), size = 1000, replace = FALSE)
nh_indeces <- sample(1:nrow(nh_users_df), size = 1000, replace = FALSE)
sc_indeces <- sample(1:nrow(sc_users_df), size = 1000, replace = FALSE)

ma_sample <- ma_users_df$user_id[ma_indeces]
nh_sample <- nh_users_df$user_id[nh_indeces]
sc_sample <- sc_users_df$user_id[sc_indeces]

# Histograms:
# number of tweets for SAMPLED users for the entire timeframe
# MA

ma_sample_hist <- ggplot(ma_users_df[ma_users_df$user_id %in% ma_sample,], aes(x = n_tweets)) + 
  geom_histogram(binwidth = 1) + 
  scale_x_continuous(limits = c(0, 100)) +
  ggtitle("Massachussets sample")

ggsave(filename = paste0(PLOT_PATH, "ma_sample_hist.png"),
       plot = ma_sample_hist,
       device = "png",
       width = 15,
       height = 10,
       units = "cm",
       dpi = 250)

# NH

nh_sample_hist <- ggplot(nh_users_df[nh_users_df$user_id %in% nh_sample,], aes(x = n_tweets)) + 
  geom_histogram(binwidth = 1) + 
  scale_x_continuous(limits = c(0, 100)) +
  ggtitle("New Hampshire sample")

ggsave(filename = paste0(PLOT_PATH, "nh_sample_hist.png"),
       plot = nh_sample_hist,
       device = "png",
       width = 15,
       height = 10,
       units = "cm",
       dpi = 250)

# SC

sc_sample_hist <- ggplot(sc_users_df[sc_users_df$user_id %in% sc_sample,], aes(x = n_tweets)) + 
  geom_histogram(binwidth = 1) + 
  scale_x_continuous(limits = c(0, 100)) +
  ggtitle("South Carolina sample")

ggsave(filename = paste0(PLOT_PATH, "sc_sample_hist.png"),
       plot = sc_sample_hist,
       device = "png",
       width = 15,
       height = 10,
       units = "cm",
       dpi = 250)


# TWEET SAMPLING! 

# MA
ma_tweets_df <- stream_in(con = file(TWEETS[1]))
ma_tweets_df <- flatten(ma_tweets_df)

ma_tweet_sample_df <- NULL

for(i in 1:length(ma_sample)){
  
  subset_df <- ma_tweets_df %>% 
    filter(user.id_str == ma_sample[i])
  
  this_tweet <- which(subset_df$timestamp==sort(subset_df$timestamp, decreasing = T)[1])
  if(length(this_tweet)>1){
    this_tweet <- this_tweet[1]
  }
  
  ma_tweet_sample_df <- rbind(ma_tweet_sample_df, subset_df[this_tweet,])
}

# remove erroneously included duplicate tweets
ma_tweet_sample_df <- ma_tweet_sample_df %>% 
  distinct(id_str, .keep_all = T) %>% 
  select(timestamp, id_str, text, id, user.id_str)

write.csv(ma_tweet_sample_df, paste0(DATA_OUT, "ma_tweet_sample.csv"), row.names = F)

rm(ma_tweets_df)
gc()


# NH 
nh_tweets_df <- stream_in(con = file(TWEETS[2]))
nh_tweets_df <- flatten(nh_tweets_df)

nh_tweet_sample_df <- NULL

for(i in 1:length(nh_sample)){
  
  subset_df <- nh_tweets_df %>% 
    filter(user.id_str == nh_sample[i])
  
  this_tweet <- which(subset_df$timestamp==sort(subset_df$timestamp, decreasing = T)[1])
  if(length(this_tweet)>1){
    this_tweet <- this_tweet[1]
  }
  
  nh_tweet_sample_df <- rbind(nh_tweet_sample_df, subset_df[this_tweet,])
}

# remove erroneously included duplicate tweets
nh_tweet_sample_df <- nh_tweet_sample_df %>% 
  distinct(id_str, .keep_all = T) %>% 
  select(timestamp, id_str, text, id, user.id_str)

write.csv(nh_tweet_sample_df, paste0(DATA_OUT, "nh_tweet_sample.csv"), row.names = F)

rm(nh_tweets_df)
gc()


# SC 
sc_tweets_df <- stream_in(con = file(TWEETS[3]))
sc_tweets_df <- flatten(sc_tweets_df)

sc_tweet_sample_df <- NULL

for(i in 1:length(sc_sample)){
  
  subset_df <- sc_tweets_df %>% 
    filter(user.id_str == sc_sample[i])
  
  this_tweet <- which(subset_df$timestamp==sort(subset_df$timestamp, decreasing = T)[1])
  if(length(this_tweet)>1){
    this_tweet <- this_tweet[1]
  }
  
  sc_tweet_sample_df <- rbind(sc_tweet_sample_df, subset_df[this_tweet,])
}

# remove erroneously included duplicate tweets
sc_tweet_sample_df <- sc_tweet_sample_df %>% 
  distinct(id_str, .keep_all = T) %>% 
  select(timestamp, id_str, text, id, user.id_str)

write.csv(sc_tweet_sample_df, paste0(DATA_OUT, "sc_tweet_sample.csv"), row.names = F)

rm(sc_tweets_df)
gc()


# NOW generate gold standard samples
ma_gold_indeces <- sample(1:1000, 100, replace = F)
nh_gold_indeces <- sample(1:1000, 100, replace = F)
sc_gold_indeces <- sample(1:1000, 100, replace = F)

ma_gold_sample_df <- ma_tweet_sample_df[ma_gold_indeces,]
nh_gold_sample_df <- nh_tweet_sample_df[nh_gold_indeces,]
sc_gold_sample_df <- sc_tweet_sample_df[sc_gold_indeces,]

write.csv(ma_gold_sample_df, paste0(DATA_OUT, "ma_gold_sample.csv"), row.names = F)
write.csv(nh_gold_sample_df, paste0(DATA_OUT, "nh_gold_sample.csv"), row.names = F)
write.csv(sc_gold_sample_df, paste0(DATA_OUT, "sc_gold_sample.csv"), row.names = F)


