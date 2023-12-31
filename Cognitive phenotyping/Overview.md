# Cognitive Phenotyping

This project aims at exploring cognitive phenotypes of depression. Depression is associated with large variability in symptomatology as well as in treatment response. It has therefore been suggested that different phenotypes of depression might exist with different underlying psychopathology. Individuals with the same phenotype of depression might be similar in psychopathology and might therefore respond to the same treatment. 

The goal of this project is to test whether different phenotypes of depression can be identified based on the performance of cogntive tasks (for example tasks capturing negative cognitive biases). I am investigating which parameters extracted from five different cognitive tasks could capture distinct symptom dimensions of depression.


## Factor analysis of mood questionnaires

To extract different dimensions of depressive symptoms, I performed factor analysis on mood questionnaire ratings.

- <a href="https://verenasarrazin.github.io/Analysis-and-coding/FA_github.html" title="Factor analysis script (R)">Factor analysis script (R)</a>


## Analysis of task performance

Participants were asked to perform five cognitive tasks. In the first task, participants need to indicate the emotion of faces which are briefly presented on the screen. Depression has been associated with an increased bias towards recognising facial expressions as negative. 

- [Task analysis script (Python)](https://github.com/verenasarrazin/Analysis-and-coding/blob/main/Cognitive%20phenotyping/FERT_preprocessing.py)


## Relating task measures to mood 

I then used regression analysis to test whether different symptom dimensions can predict the measures derived from cognitive task performance.

- <a href="https://verenasarrazin.github.io/Analysis-and-coding/Regression_github.html" title="Regression analysis script (R)">Regression analysis script (R)</a>


## Canonical Correlation Analysis (CCA)

CCA aims at maximising the correlation between linear combinations of two different modalities. In this project, I will use CCA to identify different dimensions of task measures correlated to different symptom dimensions. 

<img src="https://github.com/verenasarrazin/Analysis-and-coding/assets/73107031/34dea119-237e-450a-8117-2ea0b4732602" alt="drawing" width="500"/>


*Figure adapted from: Fan M, Yang AC, Fuh J-L and Chou C-A (2018) Topological Pattern Recognition of Severe Alzheimer's Disease via Regularized Supervised Learning of EEG Complexity. Front. Neurosci. 12:685. doi: 10.3389/fnins.2018.00685*

