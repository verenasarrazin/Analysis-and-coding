
// Parameter estimation for model 6 (constant modelling appraoch). Script written by Verena Sarrazin and Michael Browning.
// One inverse temparture for wins, one inverse temperature for losses and 6 win and loss lR (one for each block)


data{
	int nsubs;  //number of subjects
	int ntrials; // number of trials
	real information[ntrials,2,nsubs];  // outcomes 
	int choice[ntrials,nsubs];   // choices
	int trialstouse[ntrials,nsubs];     // the first 10 trials are excluded
	int reset[ntrials,nsubs]; // reset probabilities to 0.5 at the start of each block
	int blocks[ntrials,nsubs]; // number of blocks
	real priorprec;     /// SD of priors
	
}
parameters{ 

    real alpha_win_bv1[nsubs]; // bv = both-volatile, wv = wins-volatile, lv = losses-volatile
    real alpha_win_bv2[nsubs];    
    real alpha_win_wv1[nsubs];
    real alpha_win_wv2[nsubs];
    real alpha_win_lv1[nsubs];
    real alpha_win_lv2[nsubs];
    real alpha_loss_bv1[nsubs];
    real alpha_loss_bv2[nsubs];
    real alpha_loss_wv1[nsubs];
    real alpha_loss_wv2[nsubs];
    real alpha_loss_lv1[nsubs];
    real alpha_loss_lv2[nsubs];
    
    real beta_win[nsubs];
    real beta_loss[nsubs];
}

model{
for (s in 1:nsubs){

    alpha_win_bv1[s]~normal(-0.5,priorprec);
    alpha_win_bv2[s]~normal(-0.5,priorprec);
    alpha_win_wv1[s]~normal(-0.5,priorprec);
    alpha_win_wv2[s]~normal(-0.5,priorprec);
    alpha_win_lv1[s]~normal(-0.5,priorprec);
    alpha_win_lv2[s]~normal(-0.5,priorprec);
    alpha_loss_bv1[s]~normal(-0.5,priorprec);
    alpha_loss_bv2[s]~normal(-0.5,priorprec);
    alpha_loss_wv1[s]~normal(-0.5,priorprec);
    alpha_loss_wv2[s]~normal(-0.5,priorprec);
    alpha_loss_lv1[s]~normal(-0.5,priorprec);
    alpha_loss_lv2[s]~normal(-0.5,priorprec);

    beta_win[s]~normal(0,priorprec);
    beta_loss[s]~normal(0,priorprec);
}

	for (s in 1:nsubs) 
	    {
	      real betas_win;
	      real betas_loss;
	      real wlr; // winLR
	      real llr; // lossLR
	      
	      real b1; // win probability
	      real b2; // loss probability
	
              betas_win=exp(beta_win[s]);
              betas_loss=exp(beta_loss[s]);
		          
              
            
                b1=0.5;
                b2=0.5;
                //trials
                for (t in 1:ntrials){
                  
                    // reset probabilities to 0.5 at the start of each block
                    if (reset[t,s]==1) {
                                b1=0.5; 
                                b2=0.5;
                    } 
                    
                    // use trials specified in trialstouse    
                    if (trialstouse[t,s]==1){
                      choice[t,s] ~ bernoulli_logit(betas_win*(b1-0.5) - betas_loss*(b2-0.5)); // here, the estimated outcome associations are transformed into action probabilities
                    }
                      
                    // Volatility condition (blocks variable: 1: bv1, 2: wv1, 3: lv1, 4: wv2, 5: lv2, 6: bv2)
                    if (blocks[t,s] == 1){
                      wlr=Phi_approx(alpha_win_bv1[s]);
                      llr=Phi_approx(alpha_loss_bv1[s]);
                    }
                    else if(blocks[t,s] == 2){
                      wlr = Phi_approx(alpha_win_wv1[s]);
                      llr = Phi_approx(alpha_loss_wv1[s]); 
                    }
                    else if(blocks[t,s] == 3){
                      wlr = Phi_approx(alpha_win_lv1[s]);
                      llr = Phi_approx(alpha_loss_lv1[s]);
                    }
                    else if(blocks[t,s] == 4){
                      wlr = Phi_approx(alpha_win_wv2[s]);
                      llr = Phi_approx(alpha_loss_wv2[s]);
                    }
                    else if(blocks[t,s] == 5){
                      wlr = Phi_approx(alpha_win_lv2[s]);
                      llr = Phi_approx(alpha_loss_lv2[s]);
                    }
                    else if(blocks[t,s] == 6){
                      wlr = Phi_approx(alpha_win_bv2[s]);
                      llr = Phi_approx(alpha_loss_bv2[s]);
                    }

                b1 = ((1-wlr) * b1) + (wlr* information[t,1,s]); // updating of the estimated win probability
                b2 = ((1-llr) * b2) + (llr* information[t,2,s]); // updating of the estimated loss probability
               
		            }
	    }
}

