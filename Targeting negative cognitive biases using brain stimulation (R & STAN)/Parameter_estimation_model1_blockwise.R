

##########################################################
# # Extract parameter estimates and win-driven choices # #
##########################################################

library(tidyverse)
source("inv_logit.R")
source("rescorla_wagner.R")
source("fit_model1_block_wise.R")
source("extract_proportion_windriven_choices.R")


start_time <- Sys.time()
Estimates <- data.frame("ID" = c(NA), "Session" = c(NA), "Half"=c(NA), "win_LR_both" = c(NA), "win_LR_wins" = c(NA),"win_LR_losses" = c(NA), 
           "loss_LR_both" = c(NA), "loss_LR_wins" = c(NA), "loss_LR_losses" = c(NA),"beta_both" = c(NA), "beta_wins" = c(NA), 
           "beta_losses" = c(NA), "t_both" = c(NA), "t_wins" = c(NA),"t_losses" = c(NA), "AIC_both" = c(NA), 
           "AIC_wins" = c(NA),"AIC_losses" = c(NA), "BIC_both" = c(NA), "BIC_wins" = c(NA), "BIC_losses"=c(NA))


#  determine trials to use 
miss_trials <- 10
trials_to_use <- rep(TRUE,80)
trials_to_use[1:miss_trials] <- FALSE
resp_made <- trials_to_use

# bins
alpha_bins <- 30
beta_bins <- 30
t_bins <- 30


# Variables needed: ID: participant IDs, blk_type: block order for each participant

for (sub in 1:length(ID)){ # ID is the participant number
  numb <- (ID[sub])
  
  for (sess in 1:2){ # all participamnts attended two sessions
    
    # read in data file 
    data_name <- paste("./Raw_data/", numb, "_visit_", sess, "_blktype_", blk_type[sub], ".txt", sep ="")
   
    raw_data <- read.delim2(data_name, header = T, skip=1)
    information <- select(raw_data, Winpos, Losspos) # win and loss outcomes per trial
    choice <- select(raw_data, Choice) # participants' choices
    
    
    # fit model to 6 blocks
   
    start_point <- 1
    end_point <- 80
    out1 <- fit_model_tendency_parameter_2_alpha_1_beta(information[start_point:end_point,], choice[start_point:end_point,], alpha_bins, beta_bins, t_bins)
    
    start_point <- 81
    end_point <- 160
    out2 <- fit_model_tendency_parameter_2_alpha_1_beta(information[start_point:end_point,], choice[start_point:end_point,], alpha_bins, beta_bins, t_bins)

    start_point <- 161
    end_point <- 240
    out3 <- fit_model_tendency_parameter_2_alpha_1_beta(information[start_point:end_point,], choice[start_point:end_point,], alpha_bins, beta_bins, t_bins)

    start_point <- 241
    end_point <- 320
    out4 <- fit_model_tendency_parameter_2_alpha_1_beta(information[start_point:end_point,], choice[start_point:end_point,], alpha_bins, beta_bins, t_bins)

    start_point <- 321
    end_point <- 400
    out5 <- fit_model_tendency_parameter_2_alpha_1_beta(information[start_point:end_point,], choice[start_point:end_point,], alpha_bins, beta_bins, t_bins)

    start_point <- 401
    end_point <- 480
    out6 <- fit_model_tendency_parameter_2_alpha_1_beta(information[start_point:end_point,], choice[start_point:end_point,], alpha_bins, beta_bins, t_bins)

    if(blk_type[sub] == 1){ # block order: both-volatile, losses-volatile, wins-volatile, losses-volatile, wins-volatile, both-volatile
    estimates <- data.frame("ID" = c(ID[sub], ID[sub]), "Session" = c(sess,sess), "Half"=c(1,2), "win_LR_both" = c(out1[1], out6[1]), "win_LR_wins" = c(out3[1], out5[1]),"win_LR_losses" = c(out2[1], out4[1]), 
                            "loss_LR_both" = c(out1[2], out6[2]), "loss_LR_wins" = c(out3[2], out5[2]), "loss_LR_losses" = c(out2[2], out4[2]),"beta_both" = c(out1[3], out6[3]), "beta_wins" = c(out3[3], out5[3]), 
                            "beta_losses" = c(out2[3], out4[3]), "t_both" = c(out1[4], out6[4]), "t_wins" = c(out3[4], out5[4]),"t_losses" = c(out2[4], out4[4]), "AIC_both" = c(out1[5], out6[5]), 
                            "AIC_wins" = c(out3[5], out5[5]),"AIC_losses" = c(out2[5], out4[5]), "BIC_both" = c(out1[6], out6[6]), "BIC_wins" = c(out3[6], out5[6]), "BIC_losses"=c(out2[6], out4[6]))
    
    } else{ # block order: both-volatile, wins-volatile, losses-volatile, wins-volatile, losses-volatile, both-volatile
    estimates <- data.frame("ID" = c(ID[sub], ID[sub]), "Session" = c(sess,sess), "Half"=c(1,2), "win_LR_both" = c(out1[1], out6[1]), "win_LR_wins" = c(out2[1], out4[1]),"win_LR_losses" = c(out3[1], out5[1]), 
                              "loss_LR_both" = c(out1[2], out6[2]), "loss_LR_wins" = c(out2[2], out4[2]), "loss_LR_losses" = c(out3[2], out5[2]),"beta_both" = c(out1[3], out6[3]), "beta_wins" = c(out2[3], out4[3]), 
                              "beta_losses" = c(out3[3], out5[3]), "t_both" = c(out1[4], out6[4]), "t_wins" = c(out2[4], out4[4]),"t_losses" = c(out3[4], out5[4]), "AIC_both" = c(out1[5], out6[5]), 
                              "AIC_wins" = c(out2[5], out4[5]),"AIC_losses" = c(out3[5], out5[5]), "BIC_both" = c(out1[6], out6[6]), "BIC_wins" = c(out2[6], out4[6]), "BIC_losses"=c(out3[6], out5[6]))
      
    }
    Estimates <- rbind(Estimates, estimates)
    
  }
}
  
Estimates <- Estimates[2:nrow(Estimates),]




# Extract proportion of win-driven choices ################################################################################


Win_driven_choices <- data.frame("ID" = c(NA), "Session" = c(NA), "Half"=c(NA), "win_driven_both" = c(NA), "win_driven_wins" = c(NA),"win_driven_losses" = c(NA))

for (sub in 1:length(ID)){
  numb <- as.character(ID[sub])
  
  for (sess in 1:2){
    
    # read in data file 
    
    data_name <- paste("./Raw_data/", numb, "_visit_", sess, "_blktype_", blk_type[sub], ".txt", sep ="")
   
    raw_data <- read.delim2(data_name, header = T, skip=1)
    information <- select(raw_data, Winpos, Losspos)
    choice <- select(raw_data, Choice)
    
    
    
    # win-driven choices for 6 blocks
    
    start_point <- 1
    end_point <- 80
    Information <- information[start_point:end_point,]
    Choice <- as.data.frame(choice[start_point:end_point,])
    out1 <- extract_proportion_windriven_choices(Information, Choice)
    
    start_point <- 81
    end_point <- 160
    Information <- information[start_point:end_point,]
    Choice <- as.data.frame(choice[start_point:end_point,])
    out2 <- extract_proportion_windriven_choices(Information, Choice)
    
    start_point <- 161
    end_point <- 240
    Information <- information[start_point:end_point,]
    Choice <- as.data.frame(choice[start_point:end_point,])
    out3 <- extract_proportion_windriven_choices(Information, Choice)
    
    start_point <- 241
    end_point <- 320
    Information <- information[start_point:end_point,]
    Choice <- as.data.frame(choice[start_point:end_point,])
    out4 <- extract_proportion_windriven_choices(Information, Choice)
    
    start_point <- 321
    end_point <- 400
    Information <- information[start_point:end_point,]
    Choice <- as.data.frame(choice[start_point:end_point,])
    out5 <- extract_proportion_windriven_choices(Information, Choice)
    
    start_point <- 401
    end_point <- 480
    Information <- information[start_point:end_point,]
    Choice <- as.data.frame(choice[start_point:end_point,])
    out6 <- extract_proportion_windriven_choices(Information, Choice)
    
    
    if(blk_type[sub] == 1){  # block order: both-volatile, losses-volatile, wins-volatile, losses-volatile, wins-volatile, both-volatile
      win_driven_choices <- data.frame("ID" = c(ID[sub], ID[sub]), "Session" = c(sess,sess), "Half"=c(1,2), "win_driven_both" = c(out1[1], out6[1]), "win_driven_wins" = c(out3[1], out5[1]),"win_driven_losses" = c(out2[1], out4[1]))
    
      } else{ # block order: both-volatile, wins-volatile, losses-volatile, wins-volatile, losses-volatile, both-volatile
      win_driven_choices <- data.frame("ID" = c(ID[sub], ID[sub]), "Session" = c(sess,sess), "Half"=c(1,2), "win_driven_both" = c(out1[1], out6[1]), "win_driven_wins" = c(out2[1], out4[1]),"win_driven_losses" = c(out3[1], out5[1]))
      
    }
    Win_driven_choices <- rbind(Win_driven_choices, win_driven_choices)
    
  }
}
Win_driven_choices <- Win_driven_choices[2:nrow(Win_driven_choices),]




