# M01_formatting_labelled_data.R
# a script that pulls in the labelled data exported from the collabortweet instance. This script is to get all the data in the right structure, 
# so that it can then be analysed, along with generating overview tables / graphs for this labelled data. 
# NL, 17/07/20

library(dplyr)
library(ggplot2)

DATA_IN <- "Desktop/SENTIMENT/data/labelled_tweets/raw/"
DATA_OUT <- "Desktop/SENTIMENT/data/labelled_tweets/formatted/"

nh_df <- read.csv(paste0(DATA_IN, "NewHampshire_FULL_labelled.csv"), colClasses = "character")
sc_df <- read.csv(paste0(DATA_IN, "SouthCarolina_FULL_labelled.csv"), colClasses = "character")
ma_df <- read.csv(paste0(DATA_IN, "Massachussets_FULL_labelled.csv"), colClasses = "character")

# so, we want a data frame that looks like this:
# tweet_id    HC-dummy    BS-dummy    label

# nh 
nh_df <- nh_df %>% 
  filter(elementId != "both")

nh_df$bernie_score <- NA
nh_df$bernie_score[nh_df$labelText=="-5 -- very negative"] <- -5
nh_df$bernie_score[nh_df$labelText=="-4"] <- -4
nh_df$bernie_score[nh_df$labelText=="-3 -- moderately negative"] <- -3
nh_df$bernie_score[nh_df$labelText=="-2"] <- -2
nh_df$bernie_score[nh_df$labelText=="-1 -- mildly negative"] <- -1
nh_df$bernie_score[nh_df$labelText=="0  -- neutral"] <- 0
nh_df$bernie_score[nh_df$labelText=="+1 -- mildly positive"] <- 1
nh_df$bernie_score[nh_df$labelText=="+2"] <- 2
nh_df$bernie_score[nh_df$labelText=="+3 -- moderately positive"] <- 3
nh_df$bernie_score[nh_df$labelText=="+4"] <- 4
nh_df$bernie_score[nh_df$labelText=="+5 -- very positive"] <- 5

nh_df$bernie_score[nh_df$labelText=="both positive"] <- 3
nh_df$bernie_score[nh_df$labelText=="both negative"] <- -3
nh_df$bernie_score[nh_df$labelText=="positive Sanders"] <- 3
nh_df$bernie_score[nh_df$labelText=="negative Sanders"] <- -3
nh_df$bernie_score[nh_df$labelText=="neither"] <- NA
nh_df$bernie_score[nh_df$labelText=="both neutral"] <- 0
nh_df$bernie_score[nh_df$labelText=="don't know"] <- NA

nh_df$bernie_score[nh_df$parentLabel==" negative Sanders"] <- -3
nh_df$bernie_score[nh_df$parentLabel==" neutral Sanders"] <- 0

# drop scores that are addressed to hillary
nh_df$bernie_score[nh_df$parentLabelText=="Hillary Clinton"] <- NA

# hillary
nh_df$hillary_score <- NA
nh_df$hillary_score[nh_df$labelText=="-5 -- very negative"] <- -5
nh_df$hillary_score[nh_df$labelText=="-4"] <- -4
nh_df$hillary_score[nh_df$labelText=="-3 -- moderately negative"] <- -3
nh_df$hillary_score[nh_df$labelText=="-2"] <- -2
nh_df$hillary_score[nh_df$labelText=="-1 -- mildly negative"] <- -1
nh_df$hillary_score[nh_df$labelText=="0  -- neutral"] <- 0
nh_df$hillary_score[nh_df$labelText=="+1 -- mildly positive"] <- 1
nh_df$hillary_score[nh_df$labelText=="+2"] <- 2
nh_df$hillary_score[nh_df$labelText=="+3 -- moderately positive"] <- 3
nh_df$hillary_score[nh_df$labelText=="+4"] <- 4
nh_df$hillary_score[nh_df$labelText=="+5 -- very positive"] <- 5

nh_df$hillary_score[nh_df$labelText=="both positive"] <- 3
nh_df$hillary_score[nh_df$labelText=="both negative"] <- -3
nh_df$hillary_score[nh_df$labelText=="positive Clinton"] <- 3
nh_df$hillary_score[nh_df$labelText=="negative Clinton"] <- -3
nh_df$hillary_score[nh_df$labelText=="neither"] <- NA
nh_df$hillary_score[nh_df$labelText=="both neutral"] <- 0
nh_df$hillary_score[nh_df$labelText=="don't know"] <- NA

nh_df$hillary_score[nh_df$parentLabel==" negative Clinton"] <- -3
nh_df$hillary_score[nh_df$parentLabel==" neutral Clinton"] <- 0

# drop scores that are addressed to bernie
nh_df$hillary_score[nh_df$parentLabelText=="Bernie Sanders"] <- NA

# addressee
nh_df$addressee <- NA
nh_df$addressee[nh_df$parentLabelText=="Bernie Sanders"] <- "Bernie Sanders"
nh_df$addressee[nh_df$parentLabelText=="Hillary Clinton"] <- "Hillary Clinton"
nh_df$addressee[nh_df$parentLabelText=="both"] <- "both"
nh_df$addressee[nh_df$parentLabelText=="210"] <- "both"
nh_df$addressee[nh_df$labelText=="neither"] <- "neither"
nh_df$addressee[nh_df$labelText=="don't know"] <- "neither"

nh_df <- nh_df %>% 
  rename(external_id = externalId) %>% 
  select(external_id, addressee, bernie_score, hillary_score)

# sc
sc_df <- sc_df %>% 
  filter(elementId != "both")

sc_df$bernie_score <- NA
sc_df$bernie_score[sc_df$labelText=="-5 -- very negative"] <- -5
sc_df$bernie_score[sc_df$labelText=="-4"] <- -4
sc_df$bernie_score[sc_df$labelText=="-3 -- moderately negative"] <- -3
sc_df$bernie_score[sc_df$labelText=="-2"] <- -2
sc_df$bernie_score[sc_df$labelText=="-1 -- mildly negative"] <- -1
sc_df$bernie_score[sc_df$labelText=="0  -- neutral"] <- 0
sc_df$bernie_score[sc_df$labelText=="+1 -- mildly positive"] <- 1
sc_df$bernie_score[sc_df$labelText=="+2"] <- 2
sc_df$bernie_score[sc_df$labelText=="+3 -- moderately positive"] <- 3
sc_df$bernie_score[sc_df$labelText=="+4"] <- 4
sc_df$bernie_score[sc_df$labelText=="+5 -- very positive"] <- 5

sc_df$bernie_score[sc_df$labelText=="both positive"] <- 3
sc_df$bernie_score[sc_df$labelText=="both negative"] <- -3
sc_df$bernie_score[sc_df$labelText=="positive Sanders"] <- 3
sc_df$bernie_score[sc_df$labelText=="negative Sanders"] <- -3
sc_df$bernie_score[sc_df$labelText=="neither"] <- NA
sc_df$bernie_score[sc_df$labelText=="both neutral"] <- 0
sc_df$bernie_score[sc_df$labelText=="don't know"] <- NA

sc_df$bernie_score[sc_df$parentLabel==" negative Sanders"] <- -3
sc_df$bernie_score[sc_df$parentLabel==" neutral Sanders"] <- 0

# drop scores that are addressed to hillary
sc_df$bernie_score[sc_df$parentLabelText=="Hillary Clinton"] <- NA

# hillary
sc_df$hillary_score <- NA
sc_df$hillary_score[sc_df$labelText=="-5 -- very negative"] <- -5
sc_df$hillary_score[sc_df$labelText=="-4"] <- -4
sc_df$hillary_score[sc_df$labelText=="-3 -- moderately negative"] <- -3
sc_df$hillary_score[sc_df$labelText=="-2"] <- -2
sc_df$hillary_score[sc_df$labelText=="-1 -- mildly negative"] <- -1
sc_df$hillary_score[sc_df$labelText=="0  -- neutral"] <- 0
sc_df$hillary_score[sc_df$labelText=="+1 -- mildly positive"] <- 1
sc_df$hillary_score[sc_df$labelText=="+2"] <- 2
sc_df$hillary_score[sc_df$labelText=="+3 -- moderately positive"] <- 3
sc_df$hillary_score[sc_df$labelText=="+4"] <- 4
sc_df$hillary_score[sc_df$labelText=="+5 -- very positive"] <- 5

sc_df$hillary_score[sc_df$labelText=="both positive"] <- 3
sc_df$hillary_score[sc_df$labelText=="both negative"] <- -3
sc_df$hillary_score[sc_df$labelText=="positive Clinton"] <- 3
sc_df$hillary_score[sc_df$labelText=="negative Clinton"] <- -3
sc_df$hillary_score[sc_df$labelText=="neither"] <- NA
sc_df$hillary_score[sc_df$labelText=="both neutral"] <- 0
sc_df$hillary_score[sc_df$labelText=="don't know"] <- NA

sc_df$hillary_score[sc_df$parentLabel==" negative Clinton"] <- -3
sc_df$hillary_score[sc_df$parentLabel==" neutral Clinton"] <- 0

# drop scores that are addressed to bernie
sc_df$hillary_score[sc_df$parentLabelText=="Bernie Sanders"] <- NA

# addressee
sc_df$addressee <- NA
sc_df$addressee[sc_df$parentLabelText=="Bernie Sanders"] <- "Bernie Sanders"
sc_df$addressee[sc_df$parentLabelText=="Hillary Clinton"] <- "Hillary Clinton"
sc_df$addressee[sc_df$parentLabelText=="both"] <- "both"
sc_df$addressee[sc_df$parentLabelText=="136"] <- "both"
sc_df$addressee[sc_df$labelText=="neither"] <- "neither"
sc_df$addressee[sc_df$labelText=="don't know"] <- "neither"

sc_df <- sc_df %>% 
  rename(external_id = externalId) %>% 
  select(external_id, addressee, bernie_score, hillary_score)

# ma
ma_df <- ma_df %>% 
  filter(elementId != "both")

ma_df$bernie_score <- NA
ma_df$bernie_score[ma_df$labelText=="-5 -- very negative"] <- -5
ma_df$bernie_score[ma_df$labelText=="-4"] <- -4
ma_df$bernie_score[ma_df$labelText=="-3 -- moderately negative"] <- -3
ma_df$bernie_score[ma_df$labelText=="-2"] <- -2
ma_df$bernie_score[ma_df$labelText=="-1 -- mildly negative"] <- -1
ma_df$bernie_score[ma_df$labelText=="0  -- neutral"] <- 0
ma_df$bernie_score[ma_df$labelText=="+1 -- mildly positive"] <- 1
ma_df$bernie_score[ma_df$labelText=="+2"] <- 2
ma_df$bernie_score[ma_df$labelText=="+3 -- moderately positive"] <- 3
ma_df$bernie_score[ma_df$labelText=="+4"] <- 4
ma_df$bernie_score[ma_df$labelText=="+5 -- very positive"] <- 5

ma_df$bernie_score[ma_df$labelText=="both positive"] <- 3
ma_df$bernie_score[ma_df$labelText=="both negative"] <- -3
ma_df$bernie_score[ma_df$labelText=="positive Sanders"] <- 3
ma_df$bernie_score[ma_df$labelText=="negative Sanders"] <- -3
ma_df$bernie_score[ma_df$labelText=="neither"] <- NA
ma_df$bernie_score[ma_df$labelText=="both neutral"] <- 0
ma_df$bernie_score[ma_df$labelText=="don't know"] <- NA

ma_df$bernie_score[ma_df$parentLabel==" negative Sanders"] <- -3
ma_df$bernie_score[ma_df$parentLabel==" neutral Sanders"] <- 0

# drop scores that are addressed to hillary
ma_df$bernie_score[ma_df$parentLabelText=="Hillary Clinton"] <- NA

# hillary
ma_df$hillary_score <- NA
ma_df$hillary_score[ma_df$labelText=="-5 -- very negative"] <- -5
ma_df$hillary_score[ma_df$labelText=="-4"] <- -4
ma_df$hillary_score[ma_df$labelText=="-3 -- moderately negative"] <- -3
ma_df$hillary_score[ma_df$labelText=="-2"] <- -2
ma_df$hillary_score[ma_df$labelText=="-1 -- mildly negative"] <- -1
ma_df$hillary_score[ma_df$labelText=="0  -- neutral"] <- 0
ma_df$hillary_score[ma_df$labelText=="+1 -- mildly positive"] <- 1
ma_df$hillary_score[ma_df$labelText=="+2"] <- 2
ma_df$hillary_score[ma_df$labelText=="+3 -- moderately positive"] <- 3
ma_df$hillary_score[ma_df$labelText=="+4"] <- 4
ma_df$hillary_score[ma_df$labelText=="+5 -- very positive"] <- 5

ma_df$hillary_score[ma_df$labelText=="both positive"] <- 3
ma_df$hillary_score[ma_df$labelText=="both negative"] <- -3
ma_df$hillary_score[ma_df$labelText=="positive Clinton"] <- 3
ma_df$hillary_score[ma_df$labelText=="negative Clinton"] <- -3
ma_df$hillary_score[ma_df$labelText=="neither"] <- NA
ma_df$hillary_score[ma_df$labelText=="both neutral"] <- 0
ma_df$hillary_score[ma_df$labelText=="don't know"] <- NA

ma_df$hillary_score[ma_df$parentLabel==" negative Clinton"] <- -3
ma_df$hillary_score[ma_df$parentLabel==" neutral Clinton"] <- 0

# drop scores that are addressed to bernie
ma_df$hillary_score[ma_df$parentLabelText=="Bernie Sanders"] <- NA

# addressee
ma_df$addressee <- NA
ma_df$addressee[ma_df$parentLabelText=="Bernie Sanders"] <- "Bernie Sanders"
ma_df$addressee[ma_df$parentLabelText=="Hillary Clinton"] <- "Hillary Clinton"
ma_df$addressee[ma_df$parentLabelText=="both"] <- "both"
ma_df$addressee[ma_df$parentLabelText=="173"] <- "both"
ma_df$addressee[ma_df$labelText=="neither"] <- "neither"
ma_df$addressee[ma_df$labelText=="don't know"] <- "neither"

ma_df <- ma_df %>% 
  rename(external_id = externalId) %>% 
  select(external_id, addressee, bernie_score, hillary_score)

#write out
write.csv(nh_df, paste0(DATA_OUT, "new_hampshire.csv"), row.names = F)
write.csv(sc_df, paste0(DATA_OUT, "south_carolina.csv"), row.names = F)
write.csv(ma_df, paste0(DATA_OUT, "massachussets.csv"), row.names = F)



