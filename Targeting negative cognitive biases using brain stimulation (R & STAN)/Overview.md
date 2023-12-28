# Targeting Negative Cognitive Biases Using Brain Stimulation 

This is the main project I conducted during my DPhil. The aim of the project was to test whether transcranial direct curent stimulation (tDCS), 
a non-invasive brain stimulation technique, can normalise reward and punishment learning in depression. Depression has previously been associated with
deficits in reward and punishment learning. These deficits might to lead to an increased focus on negative information, which are thought to cause and maintain
depressive symptoms. Normalising these deficits in reward and punishemnt learning might therefore be a novel intervention approach.

## Computational Modelling

In this study, participants performed a reward and punishment learning task. The analysis of this tasks requires fitting refinforcementlearning models to participants' trial-by-trial choices. I used two approaches:

#### Fitting a reinforcement learning model using grid approximation:
- [Function that performs model fitting (R)](https://github.com/verenasarrazin/Analysis-and-coding/blob/main/Targeting%20negative%20cognitive%20biases%20using%20brain%20stimulation%20(R%20%26%20STAN)/fit_model1_block_wise.R)
- [Wrapper script (R)](https://github.com/verenasarrazin/Analysis-and-coding/blob/main/Targeting%20negative%20cognitive%20biases%20using%20brain%20stimulation%20(R%20%26%20STAN)/Parameter_estimation_model1_blockwise.R)
  
#### Fitting a reinforcement learning model using STAN:
- [Function that fits the model (STAN)](https://github.com/verenasarrazin/Analysis-and-coding/blob/main/Targeting%20negative%20cognitive%20biases%20using%20brain%20stimulation%20(R%20%26%20STAN)/fit_model6_constant.stan)
- [Wrapper script (R)](https://github.com/verenasarrazin/Analysis-and-coding/blob/main/Targeting%20negative%20cognitive%20biases%20using%20brain%20stimulation%20(R%20%26%20STAN)/Parameter_estimation_model6_constant.R)
  
## Statistical Analysis

The parameter estimates derived from the computational models were analysed in repeated-measures ANOVAs. The main analysis of interest was the contrast between real tDCS and sham tDCS (placebo).

- [Analsysis script](https://github.com/verenasarrazin/Analysis-and-coding/blob/main/Targeting%20negative%20cognitive%20biases%20using%20brain%20stimulation%20(R%20%26%20STAN)/Effect_of_tDCS_constant_model.R): Removing outliers, ANOVAs, t-tests, figures


## Publication
The project has been published as [preprint on MedRxiv](https://www.medrxiv.org/content/10.1101/2023.04.24.23289064v1). I am very grateful for the opportunity to give a talk on this project at the Conference on Cognitive and Computational Neuroscience (CCN) 2023 in Oxford ([watch the recording of Youtube here](https://www.youtube.com/live/nxTSMQFx-HM?feature=shared&t=7521)). I have also given poster presentations on this project. 


![image](https://github.com/verenasarrazin/Analysis-and-coding/assets/73107031/594e6b0d-f73f-4459-b7d8-3b93c1bcf171)
