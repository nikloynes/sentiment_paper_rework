# N_01_exploring_classified_data.R
# Having classified tweet-level addressees (both through naive tweet-text-filtering and through machine classification) and then also 
# regressed several sentiment scores onto the previously unseen data, it is time to familiarise oneself with the newly generated data. 

# But before this, these tweet data have to be merged in with the previously generated/computed metadata: 
# such as individual-level location,
# location dispersion,
# ideology. 

# Two core questions stand here: 
#   1: Which addressee variable to trust? When do they overlap, when do they not, and why is that the case? Maybe a mini-sample test can 
#      shed more light into the question? 
#   2: Which sentiment predicted value to trust? Again, where do they overlap, where do they differ, and why is this the case? Repeat the n=100 
#      random sample spot-checking to see what's going on. 
# NL, 02/10/20 [long delay since working on this project, as waiting for input from ME, but it never came]
# NL, 09/20/20 -- finishing off and adding spot-checking tweets back into the mix

library(dplyr)
library(jsonlite)

DATA_PATH <- "Desktop/SENTIMENT/data/predictions_rerun/"
FULL_TWEETS <- "Desktop/SENTIMENT/data/located_users_tweets/" # here we will match the tweet ids with user ids
USER_METADATA <- "Desktop/SENTIMENT/data/users_with_place_proportions/" # here we will get the user-level metadata
DATA_OUT <- "Desktop/SENTIMENT/data/final_merged_data/"

#################
# WRANGLING
#################

# DATA IN
nh_df <- stream_in(con = file(paste0(DATA_PATH, "nh_preds.json")))
sc_df <- stream_in(con = file(paste0(DATA_PATH, "sc_preds.json")))
ma_df <- stream_in(con = file(paste0(DATA_PATH, "ma_preds.json")))

# add users to tweets
nh_users_df <- stream_in(con = file(paste0(FULL_TWEETS, "new_hampshire_tweets.json")))
nh_users_df <- flatten(nh_users_df)
nh_users_df <- nh_users_df %>% 
  select(id_str, text, user.id_str, user.name, user.screen_name, created_at, user.followers_count, user.friends_count)
sc_users_df <- stream_in(con = file(paste0(FULL_TWEETS, "southcarolina_tweets.json")))
sc_users_df <- flatten(sc_users_df)
sc_users_df <- sc_users_df %>% 
  select(id_str, text, user.id_str, user.name, user.screen_name, created_at, user.followers_count, user.friends_count)
ma_users_df <- stream_in(con = file(paste0(FULL_TWEETS, "massachussets_tweets.json")))
ma_users_df <- flatten(ma_users_df)
ma_users_df <- ma_users_df %>% 
  select(id_str, text, user.id_str, user.name, user.screen_name, created_at, user.followers_count, user.friends_count)

# While left_join would have been the default way to merge on this data, these dataframes are identical in length. 
# The way to test whether they actually correspond or if something got mangled in the process is to spot-check rows randomly
# and to see whether the tweet text is the same. 
# HAVING DONE THIS EXTENSIVELY, IT IS CLEAR THAT THEY CAN JUST BE STUCK TOGETHER USING CBIND! 

nh_users_df <- nh_users_df[3:length(nh_users_df)] 
sc_users_df <- sc_users_df[3:length(sc_users_df)] 
ma_users_df <- ma_users_df[3:length(ma_users_df)] 

nh_df <- cbind(nh_df, nh_users_df) 
sc_df <- cbind(sc_df, sc_users_df)
ma_df <- cbind(ma_df, ma_users_df)

nh_df <- nh_df %>% 
  rename(user_id = user.id_str)
sc_df <- sc_df %>% 
  rename(user_id = user.id_str)
ma_df <- ma_df %>% 
  rename(user_id = user.id_str)

# clearing memory just for sake of organisation
rm(nh_users_df, sc_users_df, ma_users_df)
gc()

# adding on user-level computed metadata
# data in
nh_metadata_df <- read.csv(paste0(USER_METADATA, "new_hampshire.csv"), colClasses = "character") %>% 
  mutate(X.1 = NULL, X = NULL)
sc_metadata_df <- read.csv(paste0(USER_METADATA, "south_carolina.csv"), colClasses = "character") %>% 
  mutate(X.1 = NULL, X = NULL)
ma_metadata_df <- read.csv(paste0(USER_METADATA, "massachusetts.csv"), colClasses = "character") %>% 
  mutate(X.1 = NULL, X = NULL)

nh_df <- left_join(nh_df, nh_metadata_df, by = "user_id")
sc_df <- left_join(sc_df, sc_metadata_df, by = "user_id")
ma_df <- left_join(ma_df, ma_metadata_df, by = "user_id")

rm(nh_metadata_df, sc_metadata_df, ma_metadata_df)
gc()

#################
# ANALYSIS
#################

# 1 - choosing addresse variable. 
# first, rename the variables for addressee to determine which class represents which candidate. 

# NH - 
# Bernie: 0  
# Hillary: 1  
# both: 2  
# neither: 3

nh_df$preds_add_name <- NA
nh_df$preds_add_name[nh_df$preds_addressee=="0"] <- "Bernie Sanders"
nh_df$preds_add_name[nh_df$preds_addressee=="1"] <- "Hillary Clinton"
nh_df$preds_add_name[nh_df$preds_addressee=="2"] <- "neither"
nh_df$preds_add_name[nh_df$preds_addressee=="3"] <- "both"

# where do they overlap? 
sum(nh_df$addressee==nh_df$preds_add_name) # 14010, or 77.4%
nh_add_diverge_df <- nh_df[which(nh_df$addressee!=nh_df$preds_add_name),] %>% 
  select(id_str, text, addressee, preds_add_name)
# a spot-check of tweets with differently classified addressees shows that the filtering method is MUCH better and hence 
# should be chosen for NH, regardless of its ineffectiveness at identifying 'neither' cases
rm(nh_add_diverge_df)

# SC -
# Bernie: 0  
# Hillary: 1  
# neither: 2  
# both: 3

sc_df$preds_add_name <- NA
sc_df$preds_add_name[sc_df$preds_addressee=="0"] <- "Bernie Sanders"
sc_df$preds_add_name[sc_df$preds_addressee=="1"] <- "Hillary Clinton"
sc_df$preds_add_name[sc_df$preds_addressee=="2"] <- "neither"
sc_df$preds_add_name[sc_df$preds_addressee=="3"] <- "both"

# where do they overlap? 
sum(sc_df$addressee==sc_df$preds_add_name) # 28924, or 87.6%
sc_add_diverge_df <- sc_df[which(sc_df$addressee!=sc_df$preds_add_name),] %>% 
  select(id_str, text, addressee, preds_add_name)
# a spot-check of tweets with differently classified addressees shows that the filtering method is MUCH better and hence 
# should be chosen for SC, regardless of its ineffectiveness at identifying 'neither' cases - same as for NH. 
rm(sc_add_diverge_df)


# MA - 
# Bernie: 0  
# both: 1  
# Hillary: 2  
# neither: 3

ma_df$preds_add_name <- NA
ma_df$preds_add_name[ma_df$preds_addressee=="0"] <- "Bernie Sanders"
ma_df$preds_add_name[ma_df$preds_addressee=="1"] <- "both"
ma_df$preds_add_name[ma_df$preds_addressee=="2"] <- "Hillary Clinton"
ma_df$preds_add_name[ma_df$preds_addressee=="3"] <- "neither"

# where do they overlap? 
sum(ma_df$addressee==ma_df$preds_add_name) # 14010, or 85.3%
ma_add_diverge_df <- ma_df[which(ma_df$addressee!=ma_df$preds_add_name),] %>% 
  select(id_str, text, addressee, preds_add_name)
# a spot-check of tweets with differently classified addressees shows that the filtering method is MUCH better and hence 
# should be chosen for MA, regardless of its ineffectiveness at identifying 'neither' cases -- same as with the other two states. 
rm(ma_add_diverge_df)

# 2
# which of the sentiment scores is the most trustworthy? 
# first - make a mean sentiment score out of both log and forest
# then - make a sample of n=50 for bernie and hillary, for each state, without the computed score, and compare once hand-labelled! 

LABELLING_SAMPLES <- "Desktop/SENTIMENT/data/predictions_rerun/accuracy_check_samples/"
set.seed(1234)

# NH
nh_df$bernie_mean_preds <- (nh_df$bernie_preds_log+nh_df$bernie_preds_forest)/2
nh_df$hillary_mean_preds <- (nh_df$hillary_preds_log+nh_df$hillary_preds_forest)/2
# bernie_sampling_indeces_nh <- which(nh_df$addressee=="Bernie Sanders")
# hillary_sampling_indeces_nh <- which(nh_df$addressee=="Hillary Clinton")
# bernie_sample_indeces_nh <- sample(bernie_sampling_indeces_nh, size = 50)
# hillary_sample_indeces_nh <- sample(hillary_sampling_indeces_nh, size = 50)
# 
# bernie_sample_nh_df <- nh_df[bernie_sample_indeces_nh,] %>% 
#   select(id_str, text, addressee)
# hillary_sample_nh_df <- nh_df[hillary_sample_indeces_nh,] %>% 
#   select(id_str, text, addressee)
# 
# write.csv(bernie_sample_nh_df, paste0(LABELLING_SAMPLES, "bernie_sample_nh.csv"), row.names = F)
# write.csv(hillary_sample_nh_df, paste0(LABELLING_SAMPLES, "hillary_sample_nh.csv"), row.names = F)

# SC
sc_df$bernie_mean_preds <- (sc_df$bernie_preds_log+sc_df$bernie_preds_forest)/2
sc_df$hillary_mean_preds <- (sc_df$hillary_preds_log+sc_df$hillary_preds_forest)/2
# bernie_sampling_indeces_sc <- which(sc_df$addressee=="Bernie Sanders")
# hillary_sampling_indeces_sc <- which(sc_df$addressee=="Hillary Clinton")
# bernie_sample_indeces_sc <- sample(bernie_sampling_indeces_sc, size = 50)
# hillary_sample_indeces_sc <- sample(hillary_sampling_indeces_sc, size = 50)
# 
# bernie_sample_sc_df <- sc_df[bernie_sample_indeces_sc,] %>% 
#   select(id_str, text, addressee)
# hillary_sample_sc_df <- sc_df[hillary_sample_indeces_sc,] %>% 
#   select(id_str, text, addressee)
# 
# write.csv(bernie_sample_sc_df, paste0(LABELLING_SAMPLES, "bernie_sample_sc.csv"), row.names = F)
# write.csv(hillary_sample_sc_df, paste0(LABELLING_SAMPLES, "hillary_sample_sc.csv"), row.names = F)

# MA
ma_df$bernie_mean_preds <- (ma_df$bernie_preds_log+ma_df$bernie_preds_forest)/2
ma_df$hillary_mean_preds <- (ma_df$hillary_preds_log+ma_df$hillary_preds_forest)/2
# bernie_sampling_indeces_ma <- which(ma_df$addressee=="Bernie Sanders")
# hillary_sampling_indeces_ma <- which(ma_df$addressee=="Hillary Clinton")
# bernie_sample_indeces_ma <- sample(bernie_sampling_indeces_ma, size = 50)
# hillary_sample_indeces_ma <- sample(hillary_sampling_indeces_ma, size = 50)
# 
# bernie_sample_ma_df <- ma_df[bernie_sample_indeces_ma,] %>% 
#   select(id_str, text, addressee)
# hillary_sample_ma_df <- ma_df[hillary_sample_indeces_ma,] %>% 
#   select(id_str, text, addressee)
# 
# write.csv(bernie_sample_ma_df, paste0(LABELLING_SAMPLES, "bernie_sample_ma.csv"), row.names = F)
# write.csv(hillary_sample_ma_df, paste0(LABELLING_SAMPLES, "hillary_sample_ma.csv"), row.names = F)


# I labelled the tweets in google sheets, exported them (unfortunately) as excel. 
# Now importing them again. 
# IMPORT LABELLED TWEETS AND LOOK AT WHICH METRIC WORKS BEST WHERE! 
library(readxl)
bernie_labelled_nh_df <- read_xlsx(paste0(LABELLING_SAMPLES, "labelled/bernie_sample_nh.xlsx"), col_types = "text")
bernie_labelled_sc_df <- read_xlsx(paste0(LABELLING_SAMPLES, "labelled/bernie_sample_sc.xlsx"), col_types = "text")
bernie_labelled_ma_df <- read_xlsx(paste0(LABELLING_SAMPLES, "labelled/bernie_sample_ma.xlsx"), col_types = "text")

hillary_labelled_nh_df <- read_xlsx(paste0(LABELLING_SAMPLES, "labelled/hillary_sample_nh.xlsx"), col_types = "text")
hillary_labelled_sc_df <- read_xlsx(paste0(LABELLING_SAMPLES, "labelled/hillary_sample_sc.xlsx"), col_types = "text")
hillary_labelled_ma_df <- read_xlsx(paste0(LABELLING_SAMPLES, "labelled/hillary_sample_ma.xlsx"), col_types = "text")

# merge in the original data
bernie_labelled_nh_df <- left_join(bernie_labelled_nh_df, nh_df, by = "id_str")
bernie_labelled_nh_df <- bernie_labelled_nh_df %>% 
  select(id_str, text.x, addressee.x, bernie_score, bernie_preds_log, bernie_preds_forest, bernie_mean_preds) %>% 
  mutate(bernie_score = as.numeric(bernie_score),
         bernie_preds_log = as.numeric(bernie_preds_log),
         bernie_preds_forest = as.numeric(bernie_preds_forest),
         bernie_mean_preds = as.numeric(bernie_mean_preds))

bernie_labelled_sc_df <- left_join(bernie_labelled_sc_df, sc_df, by = "id_str")
bernie_labelled_sc_df <- bernie_labelled_sc_df %>% 
  select(id_str, text.x, addressee.x, bernie_score, bernie_preds_log, bernie_preds_forest, bernie_mean_preds) %>% 
  mutate(bernie_score = as.numeric(bernie_score),
         bernie_preds_log = as.numeric(bernie_preds_log),
         bernie_preds_forest = as.numeric(bernie_preds_forest),
         bernie_mean_preds = as.numeric(bernie_mean_preds))

bernie_labelled_ma_df <- left_join(bernie_labelled_ma_df, ma_df, by = "id_str")
bernie_labelled_ma_df <- bernie_labelled_ma_df %>% 
  select(id_str, text.x, addressee.x, bernie_score, bernie_preds_log, bernie_preds_forest, bernie_mean_preds) %>% 
  mutate(bernie_score = as.numeric(bernie_score),
         bernie_preds_log = as.numeric(bernie_preds_log),
         bernie_preds_forest = as.numeric(bernie_preds_forest),
         bernie_mean_preds = as.numeric(bernie_mean_preds))


hillary_labelled_nh_df <- left_join(hillary_labelled_nh_df, nh_df, by = "id_str")
hillary_labelled_nh_df <- hillary_labelled_nh_df %>% 
  select(id_str, text.x, addressee.x, hillary_score, hillary_preds_log, hillary_preds_forest, hillary_mean_preds) %>% 
  mutate(hillary_score = as.numeric(hillary_score),
         hillary_preds_log = as.numeric(hillary_preds_log),
         hillary_preds_forest = as.numeric(hillary_preds_forest),
         hillary_mean_preds = as.numeric(hillary_mean_preds))
hillary_labelled_sc_df <- left_join(hillary_labelled_sc_df, sc_df, by = "id_str")
hillary_labelled_sc_df <- hillary_labelled_sc_df %>% 
  select(id_str, text.x, addressee.x, hillary_score, hillary_preds_log, hillary_preds_forest, hillary_mean_preds) %>% 
  mutate(hillary_score = as.numeric(hillary_score),
         hillary_preds_log = as.numeric(hillary_preds_log),
         hillary_preds_forest = as.numeric(hillary_preds_forest),
         hillary_mean_preds = as.numeric(hillary_mean_preds))
hillary_labelled_ma_df <- left_join(hillary_labelled_ma_df, ma_df, by = "id_str")
hillary_labelled_ma_df <- hillary_labelled_ma_df %>% 
  select(id_str, text.x, addressee.x, hillary_score, hillary_preds_log, hillary_preds_forest, hillary_mean_preds) %>% 
  mutate(hillary_score = as.numeric(hillary_score),
         hillary_preds_log = as.numeric(hillary_preds_log),
         hillary_preds_forest = as.numeric(hillary_preds_forest),
         hillary_mean_preds = as.numeric(hillary_mean_preds))

# quantities to calculate: 
# MAE for each of the predicted scores
# correlation for each of the predicted scores
# WITH - the bernie/hillary_score! 

# BERNIE!!!
# NH
# MAE
bernie_labelled_nh_df$error_log <- bernie_labelled_nh_df$bernie_preds_log - bernie_labelled_nh_df$bernie_score
bernie_labelled_nh_df$error_forest <- bernie_labelled_nh_df$bernie_preds_forest - bernie_labelled_nh_df$bernie_score
bernie_labelled_nh_df$error_mean <- bernie_labelled_nh_df$bernie_mean_preds - bernie_labelled_nh_df$bernie_score

mae_nh_bernie_log <- mean(abs(bernie_labelled_nh_df$error_log))
mae_nh_bernie_forest <- mean(abs(bernie_labelled_nh_df$error_forest))
mae_nh_bernie_mean <- mean(abs(bernie_labelled_nh_df$error_mean))

mae_nh_bernie_log
mae_nh_bernie_forest
mae_nh_bernie_mean

# > mae_nh_bernie_log
# [1] 1.34
# > mae_nh_bernie_forest
# [1] 1.473413
# > mae_nh_bernie_mean
# [1] 1.406707

# correlation
cor(bernie_labelled_nh_df[4:7], method = "pearson")
#                         bernie_score bernie_preds_log bernie_preds_forest bernie_mean_preds
# bernie_score           1.0000000        0.6746839           0.6709592         0.7043289
# bernie_preds_log       0.6746839        1.0000000           0.8222628         0.9680025
# bernie_preds_forest    0.6709592        0.8222628           1.0000000         0.9387647
# bernie_mean_preds      0.7043289        0.9680025           0.9387647         1.0000000

# log has the lowest MAE, 1.34, while the highest correlation is the mean score, at .70. I'm going to go with Log. 

# SC
# MAE
bernie_labelled_sc_df$error_log <- bernie_labelled_sc_df$bernie_preds_log - bernie_labelled_sc_df$bernie_score
bernie_labelled_sc_df$error_forest <- bernie_labelled_sc_df$bernie_preds_forest - bernie_labelled_sc_df$bernie_score
bernie_labelled_sc_df$error_mean <- bernie_labelled_sc_df$bernie_mean_preds - bernie_labelled_sc_df$bernie_score

mae_sc_bernie_log <- mean(abs(bernie_labelled_sc_df$error_log))
mae_sc_bernie_forest <- mean(abs(bernie_labelled_sc_df$error_forest))
mae_sc_bernie_mean <- mean(abs(bernie_labelled_sc_df$error_mean))

mae_sc_bernie_log
mae_sc_bernie_forest
mae_sc_bernie_mean
# > mae_sc_bernie_log
# [1] 0.9
# > mae_sc_bernie_forest
# [1] 1.089308
# > mae_sc_bernie_mean
# [1] 0.9364538

# correlation
cor(bernie_labelled_sc_df[4:7], method = "pearson")
#                       bernie_score  bernie_preds_log bernie_preds_forest bernie_mean_preds
# bernie_score           1.0000000        0.5932502           0.1952718         0.4873482
# bernie_preds_log       0.5932502        1.0000000           0.4495748         0.8844069
# bernie_preds_forest    0.1952718        0.4495748           1.0000000         0.8144982
# bernie_mean_preds      0.4873482        0.8844069           0.8144982         1.0000000


# log has both the lowest MAE (0.9) and the highest correlation (.59). 

# MA
# MAE
bernie_labelled_ma_df$error_log <- bernie_labelled_ma_df$bernie_preds_log - bernie_labelled_ma_df$bernie_score
bernie_labelled_ma_df$error_forest <- bernie_labelled_ma_df$bernie_preds_forest - bernie_labelled_ma_df$bernie_score
bernie_labelled_ma_df$error_mean <- bernie_labelled_ma_df$bernie_mean_preds - bernie_labelled_ma_df$bernie_score

mae_ma_bernie_log <- mean(abs(bernie_labelled_ma_df$error_log))
mae_ma_bernie_forest <- mean(abs(bernie_labelled_ma_df$error_forest))
mae_ma_bernie_mean <- mean(abs(bernie_labelled_ma_df$error_mean))

mae_ma_bernie_log
mae_ma_bernie_forest
mae_ma_bernie_mean

# > mae_ma_bernie_log
# [1] 1.04
# > mae_ma_bernie_forest
# [1] 1.258567
# > mae_ma_bernie_mean
# [1] 1.124359


# correlation
cor(bernie_labelled_ma_df[4:7], method = "pearson")
#                         bernie_score bernie_preds_log bernie_preds_forest bernie_mean_preds
# bernie_score           1.0000000        0.4575580           0.3700827         0.4499701
# bernie_preds_log       0.4575580        1.0000000           0.7826762         0.9738786
# bernie_preds_forest    0.3700827        0.7826762           1.0000000         0.9035662
# bernie_mean_preds      0.4499701        0.9738786           0.9035662         1.0000000


# The Log score is easily the lowest MAE, at 1.04 - and almost also for the correlation, .45

# HILLARY!!!
# NH
# MAE
hillary_labelled_nh_df$error_log <- hillary_labelled_nh_df$hillary_preds_log - hillary_labelled_nh_df$hillary_score
hillary_labelled_nh_df$error_forest <- hillary_labelled_nh_df$hillary_preds_forest - hillary_labelled_nh_df$hillary_score
hillary_labelled_nh_df$error_mean <- hillary_labelled_nh_df$hillary_mean_preds - hillary_labelled_nh_df$hillary_score

mae_nh_hillary_log <- mean(abs(hillary_labelled_nh_df$error_log), na.rm = T)
mae_nh_hillary_forest <- mean(abs(hillary_labelled_nh_df$error_forest), na.rm = T)
mae_nh_hillary_mean <- mean(abs(hillary_labelled_nh_df$error_mean), na.rm = T)

mae_nh_hillary_log
mae_nh_hillary_forest
mae_nh_hillary_mean

# > mae_nh_hillary_log
# [1] 1.591837
# > mae_nh_hillary_forest
# [1] 1.593003
# > mae_nh_hillary_mean
# [1] 1.508361


# correlation
cor(hillary_labelled_nh_df[4:7], use = "complete.obs", method = "pearson")
#                         hillary_score hillary_preds_log hillary_preds_forest hillary_mean_preds
# hillary_score            1.0000000         0.4458542            0.4875753          0.4770518
# hillary_preds_log        0.4458542         1.0000000            0.8538642          0.9812814
# hillary_preds_forest     0.4875753         0.8538642            1.0000000          0.9381178
# hillary_mean_preds       0.4770518         0.9812814            0.9381178          1.0000000

# Everything's pretty close here, and certainly not as precise as with Bernie. The lowest MAE is the mean score, and the highest correlation is the forest.

# SC
# MAE
hillary_labelled_sc_df$error_log <- hillary_labelled_sc_df$hillary_preds_log - hillary_labelled_sc_df$hillary_score
hillary_labelled_sc_df$error_forest <- hillary_labelled_sc_df$hillary_preds_forest - hillary_labelled_sc_df$hillary_score
hillary_labelled_sc_df$error_mean <- hillary_labelled_sc_df$hillary_mean_preds - hillary_labelled_sc_df$hillary_score

mae_sc_hillary_log <- mean(abs(hillary_labelled_sc_df$error_log), na.rm = T)
mae_sc_hillary_forest <- mean(abs(hillary_labelled_sc_df$error_forest), na.rm = T)
mae_sc_hillary_mean <- mean(abs(hillary_labelled_sc_df$error_mean), na.rm = T)

mae_sc_hillary_log
mae_sc_hillary_forest
mae_sc_hillary_mean

# > mae_sc_hillary_log
# [1] 1.64
# > mae_sc_hillary_forest
# [1] 1.82619
# > mae_sc_hillary_mean
# [1] 1.733095

# correlation
cor(hillary_labelled_sc_df[4:7], use = "complete.obs", method = "pearson")
#                         hillary_score hillary_preds_log hillary_preds_forest hillary_mean_preds
# hillary_score            1.0000000         0.5638773            0.5172030          0.5599701
# hillary_preds_log        0.5638773         1.0000000            0.8926570          0.9830886
# hillary_preds_forest     0.5172030         0.8926570            1.0000000          0.9601046
# hillary_mean_preds       0.5599701         0.9830886            0.9601046          1.0000000

# Again, we're looking at a situation where the hillary score is predicted far worse than the bernie score. The lowest MAE is log (1.64), 
# the highest correlation is also log. 


# MA
# MAE
hillary_labelled_ma_df$error_log <- hillary_labelled_ma_df$hillary_preds_log - hillary_labelled_ma_df$hillary_score
hillary_labelled_ma_df$error_forest <- hillary_labelled_ma_df$hillary_preds_forest - hillary_labelled_ma_df$hillary_score
hillary_labelled_ma_df$error_mean <- hillary_labelled_ma_df$hillary_mean_preds - hillary_labelled_ma_df$hillary_score

mae_ma_hillary_log <- mean(abs(hillary_labelled_ma_df$error_log), na.rm = T)
mae_ma_hillary_forest <- mean(abs(hillary_labelled_ma_df$error_forest), na.rm = T)
mae_ma_hillary_mean <- mean(abs(hillary_labelled_ma_df$error_mean), na.rm = T)

mae_ma_hillary_log
mae_ma_hillary_forest
mae_ma_hillary_mean
# > mae_ma_hillary_log
# [1] 1.44
# > mae_ma_hillary_forest
# [1] 1.983017
# > mae_ma_hillary_mean
# [1] 1.662092


# correlation
cor(hillary_labelled_ma_df[4:7], use = "complete.obs", method = "pearson")
#                         hillary_score hillary_preds_log hillary_preds_forest hillary_mean_preds
# hillary_score            1.0000000         0.6906023            0.5252743          0.6564081
# hillary_preds_log        0.6906023         1.0000000            0.8471367          0.9815902
# hillary_preds_forest     0.5252743         0.8471367            1.0000000          0.9330332
# hillary_mean_preds       0.6564081         0.9815902            0.9330332          1.0000000

# Here, the best score by MAE is the log score, which is also the best score by the correlation metric. 

# One more interesting thing to learn would be whether the predicted values tend to over- or under-estimate
# the real value. This will aid interpretation of results in the end, perhaps. 
# I'll do this analysis only for the types of scores I end up selecting. 

# BERNIE:
# NH, model: log
# n over/under/exact
length(bernie_labelled_nh_df$error_log[bernie_labelled_nh_df$error_log>0]) # n overestimated (prediction more positive than real) 26
length(bernie_labelled_nh_df$error_log[bernie_labelled_nh_df$error_log<0]) # n underestimated (prediction more negative than real) 8
length(bernie_labelled_nh_df$error_log[bernie_labelled_nh_df$error_log==0]) # exact 16

# mean prediction value for the over/under/exact groups
mean(bernie_labelled_nh_df$bernie_score[bernie_labelled_nh_df$error_log>0]) 
# 4.34 -- this mean it is not so good at getting negative scores right for bernie
mean(bernie_labelled_nh_df$bernie_score[bernie_labelled_nh_df$error_log<0])
# 7.875 -- so here we're learning the inverse, the model more often underestimates the positivity of fairly positive tweets
median(bernie_labelled_nh_df$bernie_score[bernie_labelled_nh_df$error_log==0])
# however, the sentiment score for bernie that it most often gets right is 8

# SC, model: log
# n over/under/exact
length(bernie_labelled_sc_df$error_log[bernie_labelled_sc_df$error_log>0]) # n overestimated (prediction more positive than real) 22
length(bernie_labelled_sc_df$error_log[bernie_labelled_sc_df$error_log<0]) # n underestimated (prediction more negative than real) 10
length(bernie_labelled_sc_df$error_log[bernie_labelled_sc_df$error_log==0]) # exact 18

# mean prediction value for the over/under/exact groups
mean(bernie_labelled_sc_df$bernie_score[bernie_labelled_sc_df$error_log>0]) 
# 6.04 -- this mean it is not so good at getting low-ish scores right for bernie
mean(bernie_labelled_sc_df$bernie_score[bernie_labelled_sc_df$error_log<0])
# 7.2 -- so here we're learning the inverse, the model more often underestimates the positivity of fairly positive tweets
median(bernie_labelled_sc_df$bernie_score[bernie_labelled_sc_df$error_log==0])
# however, the sentiment score for bernie that it most often gets right is 8 - good to know. 

# MA, model: log
# n over/under/exact
length(bernie_labelled_ma_df$error_log[bernie_labelled_ma_df$error_log>0]) # n overestimated (prediction more positive than real) 15
length(bernie_labelled_ma_df$error_log[bernie_labelled_ma_df$error_log<0]) # n underestimated (prediction more negative than real) 14
length(bernie_labelled_ma_df$error_log[bernie_labelled_ma_df$error_log==0]) # exact 21

# mean prediction value for the over/under/exact groups
mean(bernie_labelled_ma_df$bernie_score[bernie_labelled_ma_df$error_log>0]) 
# 5.4 -- this means it is not so good at getting low-ish scores right for bernie
mean(bernie_labelled_ma_df$bernie_score[bernie_labelled_ma_df$error_log<0])
# 8.14 -- so here we're learning the inverse, the model more often underestimates the positivity of fairly positive tweets
median(bernie_labelled_ma_df$bernie_score[bernie_labelled_ma_df$error_log==0])
# however, the sentiment maore for bernie that it most often gets right is 8 - good to know. 


# HILLARY:
# NH, model: mean
# n over/under/exact
length(hillary_labelled_nh_df$error_mean[hillary_labelled_nh_df$error_mean>0]) # n overestimated (prediction more positive than real) 17
length(hillary_labelled_nh_df$error_mean[hillary_labelled_nh_df$error_mean<0]) # n underestimated (prediction more negative than real) 34
length(hillary_labelled_nh_df$error_mean[hillary_labelled_nh_df$error_mean==0]) # exact 1

# mean prediction value for the over/under/exact groups
mean(hillary_labelled_nh_df$hillary_score[hillary_labelled_nh_df$error_mean>0], na.rm = T) 
# 3.31 -- this mean it is not so good at getting negative scores right for hillary
mean(hillary_labelled_nh_df$hillary_score[hillary_labelled_nh_df$error_mean<0], na.rm = T)
# 4.42 -- so here we're learning the inverse, the model more often underestimates the positivity of fairly positive tweets
#median(hillary_labelled_nh_df$hillary_score[hillary_labelled_nh_df$error_mean==0], na.rm = T)
# not really relevant, we only have one case. 

# SC, model: log
# n over/under/exact
length(hillary_labelled_sc_df$error_log[hillary_labelled_sc_df$error_log>0]) # n overestimated (prediction more positive than real) 9
length(hillary_labelled_sc_df$error_log[hillary_labelled_sc_df$error_log<0]) # n underestimated (prediction more negative than real) 23
length(hillary_labelled_sc_df$error_log[hillary_labelled_sc_df$error_log==0]) # exact 18

# mean prediction value for the over/under/exact groups
mean(hillary_labelled_sc_df$hillary_score[hillary_labelled_sc_df$error_log>0]) 
# 2.77 -- this mean it is not so good at getting low-ish scores right for hillary
mean(hillary_labelled_sc_df$hillary_score[hillary_labelled_sc_df$error_log<0])
# 6.8 -- so here we're learning the inverse, the model more often underestimates the positivity of fairly positive tweets
median(hillary_labelled_sc_df$hillary_score[hillary_labelled_sc_df$error_log==0])
# however, the sentiment score for hillary that it most often gets right is 3 - good to know. 

# MA, model: log
# n over/under/exact
length(hillary_labelled_ma_df$error_log[hillary_labelled_ma_df$error_log>0]) # n overestimated (prediction more positive than real) 16
length(hillary_labelled_ma_df$error_log[hillary_labelled_ma_df$error_log<0]) # n underestimated (prediction more negative than real) 20
length(hillary_labelled_ma_df$error_log[hillary_labelled_ma_df$error_log==0]) # exact 14

# mean prediction value for the over/under/exact groups
mean(hillary_labelled_ma_df$hillary_score[hillary_labelled_ma_df$error_log>0]) 
# 2.93 -- this means it is not so good at getting low-ish scores right for hillary
mean(hillary_labelled_ma_df$hillary_score[hillary_labelled_ma_df$error_log<0])
# 6.8 -- so here we're learning the inverse, the model more often underestimates the positivity of fairly positive tweets
median(hillary_labelled_ma_df$hillary_score[hillary_labelled_ma_df$error_log==0])
# however, the sentiment maore for hillary that it most often gets right is 5.5 - good to know. 


# Main takeaway from all of this is:
#   - we have a range of models that work fairly well (average error typically around 1) at predicting sentiment scores for the 
#     population of geo-located tweets we're interested in. 
#   - On average, the log model works best for this task. 
#   - For Bernie, the model typically gets broadly positive tweets bang on, while it's the inverse for Hillary tweets across states.
#   - Crucially, the model tends to be more prone to over-estimating Bernie's scores, while a lot more prone to under-estimating Hillary's. 
#     This is something that should maybe be taken into account when using these sentiment scores to model vote shares in the respective states. 


# NOW,
# DATA OUT! 

# labelled spot-checking samples
write.csv(bernie_labelled_nh_df, paste0(LABELLING_SAMPLES, "labelled/bernie_labelled_nh_with_error_metrics.csv"), row.names = F)
write.csv(bernie_labelled_sc_df, paste0(LABELLING_SAMPLES, "labelled/bernie_labelled_sc_with_error_metrics.csv"), row.names = F)
write.csv(bernie_labelled_ma_df, paste0(LABELLING_SAMPLES, "labelled/bernie_labelled_ma_with_error_metrics.csv"), row.names = F)

write.csv(hillary_labelled_nh_df, paste0(LABELLING_SAMPLES, "labelled/hillary_labelled_nh_with_error_metrics.csv"), row.names = F)
write.csv(hillary_labelled_sc_df, paste0(LABELLING_SAMPLES, "labelled/hillary_labelled_sc_with_error_metrics.csv"), row.names = F)
write.csv(hillary_labelled_ma_df, paste0(LABELLING_SAMPLES, "labelled/hillary_labelled_ma_with_error_metrics.csv"), row.names = F)

# complete, merged data. 
write.csv(nh_df, paste0(DATA_OUT, "nh.csv"), row.names = F)
write.csv(sc_df, paste0(DATA_OUT, "sc.csv"), row.names = F)
write.csv(ma_df, paste0(DATA_OUT, "ma.csv"), row.names = F)
