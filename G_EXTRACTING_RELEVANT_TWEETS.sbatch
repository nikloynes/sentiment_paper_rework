#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=5
#SBATCH --time=100:30:00
#SBATCH --mem=64GB
#SBATCH --job-name=EXTRACTING_RELEVANT_TWEETS_POLSENT
#SBATCH --mail-type=END
#SBATCH --mail-user=nl1676@nyu.edu
#SBATCH --output=slurm_%j.out

module purge

/home/$USER/anaconda3/bin/python /home/nl1676/sentiment_paper/sentiment_paper_rework/G_EXTRACTING_RELEVANT_TWEETS.py




