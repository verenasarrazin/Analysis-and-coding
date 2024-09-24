# Classification - Predicting Hiring Decisions

This was a group project that I completed as part of my CodeFirstGirls +Masters in AI & ML. The aim of this project was to build a model that can predict whether someone will be hired or not based on their education, work experience etc. The dataset is freely available on kaggle.com. 

The analysis is described in detail in the following file:
- [Predicting Hiring Decisions Jupyter Notebook](https://github.com/verenasarrazin/Analysis-and-coding/blob/main/HiringDecisionsDataset/HiringDataset.ipynb)

### My contributions to the project were:
- developing the analysis question
- search for a relevant dataset
- data pre-processing
- setting up machine learning pipelines
- model comparison and evaluation
- interpretation of the resuls

### The analysis is structured in the following way:
1. Pre-processing
2. Exploratory data analysis
3. Machine learning analysis
    - setting up cross-validation
    - model fitting and hyperparameter tuning
      - **logistic regression, support vector machines, random forest**
    - model comparison and evaluation
4. Conclusions
      
## Project summary

I used different ML algorithms to predict hiring decisions based on variables like education and work experience. I used a repeated stratified k-fold cross-validation procedure including feature selection and hyperparameter tuning to compare the performance of 3 different models. The models reached an accuracy of 63-70% in a held-out testing dataset. While the Random Forest model achieved the highest overall **accuracy**, which of the models is best suited for future prediction depends on the context. If we want to encourage someone to apply for a job if there is any chance at all that they might be successful, we should use the model with the highest **recall** (Logistic Regression model). If we only want to apply for a job if we are very certain our chances are high, then we should use the model with the highest **precision** (Random Forest model).

<br>


