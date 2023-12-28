
##################################################################
#  Parameter estimation for the constant model (Model 6) in STAN #
##################################################################


#libraries
library(abind)
library(rstan)
library(pracma)
library(tidyverse)


# stan
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# prior SD
priorprec <-1 


# Read in participant numbers and conditions
Conditions <- read.csv("Study2_tDCS_order.csv", header = T)
ID <- as.character(Conditions$ID)
blk_type <- Conditions$Block.order           # this will be used for reading in the files
blk_type[blk_type == "losses-volatile"] <- 1 
blk_type[blk_type == "wins-volatile"] <- 2
Block.order <- Conditions$Block.order
Block.order <- rep(Block.order, each = 2)    # this will be used for parameter estimation for each session
nsubs <- length(ID)*2                     # each participant took part in 2 sessions
Raw_data <- array(dim=c(480,6,1))

# Read in raw data 
for (sub in 1:length(ID)){ 
  numb <- (ID[sub])
    for (sess in 1:2){
      data_name <- paste("./Raw_data/", numb, "_visit_", sess, "_blktype_", blk_type[sub], ".txt", sep ="")
      raw_data <- read.delim2(data_name, header = F, skip=2)
      Raw_data <- abind(Raw_data, raw_data[,1:6], along=3 )
    }
}

Raw_data <- Raw_data[,,2:(dim(Raw_data)[3])]

# create arrays for data. 


ntrials <- 480
information <- array(dim=c(ntrials,2,nsubs)) # number of trials x outcomes (win, loss), number of subjects
choice      <- array(dim=c(ntrials,nsubs))
reset       <- array(dim=c(ntrials,nsubs)) # after each block
trialstouse <- array(dim=c(ntrials,nsubs)) # exclude trials at the beginning of each block

blocks <- array(dim=c(ntrials, nsubs))

# rearrange data
information[,1,] <- Raw_data[,2,] # win position
information[,2,] <- Raw_data[,3,] # loss position
choice <- Raw_data[,6,] # choice



# Block order (1: bv1, 2: wv1, 3: lv1, 4: wv2, 5: lv2, 6: bv2)
block_wins_first <- c(rep(1,80), rep(2,80), rep(3,80), rep(4,80), rep(5,80), rep(6,80)) 
block_losses_first <- c(rep(1,80), rep(3,80), rep(2,80), rep(5,80), rep(4,80), rep(6,80)) 

for (set in 1:datasets){
  if (Block.order[set] == "wins-volatile"){
    blocks[,set] <- block_wins_first
  }
  else if (Block.order[set] == "losses-volatile"){
    blocks[,set] <- block_losses_first
  }
}


# trials to use
trialstouse <- t(repmat(rep(c(rep(0,10), rep(1,70)), 6),nsubs,1)) # exclude first 10 trials of each block
reset <- t(repmat(rep(c(rep(1,1), rep(0,79)), 6), nsubs, 1)) # reset probabilities to 0.5 at beginning of each block
trialblock <- repmat(1,80,1) # each block has 80 trials
trialblock[1:5,1] <- 0
ttu <- repmat(trialblock,6,nsubs) # repeats data in trialblocks 3 times in first dimension, and nsubs times in second dimension


# put data in a list for stan
stan_data <- list(nsubs=nsubs, ntrials=ntrials, information=information, choice=choice,trialstouse=ttu, reset=reset, blocks = blocks, priorprec = priorprec)

# run parameter estimation #############################################################################################################################
fit <- stan(file = "fit_model6_constant.stan", data = stan_data, iter = 10000, chains = 4, control = list(adapt_delta = 0.99, max_treedepth = 12), cores = 4)


#my_sso = launch_shinystan(fit)
