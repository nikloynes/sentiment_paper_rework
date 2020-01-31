# I_plotting_basic_distributions_for_states.R
# a script that takes the user-tweet-overview csvs for each of the states of interest,
# and plots a number of interesting data points. 
# DATA IN: user-tweet-overviews for MA, NH and SC
# DATA OUT: a number of plots
# NL, 29/01/20

library(dplyr)
library(ggplot2)

NH_df <- read.csv("Desktop/Sentiment Paper/REDO_REPO/data/user_tweet_overviews/new_hampshire_overview.csv")
MA_df <- read.csv("Desktop/Sentiment Paper/REDO_REPO/data/user_tweet_overviews/massachussets_overview.csv")
SC_df <- read.csv("Desktop/Sentiment Paper/REDO_REPO/data/user_tweet_overviews/south_carolina_overview.csv")

# plots of interest:
# - overall candidate mentions by state
# - candidate_mentions by ideology group
# - top 10 municipalities in data
# - something looking at co-mentions of both candidates

ggplot(data = MA_df, aes(y=n_hillary, fill = ideology_bin)) + 
  geom_bar()