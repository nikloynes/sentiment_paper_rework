#!/usr/bin/env python
# coding: utf-8

# **SCRIPT TO FILTER BERNIE SANDERS TWEETS FROM the 2016_OTHER collection**
# 
#     FKA TEST SCRIPT TO EXTRACT DAILY TWEET VOLUME DATA FOR 2012 (2014, 2016, 2018) ELECTIONS WITH BASIC REPLICABLE KEYWORDS: DEMOCRAT/REPUBLICAN
# 
#     NL, 16/05/19
#     NL, 23/05/19 -- getting towards deployment with help from Frido
#     NL, 04/06/19 -- new edits after local testing
#     ----
#     NL, 12/12/19 -- adapted for re-work of sentiment paper for NL PhD. There are different keywords and different target collections to take this from, but essentially it's the same principle. 
#     NL, 13/01/20 -- trying to get this script to work for the bernie thing 
#     NL, 14/01/20 -- first beta testing stage for bernie script --> going to standard python script
#     NL, 16/01/20 -- it worked! re-doing the same thing for the hillary collection

# In[1]:


import glob
from pathlib import Path
import pandas as pd
from bz2 import BZ2File as bzopen
import json
import datetime
from tqdm import tqdm
import re
from multiprocessing import Pool


# Glob out the relevant collection, which is: us_election_hillary

# In[2]:


# creating an array with all the files to be read in
collection_files = glob.glob("/scratch/olympus/us_election_hillary_2016/data/*.bz2")


# Write out the time frame of interest. 
# 
# The time frame of interest is 3 weeks leading up to each of 3 primaries: **New Hampshire [February 9, 2016], South Carolina [February 27, 2016], Massachusetts [March 1, 2016]**. 
# 
# To keep it safe, I'm getting tweets from 01/01 to 02/03. 

# In[7]:


# find the files for the other collections too!! 
my_delta = datetime.timedelta(days = 1)

# relevant date range: 
# create an array of all pertinent days
start = datetime.datetime.strptime("2016-01-01", "%Y-%m-%d")
end = datetime.datetime.strptime("2016-03-02", "%Y-%m-%d")
date_generated = [start + datetime.timedelta(days=x) for x in range(0, (end-start).days)]


# In[8]:


# dates strings turns the dates into the right format for extracting the right collection files.
dates_strings = []

for date in date_generated:
    pos1 = date.strftime("%m_%d_%Y")
    dates_strings.append(pos1)


# In[9]:


pertinent_files = [x for x in collection_files if sum([int(z in x) for z in dates_strings]) > 0]


# In[12]:


# set up regex of interest
hillary = "|".join(["hillary", "clinton", "rodham"])
hillary = re.compile(hillary, re.IGNORECASE)


# **Functions for finding the regex and iterating through all relevant gzipped tweets**

# In[14]:


# Function that finds whether there's a mention of reps or dems in a string

def contains_regex(tweet, regex):
    pos1 = regex.search(tweet)
    if type(pos1) is re.Match:
        output = True
    else:
        output = False
    return output


# In[15]:


# function that goes through one gzipped tweet file, and checks every line for the target keywords, 
# and writes out if it's there. 

def process_file(path, output_path):
    output_length = []
    with bzopen(path) as infile: # unzips the file
        filename = path
        print(filename)
        for i,line in enumerate(infile):
            try:
                tweet = json.loads(line)
            except json.JSONDecodeError as e:
                print(f'Error in {infile} line {i}: {e}')
            if not 'text' in tweet: # this jumps to the next line in the json if there's no text
                    print(f'Error in {infile} line {i}: No text element to read from')
                    continue
            else:
                text_field = tweet['text']
            if contains_regex(tweet=text_field, regex=hillary):
                #output.append(tweet)
                with open(output_path, 'a+') as outfile:
                    pos1 = json.dumps(tweet)
                    outfile.write(pos1 + '\n')
    
    print('Wrote tweets to json. Next file.')
    
    #return output


# **Now, the loop that runs this thing for the entirety of the files of interest**

# In[16]:


# first, build a list with names for the output files

output_filenames = []

for i in range(len(pertinent_files)):
    pos1 = "/scratch/nl1676/olympus_local/sentiment_paper_relevant_tweets/hillary_tweets_{}.json".format(dates_strings[i])
    output_filenames.append(pos1)


# In[17]:


process_file(pertinent_files[0], output_filenames[0])


# In[14]:


# so, now we have 2 lists with input arugments of equal length.
# solution for parallel processing with multiple function arguments adapted
# from http://www.erogol.com/passing-multiple-arguments-python-multiprocessing-pool/, accessed 03/06/19

# auxiliary function to make it work
def par_helper(args):
   return process_file(*args)

def parallel_product(arg_a, arg_b):
   # spark given number of processes
   pool = Pool(5)
   # set each matching item into a tuple
   job_args = [(item_a, arg_b[i]) for i, item_a in enumerate(arg_a)]
   # map to pool
   pool.map(par_helper, job_args)


# In[ ]:


parallel_product(pertinent_files, output_filenames)


