
########################################################
# The effect of tDCS in the constant model (Model 6) #
########################################################

library(tidyverse) 
library(ez)
library(ggplot2)
library(rstatix)

source("inv_logit.R")
source("normDataWithin.R")
source("summarySE.R")
source("summarySEwithin.R")
source("remove_outliers.R")
source("detect_outliers.R")


data <- read.csv("Parameter_estimates.csv")
data$ID <- as.factor(data$ID)
data$Session <- as.factor(data$Session)
data$Time <- as.factor(data$Time)
data$Sample <- as.factor(data$Sample)
data$Valence <- factor(data$Valence, levels = c("win", "loss"))
data$Volatility <- as.factor(data$Volatility)
data$Block.order <- as.factor(data$Block.order)


######################################################################################################################################################
##################################### tDCS during task performance ###################################################################################
######################################################################################################################################################

online_first <- filter(data, Sample == "Low_mood", Stimulation_time == "online", Time == 1, Volatility != "both-volatile")
length(unique(online_first$ID))


# Learning rates #################################################################################################


detach(package:plyr)
LR_inv_mean <- online_first %>%
  group_by(ID, tDCS_Condition, Valence) %>%
  summarise(M6_LR_inv = mean(M6_LR_inv))

# outlier removal
LR_inv_win_mean <- filter(LR_inv_mean, Valence == "win") 
LR_inv_win_mean <- pivot_wider(LR_inv_win_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_inv" )
LR_inv_win_mean$LR_inv_win_diff <- LR_inv_win_mean$real - LR_inv_win_mean$sham
outliers_LR_inv_win <- detect_outliers(LR_inv_win_mean, "LR_inv_win_diff", 1.5)
LR_inv_loss_mean <- filter(LR_inv_mean, Valence == "loss") 
LR_inv_loss_mean <- pivot_wider(LR_inv_loss_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_inv" )
LR_inv_loss_mean$LR_inv_loss_diff <- LR_inv_loss_mean$real - LR_inv_loss_mean$sham
outliers_LR_inv_loss <- detect_outliers(LR_inv_loss_mean, "LR_inv_loss_diff", 1.5)

ezANOVA(filter(online_first),
        dv = .(M6_LR_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition, Valence, Volatility),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3)

ezANOVA(filter(online_first,!(ID %in% c(outliers_LR_inv_win$ID, outliers_LR_inv_loss$ID)) ),
        dv = .(M6_LR_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition, Valence, Volatility),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3)

# Plot effect of tDCS on learning rates

detach(package:plyr)
LR_tDCS <- online_first %>%
  filter(!ID %in% c(outliers_LR_inv_win$ID, outliers_LR_inv_loss$ID)) %>%
  group_by(ID, tDCS_Condition, Valence, Volatility) %>%
  summarise(M6_LR = mean(M6_LR))

LR_tDCS_EB <- summarySEwithin(filter(online_first, !ID %in% c(outliers_LR_inv_win$ID, outliers_LR_inv_loss$ID)), measurevar = "M6_LR",  withinvars = c("tDCS_Condition", "Valence", "Volatility"), idvar = "ID")

ggplot()+
  geom_col(data=LR_tDCS_EB, aes(Valence, M6_LR, alpha = tDCS_Condition), fill = "#C00000", position = "dodge") +
  geom_jitter(data=LR_tDCS, aes(Valence, M6_LR, fill = tDCS_Condition), alpha = .15, position = position_jitterdodge(jitter.width = 0.15, jitter.height = 0, dodge.width = 0.9), size = 1)+
  geom_errorbar(data=LR_tDCS_EB, aes(Valence,ymin=M6_LR-se, ymax=M6_LR+se, group = tDCS_Condition), width=.2, size = 0.5, position = position_dodge(width = 0.9))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  scale_alpha_discrete(range = c(0.5, 1), labels=c("bifrontal", "sham"), name = c("tDCS"))+
  labs(title = "",y = "Learning rate")+
  theme(text = element_text(size = 12))+
  facet_wrap(~Volatility)



# LR adjustment ###################################

detach(package:plyr)
LR_adj_inv_mean <- online_first%>%
  group_by(ID,tDCS_Condition, Valence) %>%
  summarise(M6_LR_adj_inv = mean(M6_LR_adj_inv))

# remove outliers
LR_adj_inv_win_mean <- filter(LR_adj_inv_mean, Valence == "win") 
LR_adj_inv_win_mean <- pivot_wider(LR_adj_inv_win_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_adj_inv" )
LR_adj_inv_win_mean$LR_adj_inv_win_diff <- LR_adj_inv_win_mean$real - LR_adj_inv_win_mean$sham
outliers_LR_adj_inv_win <- detect_outliers(LR_adj_inv_win_mean, "LR_adj_inv_win_diff", 1.5)
LR_adj_inv_loss_mean <- filter(LR_adj_inv_mean, Valence == "loss") 
LR_adj_inv_loss_mean <- pivot_wider(LR_adj_inv_loss_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_adj_inv" )
LR_adj_inv_loss_mean$LR_adj_inv_loss_diff <- LR_adj_inv_loss_mean$real - LR_adj_inv_loss_mean$sham
outliers_LR_adj_inv_loss <- detect_outliers(LR_adj_inv_loss_mean, "LR_adj_inv_loss_diff", 1.5)


ezANOVA(filter(online_first),
        dv = .(M6_LR_adj_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition, Valence),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3)


ezANOVA(filter(online_first, !(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID))),
        dv = .(M6_LR_adj_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition, Valence),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3) # tDCS Condition x Valence

ezANOVA(filter(online_first, !(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID)), Valence == "win"),
        dv = .(M6_LR_adj_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3) # tDCS Condition

ezANOVA(filter(online_first, !(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID)), Valence == "loss"),
        dv = .(M6_LR_adj_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3) # tDCS Condition





detach(package:plyr)
LR_adj_tDCS <- online_first%>%
  filter(!(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID))) %>%
  group_by(ID,tDCS_Condition, Valence) %>%
  summarise(M6_LR_adj_inv = mean(M6_LR_adj_inv))

LR_adj_tDCS_EB <- summarySEwithin(filter(online_first, !(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID))), measurevar = "M6_LR_adj_inv",  withinvars = c("tDCS_Condition", "Valence"), idvar = "ID")

ggplot()+
  geom_col(data=LR_adj_tDCS_EB, aes(Valence, M6_LR_adj_inv, alpha = tDCS_Condition), fill = "#C00000", position = "dodge") +
  geom_jitter(data=LR_adj_tDCS, aes(Valence, M6_LR_adj_inv, fill = tDCS_Condition), alpha = .15, position = position_jitterdodge(jitter.width = 0.15, jitter.height = 0, dodge.width = 0.9), size = 1)+
  geom_errorbar(data=LR_adj_tDCS_EB, aes(Valence,ymin=M6_LR_adj_inv-se, ymax=M6_LR_adj_inv+se, group = tDCS_Condition), width=.2, size = 0.5, position = position_dodge(width = 0.9))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  scale_alpha_discrete(range = c(0.5, 1), labels=c("bifrontal", "sham"), name = c("tDCS"))+
  labs(title = "",y = "Learning rate adjustment")+
  theme(text = element_text(size = 12))


# Learning rate adjustment bias ######################

detach(package:plyr)
LR_adj_diff_inv_mean <- online_first%>%
  group_by(ID,tDCS_Condition) %>%
  summarise(M6_LR_adj_diff_inv = mean(M6_LR_adj_diff_inv))


ezANOVA(filter(online_first),
        dv = .(M6_LR_adj_diff_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3)

ezANOVA(filter(online_first, !(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID))),
        dv = .(M6_LR_adj_diff_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3)



detach(package:plyr)
LR_adj_diff_tDCS <- online_first%>%
  filter(!(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID))) %>%
  group_by(ID,tDCS_Condition) %>%
  summarise(M6_LR_adj_diff_inv = mean(M6_LR_adj_diff_inv))

LR_adj_diff_tDCS_EB <- summarySEwithin(filter(online_first, !(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID))), measurevar = "M6_LR_adj_diff_inv",  withinvars = c("tDCS_Condition"), idvar = "ID")

ggplot()+
  geom_hline(yintercept=0)+
  geom_col(data=LR_adj_diff_tDCS_EB, aes(tDCS_Condition, M6_LR_adj_diff_inv, alpha = tDCS_Condition), fill = "#C00000", position = "dodge") +
  geom_jitter(data=LR_adj_diff_tDCS, aes(tDCS_Condition, M6_LR_adj_diff_inv, fill = tDCS_Condition), alpha = .15, position = position_jitterdodge(jitter.width = 0.3, jitter.height = 0, dodge.width = 0.9), size = 1)+
  geom_errorbar(data=LR_adj_diff_tDCS_EB, aes(tDCS_Condition,ymin=M6_LR_adj_diff_inv-se, ymax=M6_LR_adj_diff_inv+se, group = tDCS_Condition), width=.2, size = 0.5, position = position_dodge(width = 0.9))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  scale_alpha_discrete(range = c(0.5, 1), labels=c("bifrontal", "sham"), name = c("tDCS"))+
  labs(title = "",x = "tDCS",y = "Learning rate adjustment bias")+
  theme(text = element_text(size = 12))




# Is LR adjustment bias different from zero?

detach(package:plyr)
LR_adj_tDCS_diff_sham <- online_first%>%
  filter(!(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID)), tDCS_Condition == "sham")%>%
  group_by(ID) %>%
  summarise(M6_LR_adj_diff_inv = mean(M6_LR_adj_diff_inv))
LR_adj_tDCS_diff_real <- online_first%>%
  filter(!(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID)), tDCS_Condition == "real")%>%
  group_by(ID) %>%
  summarise(M6_LR_adj_diff_inv = mean(M6_LR_adj_diff_inv))
t.test(LR_adj_tDCS_diff_sham$M6_LR_adj_diff_inv)
t.test(LR_adj_tDCS_diff_real$M6_LR_adj_diff_inv)

# Does the effect outlast the stimulation period?

online_second <- filter(data, Sample == "Low_mood", Stimulation_time == "online", Time == "2", Volatility != "both-volatile")

detach(package:plyr)
LR_adj_inv_mean2 <- online_second %>%
  group_by(ID,tDCS_Condition, Valence) %>%
  summarise(M6_LR_adj_inv = mean(M6_LR_adj_inv))

LR_adj_inv_win_mean2 <- filter(LR_adj_inv_mean2, Valence == "win") 
LR_adj_inv_win_mean2 <- pivot_wider(LR_adj_inv_win_mean2, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_adj_inv" )
LR_adj_inv_win_mean2$LR_adj_inv_win_diff <- LR_adj_inv_win_mean2$real - LR_adj_inv_win_mean2$sham
outliers_LR_adj_inv_win2 <- detect_outliers(LR_adj_inv_win_mean2, "LR_adj_inv_win_diff", 2)
LR_adj_inv_loss_mean2 <- filter(LR_adj_inv_mean2, Valence == "loss") 
LR_adj_inv_loss_mean2 <- pivot_wider(LR_adj_inv_loss_mean2, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_adj_inv" )
LR_adj_inv_loss_mean2$LR_adj_inv_loss_diff <- LR_adj_inv_loss_mean2$real - LR_adj_inv_loss_mean2$sham
outliers_LR_adj_inv_loss2 <- detect_outliers(LR_adj_inv_loss_mean2, "LR_adj_inv_loss_diff", 2)

ezANOVA(filter(online_second, !(ID %in% c(outliers_LR_adj_inv_win2$ID, outliers_LR_adj_inv_loss2$ID))),
        dv = .(M6_LR_adj_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition, Valence),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3)


# tDCS effect on inverse temperature ###################################################################

detach(package:plyr)
beta_log_mean <- online_first%>%
  group_by(ID,tDCS_Condition, Valence) %>%
  summarise(M6_beta_log = mean(M6_beta_log))

beta_log_win_mean <- filter(beta_log_mean, Valence == "win") 
beta_log_win_mean <- pivot_wider(beta_log_win_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_beta_log" )
beta_log_win_mean$beta_log_win_diff <- beta_log_win_mean$real -beta_log_win_mean$sham
outliers_beta_log_win <- detect_outliers(beta_log_win_mean, "beta_log_win_diff", 2)
beta_log_loss_mean <- filter(beta_log_mean, Valence == "loss") 
beta_log_loss_mean <- pivot_wider(beta_log_loss_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_beta_log" )
beta_log_loss_mean$beta_log_loss_diff <- beta_log_loss_mean$real -beta_log_loss_mean$sham
outliers_beta_log_loss <- detect_outliers(beta_log_loss_mean, "beta_log_loss_diff", 2)


ezANOVA(online_first,
        dv = .(M6_beta_log),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition, Valence),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3) 



########################################################################################################################################################################
########################################################################################################################################################################






##############################################################################################################################
################################################# OFFLINE tDCS ###############################################################
##############################################################################################################################

offline_first <- filter(data, Sample == "Low_mood", Stimulation_time == "offline", Time == "1", Volatility != "both-volatile")
length(unique(offline_first$ID))
# Learning rates

detach(package:plyr)
LR_inv_mean <- offline_first %>%
  group_by(ID, tDCS_Condition, Valence) %>%
  summarise(M6_LR_inv = mean(M6_LR_inv))

LR_inv_win_mean <- filter(LR_inv_mean, Valence == "win") 
LR_inv_win_mean <- pivot_wider(LR_inv_win_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_inv" )
LR_inv_win_mean$LR_inv_win_diff <- LR_inv_win_mean$real - LR_inv_win_mean$sham
outliers_LR_inv_win <- detect_outliers(LR_inv_win_mean, "LR_inv_win_diff", 2)
LR_inv_loss_mean <- filter(LR_inv_mean, Valence == "loss") 
LR_inv_loss_mean <- pivot_wider(LR_inv_loss_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_inv" )
LR_inv_loss_mean$LR_inv_loss_diff <- LR_inv_loss_mean$real - LR_inv_loss_mean$sham
outliers_LR_inv_loss <- detect_outliers(LR_inv_loss_mean, "LR_inv_loss_diff", 2) # no outliers


ezANOVA(offline_first,
        dv = .(M6_LR_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition, Valence, Volatility),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3) # p = .33

# Plot effect of tDCS berfore task performance on learning rates

detach(package:plyr)
LR_tDCS <- offline_first %>%
  group_by(ID, tDCS_Condition, Valence, Volatility) %>%
  summarise(M6_LR = mean(M6_LR))

LR_tDCS_EB <- summarySEwithin(offline_first, measurevar = "M6_LR",  withinvars = c("tDCS_Condition", "Valence", "Volatility"), idvar = "ID")

ggplot()+
  geom_col(data=LR_tDCS_EB, aes(Valence, M6_LR, alpha = tDCS_Condition), fill = "#C00000", position = "dodge") +
  geom_jitter(data=LR_tDCS, aes(Valence, M6_LR, fill = tDCS_Condition), alpha = .15, position = position_jitterdodge(jitter.width = 0.15, jitter.height = 0, dodge.width = 0.9), size = 1)+
  geom_errorbar(data=LR_tDCS_EB, aes(Valence,ymin=M6_LR-se, ymax=M6_LR+se, group = tDCS_Condition), width=.2, size = 0.5, position = position_dodge(width = 0.9))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  scale_alpha_discrete(range = c(0.5, 1), labels=c("bifrontal", "sham"), name = c("tDCS"))+
  labs(title = "",y = "Learning rate")+
  theme(text = element_text(size = 12))+
  facet_wrap(~Volatility)

# Learning rate adjustment ################################################################

detach(package:plyr)
LR_adj_inv_mean <- offline_first%>%
  group_by(ID,tDCS_Condition, Valence) %>%
  summarise(M6_LR_adj_inv = mean(M6_LR_adj_inv))

LR_adj_inv_win_mean <- filter(LR_adj_inv_mean, Valence == "win") 
LR_adj_inv_win_mean <- pivot_wider(LR_adj_inv_win_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_adj_inv" )
LR_adj_inv_win_mean$LR_adj_inv_win_diff <- LR_adj_inv_win_mean$real - LR_adj_inv_win_mean$sham
outliers_LR_adj_inv_win_off <- detect_outliers(LR_adj_inv_win_mean, "LR_adj_inv_win_diff", 2)
LR_adj_inv_loss_mean <- filter(LR_adj_inv_mean, Valence == "loss") 
LR_adj_inv_loss_mean <- pivot_wider(LR_adj_inv_loss_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_adj_inv" )
LR_adj_inv_loss_mean$LR_adj_inv_loss_diff <- LR_adj_inv_loss_mean$real - LR_adj_inv_loss_mean$sham
outliers_LR_adj_inv_loss_off <- detect_outliers(LR_adj_inv_loss_mean, "LR_adj_inv_loss_diff", 2)

ezANOVA(offline_first,
        dv = .(M6_LR_adj_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition, Valence),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3) 

# after outlier removal
ezANOVA(filter(offline_first, !(ID %in% c(outliers_LR_adj_inv_win_off$ID, outliers_LR_adj_inv_loss_off$ID))),
        dv = .(M6_LR_adj_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition, Valence),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3)


# Plot effect of tDCS before task performance on learning rate adjustment

detach(package:plyr)
LR_adj_tDCS <- offline_first %>%
  filter(!(ID %in% c(outliers_LR_adj_inv_win_off$ID, outliers_LR_adj_inv_loss_off$ID))) %>%
  group_by(ID, tDCS_Condition, Valence) %>%
  summarise(M6_LR_adj_inv = mean(M6_LR_adj_inv))

LR_adj_tDCS_EB <- summarySEwithin(filter(offline_first,!(ID %in% c(outliers_LR_adj_inv_win_off$ID, outliers_LR_adj_inv_loss_off$ID))), measurevar = "M6_LR_adj_inv",  withinvars = c("tDCS_Condition", "Valence"), idvar = "ID")

ggplot()+
  geom_col(data=LR_adj_tDCS_EB, aes(Valence, M6_LR_adj_inv, alpha = tDCS_Condition), fill = "#C00000", position = "dodge") +
  geom_jitter(data=LR_adj_tDCS, aes(Valence, M6_LR_adj_inv, fill = tDCS_Condition), alpha = .15, position = position_jitterdodge(jitter.width = 0.15, jitter.height = 0, dodge.width = 0.9), size = 1)+
  geom_errorbar(data=LR_adj_tDCS_EB, aes(Valence,ymin=M6_LR_adj_inv-se, ymax=M6_LR_adj_inv+se, group = tDCS_Condition), width=.2, size = 0.5, position = position_dodge(width = 0.9))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  scale_alpha_discrete(range = c(0.5, 1), labels=c("bifrontal", "sham"), name = c("tDCS"))+
  labs(title = "",y = "Learning rate adjustment")+
  theme(text = element_text(size = 12))



# Learning rate adjustment bias ###############################################

detach(package:plyr)
LR_adj_diff_inv_mean <- offline_first%>%
  group_by(ID,tDCS_Condition) %>%
  summarise(M6_LR_adj_diff_inv = mean(M6_LR_adj_diff_inv))

LR_adj_diff_inv_mean <- pivot_wider(LR_adj_diff_inv_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_adj_diff_inv" )
LR_adj_diff_inv_mean$LR_adj_diff_inv_diff <- LR_adj_diff_inv_mean$real - LR_adj_diff_inv_mean$sham
outliers_LR_adj_diff_inv_off <- detect_outliers(LR_adj_diff_inv_mean, "LR_adj_diff_inv_diff", 2)

ezANOVA(offline_first,
        dv = .(M6_LR_adj_diff_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3)

ezANOVA(filter(offline_first, !(ID %in% c(outliers_LR_adj_inv_win_off$ID, outliers_LR_adj_inv_loss_off$ID))),
        dv = .(M6_LR_adj_diff_inv),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3) # p = .56

# Plot effect of tDCS before task performance on learning rate adjustment bias

detach(package:plyr)
LR_adj_diff_tDCS <- offline_first %>%
  filter(!(ID %in% c(outliers_LR_adj_inv_win_off$ID, outliers_LR_adj_inv_loss_off$ID))) %>%
  group_by(ID, tDCS_Condition) %>%
  summarise(M6_LR_adj_diff_inv = mean(M6_LR_adj_diff_inv))

LR_adj_diff_tDCS_EB <- summarySEwithin(filter(offline_first,!(ID %in% c(outliers_LR_adj_inv_win_off$ID, outliers_LR_adj_inv_loss_off$ID))), measurevar = "M6_LR_adj_diff_inv",  withinvars = c("tDCS_Condition"), idvar = "ID")

ggplot()+
  geom_col(data=LR_adj_diff_tDCS_EB, aes(tDCS_Condition, M6_LR_adj_diff_inv, alpha = tDCS_Condition), fill = "#C00000", position = "dodge") +
  geom_jitter(data=LR_adj_diff_tDCS, aes(tDCS_Condition, M6_LR_adj_diff_inv, fill = tDCS_Condition), alpha = .15, position = position_jitterdodge(jitter.width = 0.15, jitter.height = 0, dodge.width = 0.9), size = 1)+
  geom_errorbar(data=LR_adj_diff_tDCS_EB, aes(tDCS_Condition,ymin=M6_LR_adj_diff_inv-se, ymax=M6_LR_adj_diff_inv+se, group = tDCS_Condition), width=.2, size = 0.5, position = position_dodge(width = 0.9))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  scale_alpha_discrete(range = c(0.5, 1), labels=c("bifrontal", "sham"), name = c("tDCS"))+
  labs(title = "",x = "tDCS", y = "Learning rate adjustment bias")+
  theme(text = element_text(size = 12))



# Inverse temperature ##################################################

detach(package:plyr)
beta_log_mean <- offline_first%>%
  group_by(ID,tDCS_Condition, Valence) %>%
  summarise(M6_beta_log = mean(M6_beta_log))

beta_log_win_mean <- filter(beta_log_mean, Valence == "win") 
beta_log_win_mean <- pivot_wider(beta_log_win_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_beta_log" )
beta_log_win_mean$beta_log_win_diff <- beta_log_win_mean$real -beta_log_win_mean$sham
outliers_beta_log_win <- detect_outliers(beta_log_win_mean, "beta_log_win_diff", 2)
beta_log_loss_mean <- filter(beta_log_mean, Valence == "loss") 
beta_log_loss_mean <- pivot_wider(beta_log_loss_mean, ID,  names_from = "tDCS_Condition", values_from = "M6_beta_log" )
beta_log_loss_mean$beta_log_loss_diff <- beta_log_loss_mean$real -beta_log_loss_mean$sham
outliers_beta_log_loss <- detect_outliers(beta_log_loss_mean, "beta_log_loss_diff", 2)

ezANOVA(offline_first,
        dv = .(M6_beta_log),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition, Valence),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3)

ezANOVA(filter(offline_first, !(ID %in% c(outliers_beta_log_win$ID, outliers_beta_log_loss$ID))),
        dv = .(M6_beta_log),
        wid = .(ID),
        between = .(Block.order),
        within = .(tDCS_Condition, Valence),
        between_covariates = .(M6_baseline_LR_win, M6_baseline_LR_loss), type = 3) 



# Is the effect on LR adjustment specific to online tDCS?

LM_first <- filter(data, Sample == "Low_mood",  Time == "1", Volatility != "both-volatile")


detach(package:plyr)
tDCS_effect_bias_w <- LM_first %>%
  filter(!(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID, outliers_LR_adj_inv_win_off$ID, outliers_LR_adj_inv_loss_off$ID, outliers_LR_adj_diff_inv_off$ID)) ) %>%
  group_by(ID, Stimulation_time, tDCS_Condition) %>%
  summarise(M6_LR_adj_diff_inv = mean(M6_LR_adj_diff_inv), Stimulation_time = unique(Stimulation_time))

tDCS_effect_bias_w <- pivot_wider(tDCS_effect_bias_w, ID,  names_from = "tDCS_Condition", values_from = "M6_LR_adj_diff_inv" )
tDCS_effect_bias_w$adjustment_bias_diff <- tDCS_effect_bias_w$real - tDCS_effect_bias_w$sham

tDCS_effect_bias <- LM_first %>%
  filter(!(ID %in% c(outliers_LR_adj_inv_win$ID, outliers_LR_adj_inv_loss$ID, outliers_LR_adj_inv_win_off$ID, outliers_LR_adj_inv_loss_off$ID, outliers_LR_adj_diff_inv_off$ID)) ) %>%
  group_by(ID, Stimulation_time) %>%
  summarise(Stimulation_time = unique(Stimulation_time))

tDCS_effect_bias <- merge( tDCS_effect_bias_w, tDCS_effect_bias)
t.test(tDCS_effect_bias$adjustment_bias_diff ~ tDCS_effect_bias$Stimulation_time, alternative = "less")




detach(package:plyr)
tDCS_effect_bias_mean <- tDCS_effect_bias%>%
  group_by(ID,Stimulation_time) %>%
  summarise(adjustment_bias_diff = mean(adjustment_bias_diff))

adjustment_bias_diff_EB <- summarySE(tDCS_effect_bias, measurevar = "adjustment_bias_diff", groupvars = "Stimulation_time")

ggplot()+
  geom_hline(yintercept=0)+
  geom_col(data=adjustment_bias_diff_EB, aes(Stimulation_time, adjustment_bias_diff, alpha = Stimulation_time), position = "dodge") +
  geom_jitter(data=tDCS_effect_bias, aes(Stimulation_time, adjustment_bias_diff, fill = Stimulation_time),alpha = .15, position = position_jitterdodge(jitter.width = 0.2, jitter.height = 0, dodge.width = 0.9), size = 1)+
  geom_errorbar(data=adjustment_bias_diff_EB, aes(Stimulation_time,ymin=adjustment_bias_diff-se, ymax=adjustment_bias_diff+se, group = Stimulation_time), width=.2, size = 0.5, position = position_dodge(width = 0.9))+
  theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_blank(), axis.line = element_line(colour = "black"))+
  scale_alpha_discrete(range = c(0.5, 1),  name = c("Stimulation time"))+
  labs(title = "",x="Stimulation time",y = "tDCS effect on LR adjustment bias\n(real minus sham)")+
  #scale_x_discrete(labels=c("real_first" = "real first", "sham_first" = "sham first"))+
  theme(text = element_text(size = 12)) 


