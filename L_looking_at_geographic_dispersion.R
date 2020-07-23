# L_looking_at_geographic_dispersion.R
# a script that imports a list of municipalities in NH, SC and NH. 
# then, the population numbers are normalised so the values range from 0 to 1. 
# then, they are merged with the user-overviews, so that we can have an understanding of 
# what types of places the folks that are tweeting live in. 
# NL, 04/06/20

library(dplyr)

USER_DATA_PATH <- list.files("~/Desktop/SENTIMENT/data/user_tweet_overviews/", full.names = T)
STATE_DATA_PATH <- list.files("~/Desktop/SENTIMENT/data/state_placename_lists/", full.names = T)
OUT_PATH <- "~/Desktop/SENTIMENT/data/users_with_place_proportions/"
states <- c("massachusetts", "new_hampshire", "south_carolina")

perc_pop_per_quantile_df <- NULL

for(i in 1:length(USER_DATA_PATH)){
  new_state_df <- NULL
  
  temp_df <- read.csv(STATE_DATA_PATH[i]) %>% 
    mutate(population = gsub(pattern = ",", replacement = "", population)) %>% 
    mutate(population = as.numeric(population)) %>% 
    mutate(pop_norm = population) %>% 
    mutate_at("pop_norm", ~(scale(.) %>% as.vector)) %>%  # normalising, so that this var has mean==0 and sd==1
    rename(municipality = name)
  
  # quantiles
  temp_df$pop_quantiles <- NA
  quantiles <- quantile(temp_df$population, na.rm = T)
  temp_df$pop_quantiles[which(temp_df$population >= quantiles[1] & temp_df$population < quantiles[2])] <- 1
  temp_df$pop_quantiles[which(temp_df$population > quantiles[2] & temp_df$population < quantiles[3])] <- 2
  temp_df$pop_quantiles[which(temp_df$population > quantiles[3] & temp_df$population < quantiles[4])] <- 3
  temp_df$pop_quantiles[which(temp_df$population > quantiles[4] & temp_df$population <= quantiles[5])] <- 4
  
  # what proportion of state dwellers live in a place in one of the 4 quantiles?
  state_total <- sum(temp_df$population, na.rm = T)
  pop_per_quantile <- NULL
  for(j in 1:4){
    new <- round(sum(temp_df$population[temp_df$pop_quantiles==j], na.rm = T)/state_total*100, digits = 3)
    pop_per_quantile <- c(pop_per_quantile, new)
  }
  
  newline_df <- data.frame(state = states[i],
                           type = "real",
                           q1 = pop_per_quantile[1],
                           q2 = pop_per_quantile[2],
                           q3 = pop_per_quantile[3],
                           q4 = pop_per_quantile[4])
    
  new_state_df <- rbind(new_state_df, newline_df)
  
  users_df <- read.csv(USER_DATA_PATH[i], colClasses = "character") 
  
  merge_df <- left_join(users_df, temp_df, by = "municipality")
  
  # pop per quantile in the geo-located set
  pop_per_quantile <- round(unname(prop.table(table(merge_df$pop_quantiles))*100), digits = 3) 

  newline_df <- data.frame(state = states[i],
                           type = "sample",
                           q1 = pop_per_quantile[1],
                           q2 = pop_per_quantile[2],
                           q3 = pop_per_quantile[3],
                           q4 = pop_per_quantile[4])
  
  new_state_df <- rbind(new_state_df, newline_df)
  perc_pop_per_quantile_df <- rbind(perc_pop_per_quantile_df, new_state_df)
  
  # write out merge_df
  write.csv(merge_df, paste0(OUT_PATH, states[i], ".csv"))
}

write.csv(perc_pop_per_quantile_df, paste0(OUT_PATH, "percentages_per_quantile.csv"))