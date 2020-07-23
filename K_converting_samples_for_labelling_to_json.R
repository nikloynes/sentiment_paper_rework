# K_converting_samples_for_labelling_to_json.R
# a script that turns the samples generated for labelling for the sentiment paper into the correct format
# for labelling in collabortweet. 
# NL, 08/04/20

library(jsonlite)
library(dplyr)

DATA_IN <- list.files("Desktop/SENTIMENT/data/samples_for_labelling/")
DATA_IN <- DATA_IN[2:length(DATA_IN)]
DATA_IN_PATHS <- list.files("Desktop/SENTIMENT/data/samples_for_labelling/", full.names = T)
DATA_IN_PATHS <- DATA_IN_PATHS[2:length(DATA_IN_PATHS)]
DATA_OUT_DIR <- ("Desktop/SENTIMENT/data/samples_for_labelling/json/")
DATA_OUT_NAMES <- gsub(".csv", ".json", DATA_IN)

for(i in 1:length(DATA_IN_PATHS)){
  temp_df <- read.csv(DATA_IN_PATHS[i]) %>% 
    mutate(id_str = as.character(id_str)) %>% 
    select(id_str, text)
  
  stream_out(temp_df, con = file(paste0(DATA_OUT_DIR, DATA_OUT_NAMES[i])))
  
}