#!/usr/bin/env python
# coding: utf-8

# **SENTIMENT PAPER rework:**
# 
# Extracting unique users from all filtered tweets 
# 
# 16/01/20 - NL, initial start working on this
# 
# In this notebook, the following will be done:
# 
#     - glob out the relevant tweets
#     - iterate through each tweet
#     - check if user id is already in a given list, if not, add it
#     - --> for now, that's it.
# 

# In[1]:


import glob
import json


# In[4]:


tweets_path = "/scratch/nl1676/olympus_local/sentiment_paper_relevant_tweets/*.json"
relevant_files = glob.glob(tweets_path)


# Function that does the unique user extraction:

# In[21]:


def extract_unique_users(tweets_file, unique_users_db):
    with open(tweets_file) as infile:
        print(tweets_file)
        pre = len(unique_users_db)
        
        for i,line in enumerate(infile):
            try:
                tweet = json.loads(line)
            except json.JSONDecodeError as e:
                print(f'Error in {infile} line {i}: {e}')
            if not 'text' in tweet: # this jumps to the next line in the json if there's no text
                    print(f'Error in {infile} line {i}: No text element to read from')
                    continue
            else:
                user_id = tweet['user']['id_str']
            # now check if it's already in the 'unique_user_db' dict
            if not user_id in unique_users_db:
                unique_users_db = unique_users_db + [user_id]
            else:
                continue
                
        # now return the user_db, and print some summary_stats
        post = len(unique_users_db)
        newly_added = post - pre
        print(f'In this file, there were {newly_added} new unique users. Total number of unique users: {len(unique_users_db)}')
        return unique_users_db


# And now to loop through all the relevant files:

# In[23]:


unique_users = []


# In[25]:


for file in relevant_files:
    unique_users = extract_unique_users(file, unique_users)


# In[28]:


out_destination = '/scratch/nl1676/olympus_local/sentiment_paper_relevant_tweets/unique_users/unique_users.txt'
with open(out_destination, 'a+') as outfile:
    for line in unique_users:
        outfile.write("%s\n" % line)


