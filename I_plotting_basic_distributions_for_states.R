# I_plotting_basic_distributions_for_states.R
# a script that takes the user-tweet-overview csvs for each of the states of interest,
# and plots a number of interesting data points. 
# DATA IN: user-tweet-overviews for MA, NH and SC
# DATA OUT: a number of plots
# NL, 29/01/20

library(dplyr)
library(ggplot2)

# NH_df <- read.csv("Desktop/Sentiment Paper/REDO_REPO/data/user_tweet_overviews/new_hampshire_overview.csv")
# MA_df <- read.csv("Desktop/Sentiment Paper/REDO_REPO/data/user_tweet_overviews/massachussets_overview.csv")
# SC_df <- read.csv("Desktop/Sentiment Paper/REDO_REPO/data/user_tweet_overviews/south_carolina_overview.csv")

NH_df <- read.csv("/Users/nikloynes/Desktop/sentiment_paper_repo/data/user_tweet_overviews/new_hampshire_overview.csv")
MA_df <- read.csv("/Users/nikloynes/Desktop/sentiment_paper_repo/data/user_tweet_overviews/massachussets_overview.csv")
SC_df <- read.csv("/Users/nikloynes/Desktop/sentiment_paper_repo/data/user_tweet_overviews/south_carolina_overview.csv")

states <- list(NH_df, MA_df, SC_df)

n_tweets_df <- data.frame(state = c("New Hampshire", "Massachusetts", "South Carolina"),
                          n_tweets = c(17929, 132756, 54138))

# plots of interest:
# - overall candidate mentions by state
# - candidate_mentions by ideology group
# - top 10 municipalities in data
# - something looking at co-mentions of both candidates

# create dataset
# state   ideology_bin    mention_group   n_mentions

aggregate_mentions_df <- NULL

for(i in 1:length(states)){
  
  for(j in 1:length(unique(states[[i]]$ideology_bin))){
    
    if(is.na(unique(states[[i]]$ideology_bin)[j])){
      id_group_df <- states[[i]] %>% 
        filter(is.na(ideology_bin))
    } else{
      id_group_df <- states[[i]] %>% 
        filter(ideology_bin == unique(states[[i]]$ideology_bin)[j])
    }
    
    n_tweets <- sum(id_group_df$n_tweets)
    n_bernie <- sum(id_group_df$n_bernie)
    n_hillary <- sum(id_group_df$n_hillary)
    
    line1_df <- data.frame(state = id_group_df$admin[1],
                           ideology_bin = id_group_df$ideology_bin[1],
                           mention_group = "total",
                           n_mentions = n_tweets)
    
    line2_df <- data.frame(state = id_group_df$admin[1],
                           ideology_bin = id_group_df$ideology_bin[1],
                           mention_group = "bernie",
                           n_mentions = n_bernie)
    
    line3_df <- data.frame(state = id_group_df$admin[1],
                           ideology_bin = id_group_df$ideology_bin[1],
                           mention_group = "hillary",
                           n_mentions = n_hillary)
    
    aggregate_mentions_df <- rbind(aggregate_mentions_df, line1_df, line2_df, line3_df)
    
  }
  
}

aggregate_mentions_df$ideology_bin <- as.character(aggregate_mentions_df$ideology_bin)
aggregate_mentions_df$ideology_bin[which(is.na(aggregate_mentions_df$ideology_bin))] <- "not_classifiable"


# plot depicting overall mentions by ideology group

total_mentions_df <- aggregate_mentions_df %>% 
  filter(mention_group=="total")

total_mentions_plot <- ggplot(data = total_mentions_df, aes(x=mention_group, y=n_mentions, fill = ideology_bin)) + 
  geom_bar(stat = "identity", position=position_dodge()) +
  facet_wrap(~state) +
  scale_fill_manual(values=c("#ff0000", "#0000ff", "#ffcc00", "#808080")) 

ggsave(filename = "Desktop/sentiment_paper_repo/plots/total_mentions_plot.png",
       plot = total_mentions_plot,
       device = "png",
       width = 15,
       height = 12,
       units = "cm")

# plot depicting normalised candidate mentions by ideology, by state

candidate_mentions_df <- aggregate_mentions_df %>% 
  filter(mention_group!="total") 

for(i in 1:length(unique(candidate_mentions_df$state))){
  
  for(j in 1:length(unique(candidate_mentions_df$ideology_bin))){
    
    for(l in 1:length(unique(candidate_mentions_df$mention_group))){
      
      candidate_mentions_df$mention_ratio[candidate_mentions_df$ideology_bin==unique(candidate_mentions_df$ideology_bin)[j] &
                                            candidate_mentions_df$state==unique(candidate_mentions_df$state)[i] &
                                            candidate_mentions_df$mention_group==unique(candidate_mentions_df$mention_group)[l]] <- 
        candidate_mentions_df$n_mentions[candidate_mentions_df$ideology_bin==unique(candidate_mentions_df$ideology_bin)[j] &
                                           candidate_mentions_df$state==unique(candidate_mentions_df$state)[i] &
                                           candidate_mentions_df$mention_group==unique(candidate_mentions_df$mention_group)[l]] / (total_mentions_df$n_mentions[total_mentions_df$ideology_bin==unique(candidate_mentions_df$ideology_bin)[j] &
                                                                                                                                                              total_mentions_df$state==unique(candidate_mentions_df$state)[i]]/2)
    }
  }
}


candidate_mentions_ideology_plot <- ggplot(data = candidate_mentions_df, aes(x=mention_group, y=mention_ratio, fill = ideology_bin)) + 
  geom_bar(stat = "identity", position=position_dodge()) +
  facet_wrap(~state) +
  geom_hline(yintercept = 1, linetype = "dashed", color = "blue") +
  scale_fill_manual(values=c("#ff0000", "#0000ff", "#ffcc00", "#808080")) 

ggsave(filename = "Desktop/sentiment_paper_repo/plots/candidate_mentions_ideology_plot.png",
       plot = candidate_mentions_ideology_plot,
       device = "png",
       width = 15,
       height = 12,
       units = "cm")

