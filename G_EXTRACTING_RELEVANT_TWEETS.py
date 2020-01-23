#!/usr/bin/env python
# coding: utf-8

# G_EXTRACTING_RELEVANT_TWEETS.ipynb
# 
# This notebook pulls out the relevant tweets out of the previously filtered tweets which match the following conditions:
#     1. Is from a user that has previously been located to IA, SC or MA
#     2. The tweet was posted during the 3-week period leading up to the respective dem primary
#     
# NL, 22/01/2020
# NL, 23/01/2020 -- first alpha for testing through sbatch
#     
# SEQUENCE:
#     1. data i/o
#     2. define date ranges
#     3. go through pertinent jsons and write the pertinent tweets to a (three) new json stream(s)

# In[1]:


import glob
from pathlib import Path
import pandas as pd
import json
import datetime
from multiprocessing import Pool


# In[34]:


DATA_PATH = "/scratch/nl1676/olympus_local/sentiment_paper_relevant_tweets/"
TWEETS = glob.glob(DATA_PATH+"*.json")


# In[49]:


# IO --> these are the users that had already been located
ia_df = pd.read_csv(DATA_PATH + "previously_located_users/iowa.csv", dtype = {"user_id" : "str"})
ma_df = pd.read_csv(DATA_PATH + "previously_located_users/massachussets.csv", dtype = {"user_id" : "str"})
sc_df = pd.read_csv(DATA_PATH + "previously_located_users/south_carolina.csv", dtype = {"user_id" : "str"})


# In[62]:


# make the unique user ids for each state into their own objects
user_ids = [list(ia_df['user_id']), list(sc_df['user_id']), list(ma_df['user_id'])]


# The time frame of interest is 3 weeks leading up to each of 3 primaries: **New Hampshire [February 9, 2016], South Carolina [February 27, 2016], Massachusetts [March 1, 2016]**. 

# In[5]:


my_delta = datetime.timedelta(days = 1)

# relevant date range: 
# create an array of all pertinent days
start_ia = datetime.datetime.strptime("2016-01-19", "%Y-%m-%d")
end_ia = datetime.datetime.strptime("2016-02-09", "%Y-%m-%d")
start_sc = datetime.datetime.strptime("2016-02-06", "%Y-%m-%d")
end_sc = datetime.datetime.strptime("2016-02-27", "%Y-%m-%d")
start_ma = datetime.datetime.strptime("2016-02-09", "%Y-%m-%d")
end_ma = datetime.datetime.strptime("2016-03-01", "%Y-%m-%d")
date_range_ia = [start_ia + datetime.timedelta(days=x) for x in range(0, (end_ia-start_ia).days)]
date_range_sc = [start_sc + datetime.timedelta(days=x) for x in range(0, (end_sc-start_sc).days)]
date_range_ma = [start_ma + datetime.timedelta(days=x) for x in range(0, (end_ma-start_ma).days)]


# In[29]:


# dates strings turns the dates into the right format for extracting the right collection files.

all_state_dates = [date_range_ia, date_range_sc, date_range_ma]
all_state_date_strings = [[],[],[]]

for i,element in enumerate(all_state_dates):
    for date in element:
        pos1 = date.strftime("%m_%d_%Y")
        all_state_date_strings[i].append(pos1)


# In[37]:


# writing out pertinent files for each state
pertinent_files = [[],[],[]]

for i,element in enumerate(all_state_date_strings):
    pertinent_files[i] = [x for x in TWEETS if sum([int(z in x) for z in all_state_date_strings[i]]) > 0]


# NOW to iterate through all the relevant tweet files, and to write out those that I am interested in, 
# to a new json file for each state! 

# In[81]:


def process_file(path, output_path, user_ids_list):
    with open(path) as infile: 
        print(path)
        for i,line in enumerate(infile):
            try:
                tweet = json.loads(line)
            except json.JSONDecodeError as e:
                print(f'Error in {infile} line {i}: {e}')
            user_id = tweet['user']['id_str']
            if user_id in user_ids_list:
                with open(output_path, 'a+') as outfile:
                    newline = json.dumps(tweet)
                    outfile.write(newline + '\n')
                    
    print('Wrote tweets to json. Next file.')


# In[61]:


# LOOP through the states, then the files
output_filepaths = [DATA_PATH+'located_users_tweets/iowa_tweets.json',
                    DATA_PATH+'located_users_tweets/southcarolina_tweets.json',
                    DATA_PATH+'located_users_tweets/massachussets_tweets.json']

for i,element in enumerate(pertinent_files):
    for j,file in enumerate(element):
        process_file(path=file, output_path=output_filepaths[i], user_ids_list=user_ids[i])


