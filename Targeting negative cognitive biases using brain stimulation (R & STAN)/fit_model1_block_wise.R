
#############################################################
# Model 1 (block-wise): 2 alpha, 1 beta, tendency parameter #
#############################################################

# Parameter estimation for model 1 (block-wise modelling approach). Script written by Verena Sarrazin and Michael Browning. 


fit_model_tendency_parameter_2_alpha_1_beta <- function(information, choice, alpha_bins, beta_bins, tbins){
  
  miss_trials <- 10                   # how many trials to ignore at the beginning of each block
  trials_to_use <- rep(TRUE,80)
  trials_to_use[1:miss_trials] <- FALSE
  resp_made <- trials_to_use

  choice <- as.numeric(choice)    
  trials <- nrow(information)
  
  # NB calculations (of mean and variance) of both learning rate and decision temperature are performed in log space.
  # This creates a vector of length alphabins in inv_logit space
  # this creates a vector of length betabins the value of which changes linearly from log(1)=0 to log(100)=4.6. It will be used to create a
  # logarythmic distribution of inverse temperatures.
  a_label <- seq(inv_logit(0.01), inv_logit(0.99), by = ((inv_logit(0.99)-inv_logit(0.01))/(alpha_bins-1)))
  b_label <- seq(log(0.1), log(100), by = (log(100)-log(0.1))/(beta_bins-1))
  t_label <- seq(-1, 1, by = (2/(tbins-1)))                
  
  # preallocate matrices
  val_l_win <- array(0, dim = c(alpha_bins, alpha_bins, trials))
  val_l_loss<- array(0, dim = c(alpha_bins, alpha_bins, trials))
  
  # run Rescorla-Wagner model with two separate learning rates for wins and losses
  for (reward_lr in 1:alpha_bins){
    for (loss_lr in 1:alpha_bins){
      
      # calculate trial-wise probability estimates for wins (first column) and losses (second column)
      learn_left <- rescorla_wagner(information, c(inv_logit(a_label[reward_lr],1), inv_logit(a_label[loss_lr],1)))
      val_l_win[reward_lr, loss_lr,] <- learn_left[,1] # trial-wise probability of win being associated with shape A (as experienced by participant)
      val_l_loss[reward_lr, loss_lr,] <- learn_left[,2] # trial-wise probability of loss being associated with shape A (as experienced by participant)
      
    }
  }
  
  
  # replicate the resulting matrices so that they can be multiplied with beta values
  mmdl_win <- array(val_l_win, c(alpha_bins, alpha_bins, trials, beta_bins, beta_bins))
  mmdl_loss <- array(val_l_loss, c(alpha_bins, alpha_bins, trials, beta_bins, beta_bins))
  
  beta <- aperm(array(data = exp(b_label), dim = c(30,30,trials,30,30)), c(2,4,3,1,5))
  t    <- aperm(array(data = t_label, dim = c(30,30,trials,30,30)), c(2,4,3,5,1))                
  
  # apply softmax function to calculate choice probabilities for each trial
  probleft <- 1/(1+exp(-beta*(mmdl_win-mmdl_loss+t)))
  rm(mmdl_win,mmdl_loss, beta, t)
  
  ch <- aperm(array(data = choice, dim = c(80,30,30,30,30)), c(2,3,1,4,5))
  
  #  calculate likelihood of choices given the parameter values
  probch <- ((ch*probleft)+((1-ch)*(1-probleft)))
  rm(ch, probleft)
  probch <- probch[,,resp_made,,] # only use trials in which response was made
  

  
  # This calculates the overall likelihood of the parameters by taking the product of the individual trials. The final term which
  # multiples the number by a large amount just makes the numbers manageable (otherwise they are very small). Note that this is now a
  # four dimensional matrix which contains the likelihood of the data given the three parameters which are coded on the dimensions (learning
  # rate, temperature, a). 
  posterior_prob <- (apply(probch, c(1,2,4,5), prod))* 10^(trials/5)
  rm(probch)
  
  #system.time(probch[,,1,,]*probch[,,2,,]*probch[,,3,,]*probch[,,4,,]*probch[,,5,,]*probch[,,6,,]*probch[,,7,,]*probch[,,8,,])
  
  
  # renormalise (all probabilities sum up to 1)
  posterior_prob <- posterior_prob/sum(posterior_prob)
  
  # store actual alpha and beta values
  alphalabel <- inv_logit(a_label,1)
  betalabel <- exp(b_label)
  
  # marginal distributions
  a_label <- t(matrix(a_label))
  
  # win learning rate
  marg_alpha_rew <- matrix(rowSums(rowSums(rowSums(posterior_prob, dims = 3), dims = 2), dims = 1))
  mean_alpha_rew <- as.numeric(inv_logit(a_label%*%marg_alpha_rew,1)) # derive expected value of learning rate from marginal distribution
  var_alpha_rew <- as.numeric(inv_logit(((a_label-inv_logit(mean_alpha_rew))^2)%*%marg_alpha_rew,1))
  
  # loss learning rate
  marg_alpha_loss <- matrix(colSums(rowSums(rowSums(posterior_prob, dims = 3), dims = 2), dims = 1))
  mean_alpha_loss <- as.numeric(inv_logit(a_label%*%marg_alpha_loss,1))
  var_alpha_loss <- as.numeric(inv_logit(((a_label-inv_logit(mean_alpha_loss))^2)%*%marg_alpha_loss,1))
  
  # inverse temperature 
  marg_beta <- matrix(colSums(rowSums(posterior_prob, dims = 3), dims = 2))
  mean_beta <- as.numeric(exp(b_label%*%marg_beta))
  var_beta <- as.numeric(exp(((b_label-log(mean_beta))^2)%*%marg_beta))
  
  # tendency parameter
  marg_t <- matrix(colSums(colSums(posterior_prob, dims = 2), dims = 1))
  mean_t<- as.numeric(t_label%*%marg_t)
  var_t <- as.numeric(((t_label-mean_t)^2)%*%marg_t)
  
  rm(posterior_prob)
  
  ## calculate LL from parameter estimates
  bel <- rescorla_wagner(information, c(mean_alpha_rew, mean_alpha_loss))
  bel_corr <- cor.test(bel[,1], bel[,2])
  prob_ch_left  <- 1/(1+exp(-mean_beta*(bel[,1]-bel[,2]+mean_t)))    
  likelihood <- prob_ch_left
  likelihood[choice==0] <- 1-likelihood[choice==0]
  neg_log_like <- -sum(log(likelihood[resp_made]+1e-16))
  
  BIC <- (2*neg_log_like)+4*(log(sum(resp_made))-log(2*pi)) # 4 parameters
  AIC <- (2*neg_log_like)+8
  
  rm(prob_ch_left)
  out <- c(mean_alpha_rew, mean_alpha_loss, mean_beta, mean_t,AIC, BIC)
  
  return(out)
  
}
