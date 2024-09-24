# Time Series Analysis - Impact of Covid Restrictions and Travelling

I conducted this group project as part of the CodeFirstGirls Degree in Data Science. The part of the project I worked on used time series analysis to model the time course of Covid infections and analyse the impact of restrictions and travel on the number of new Covid cases. 

The analysis is described in detail in the following file:
- [Covid Dataset Notebook](https://github.com/verenasarrazin/Analysis-and-coding/blob/main/CovidDataset/Timeseries_analysis_travel_and_restrictions.ipynb)

### The notebook has the following structure:
1. Exploring the trend of new COVID cases in the UK between 03/2020 and 01/2022
2. Exploring predictor variables (travel and restrictions)
3. Conducting tests to determine an appropriate approach to model time series
4. Predicting the trend of COVID cases using regression analysis

## Summary and Conclusions

Combining different publicly available datasets on Covid rate, extent of travel and restrictions, I analysed the time course of Covid cases in the UK and how it has been affected by travel and restrictions. Using regression analysis with an auto-regressive term, I found that the extent of travel and restrictions had an impact on the Covid rate with a one-month lag. As hypothesised, a higher extent of travel increased the Covid rate, whereas a larger number of restrictions decreased it. These results are very reassuring since they suggest that restrictions actually had a useful impact. However, conclusions from this project are limited, since the analysis did not take into account the complexity of factors influencing Covid rates (such as different variants, vaccines etc.). 
