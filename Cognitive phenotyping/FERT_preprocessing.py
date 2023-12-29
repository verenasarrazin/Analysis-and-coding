

########################################################################################################################################################################################################
# FERT preprocessing #
########################################################################################################################################################################################################


import numpy as np
import pandas as pd
import glob

# define directory
dir_path = '/Users/verenasarrazin/Documents/Oxford/Post-doc/Brazil_TMS_study/FERT/FERT_full_data/0*.csv'
filenames = sorted(glob.glob(dir_path))

# read in data files
data = pd.DataFrame(columns=['ID', 'Session', 'im_block', 'im_stimNo', 'im_emotion', 'im_percentEmo', 'key_respTrial.keys',
                             'key_respTrial.rt', 'trialOrderFile'])

for file in filenames:
    print(file)
    df = pd.read_csv(file)
    df = df.dropna(subset=['loop_trials.thisN'])  # remove practice trials and empty rows
    df['ID'] = file[-9:-6] # add ID from filename
    df['Session'] = file[-5] # add Session from filename
    df = df[['ID', 'Session','im_block', 'im_stimNo', 'im_emotion', 'im_percentEmo', 'key_respTrial.keys', 'key_respTrial.rt',
             'trialOrderFile']]
    data = pd.concat([data, df])


# rename variables
data.rename(columns={'im_block': 'Block', 'im_stimNo':'Trial', 'im_emotion':'Emotion', 'im_percentEmo':'Intensity',
                     'key_respTrial.keys':'Choice', 'key_respTrial.rt':'RT', 'trialOrderFile':'Protocol'}, inplace=True)

data = data[~data.ID.isin(['008', '012', '015'])] # exclude participants with incomplete datasets

# double-check all IDs have 500 trials (2 x 250)
trials_count = pd.DataFrame(data['ID'].value_counts())
sum(trials_count['count'] != 500)


# rename Choice values from numbers to emotions
data['Choice']=data['Choice'].map(str)
data.loc[data['Choice'] == '1.0', 'Choice'] = 'anger'
data.loc[data['Choice'] == '2.0', 'Choice'] = 'disgust'
data.loc[data['Choice'] == '3.0', 'Choice'] = 'fear'
data.loc[data['Choice'] == '4.0', 'Choice'] = 'happy'
data.loc[data['Choice'] == '5.0', 'Choice'] = 'sad'
data.loc[data['Choice'] == '6.0', 'Choice'] = 'surprise'
data.loc[data['Choice'] == '7.0', 'Choice'] = 'neutral'
data.loc[data['Emotion'] == 'digust', 'Emotion'] = 'disgust'

# add valence
data['Valence'] = "NaN"
data.loc[data['Emotion'].isin(['happy', 'surprise']), 'Valence'] = 'positive'
data.loc[data['Emotion'].isin(['fear', 'anger', 'disgust', 'sad']), 'Valence'] = 'negative'
data.loc[data['Emotion'] == 'neutral', 'Valence'] = 'neutral'

# add datadset number
data['Dataset'] = [element for element in [*range(1,99)] for i in range(250)] # repeat values 1 to 98, 250 times each
trial_count = pd.DataFrame(data['ID'].value_counts()) # count trials per ID
pd.DataFrame([trial_count['count'] != 500]).iloc[0].sum(axis=0) # check if any ID has more or less than 500 trials


#################################################################################################################################################################################################################
## Accuracy ##
#################################################################################################################################################################################################################

# correct answer
data['Correct'] = np.NaN
data.loc[data['Choice'] == data['Emotion'], 'Correct'] = 1
data.loc[data['Choice'] != data['Emotion'], 'Correct'] = 0

# calculate accuracy
performance = data.groupby(['ID', 'Session', 'Emotion','Valence', 'Intensity'])['Correct'].sum().reset_index() # number of correct responses per emotion and intensity
performance['Correct'] = performance['Correct']/4 # percentage
performance.loc[performance['Emotion'] == 'neutral', 'Correct'] = performance.loc[performance['Emotion'] == 'neutral', 'Correct']/2.5 # neutral faces are shown 10 times (instead of 4)

# wide format

Performance = data.pivot_table(index = ['ID', 'Session', 'Emotion', 'Valence'], columns = 'Intensity', values = 'Correct').reset_index() # can be calculated from raw data, np.mean() is default aggregate function
# performance.pivot_table(index = ['ID', 'Session', 'Emotion', 'Valence'], columns = 'Intensity', values = 'Correct').reset_index()
Performance['Accuracy'] = Performance.iloc[:, 4:14].mean(axis=1)



#################################################################################################################################################################################################################
# Unbiased hit rate #
#################################################################################################################################################################################################################

# Correct classification of emotion * (emotion correctly chosen / emotion chosen)

# Misclassifications
Misclassifications = data.groupby(['ID', 'Session', 'Emotion', 'Choice']).size().unstack(fill_value=0).stack().reset_index() # count how many times each emotion has been classified as each emotion (the unstack/stack functions are used to count zero occurrances)
Misclassifications = Misclassifications.rename(columns={0:'Count'})
Correct_answers = Misclassifications.loc[Misclassifications['Choice'] == Misclassifications['Emotion'],:]
Correct_answers = Correct_answers[['ID', 'Session', 'Emotion', 'Count']]
Correct_answers = Correct_answers.rename(columns={'Count':'Emotion_correctly_chosen'})
Performance = pd.merge(Performance, Correct_answers, on=['ID','Session','Emotion'])
Misclassified = Misclassifications.loc[Misclassifications['Choice'] != Misclassifications['Emotion'],:]
Misclassified = Misclassified.groupby(['ID', 'Session', 'Choice']).sum().reset_index()
Misclassified = Misclassified[['ID', 'Session', 'Choice', 'Count']]
Misclassified = Misclassified.rename(columns={'Choice':'Emotion', 'Count':'Emotion_incorrectly_chosen'})
Performance = pd.merge(Performance, Misclassified, on=['ID','Session','Emotion'])

# Calculate Unbiased Hit Rate
Performance['Unbiased_hit_rate'] = Performance['Accuracy'] * (Performance['Emotion_correctly_chosen'] / (Performance['Emotion_correctly_chosen'] + Performance['Emotion_incorrectly_chosen']))


################################################################################################################################################################################################################
# Bias measures #
#################################################################################################################################################################################################################

# Accuracy

Bias = Performance[['ID','Session','Emotion', 'Accuracy', 'Unbiased_hit_rate']]
Bias = Bias.pivot_table(index = ['ID', 'Session'], columns = 'Emotion', values = ['Accuracy','Unbiased_hit_rate']).reset_index()
Bias.columns = [''.join(col) for col in Bias.columns]

Bias['Accuracy_pos'] = (Bias[('Accuracyhappy')] + Bias[('Accuracysurprise')])/2
Bias['Accuracy_neg'] = (Bias[('Accuracyfear')] + Bias[('Accuracydisgust')] + Bias[('Accuracyanger')] + Bias[('Accuracysad')])/4
Bias['Positive_bias_acc'] = np.log(Bias['Accuracy_pos']/Bias['Accuracy_neg'])

# Unbiased hit rate
Bias['UBH_pos'] = (Bias[('Unbiased_hit_ratehappy')] + Bias[('Unbiased_hit_ratesurprise')])/2
Bias['UBH_neg'] = (Bias[('Unbiased_hit_ratefear')] + Bias[('Unbiased_hit_ratedisgust')] + Bias[('Unbiased_hit_rateanger')] + Bias[('Unbiased_hit_ratesad')])/4
Bias['Positive_bias_UBH'] = np.log(Bias['UBH_pos']/Bias['UBH_neg'])


# Merge
bias = Bias[['ID', 'Session', 'Accuracy_pos', 'Accuracy_neg', 'Positive_bias_acc', 'UBH_pos', 'UBH_neg', 'Positive_bias_UBH']]
all = pd.merge(Performance, bias, on=['ID','Session'])



#################################################################################################################################################################################################################
## RT ##
#################################################################################################################################################################################################################

data_rt = data.copy() # without .copy() changes will be transferred to original dataset
data_rt['Excluded_RT'] = np.NaN
data_rt.loc[(data_rt['RT'] > 6) | (data_rt['RT'] < 0.2), 'Excluded_RT'] = 1
data_rt['Excluded_RT'].sum() # number of excluded RTs
data_rt.loc[data_rt['Excluded_RT']==1, 'Choice'] = np.nan # trials with RTs shorter than 0.2s or longer than 6s are excluded (also the choice)
data_rt.loc[data_rt['Excluded_RT']==1, 'RT'] = np.nan
data_rt.loc[data_rt['Excluded_RT']==1, 'Correct'] = np.nan

# !! Should accuracy etc. be calculated after excluding trials based on RT??

# Calculate number of excluded trial per dataset
excluded_rt = data_rt[['Dataset', 'Excluded_RT']].groupby(['Dataset']).sum(['Excluded_RT']).reset_index()

data_rt.loc[data_rt['Correct'] == 0, 'RT'] = np.NaN # Exclude trials with incorrect choice from RT analysis
data_rt['RT'].isna().sum()

mean_rt = data_rt[['ID', 'Session', 'Emotion', 'RT', 'Valence']].groupby(['ID', 'Session', 'Emotion', 'Valence']).agg(['mean','median']).reset_index()
mean_rt.columns = [''.join(col) for col in mean_rt.columns]

all = pd.merge(all, mean_rt, on=['ID','Session', 'Emotion', 'Valence'])

# !! OUTLIER REMOVAL?



#################################################################################################################################################################################################################
# Positive bias in RT #
#################################################################################################################################################################################################################


# mean RT for positive and negative emotions
RT_bias = mean_rt[['ID', 'Session', 'Valence', 'RTmean', 'RTmedian']].groupby(['ID', 'Session', 'Valence']).mean().reset_index()
# MEAN OF MEDIANS?


# wide format
RT_bias = RT_bias.pivot_table(index = ['ID', 'Session'], columns = 'Valence', values = ['RTmean','RTmedian']).reset_index()
RT_bias.columns = [''.join(col) for col in RT_bias.columns]
RT_bias['Positive_bias_mean_RT'] = np.log( RT_bias['RTmeannegative']/RT_bias['RTmeanpositive'])
RT_bias['Positive_bias_median_RT'] = np.log( RT_bias['RTmediannegative']/RT_bias['RTmedianpositive'])

all = pd.merge(all, RT_bias, on=['ID','Session'])


#################################################################################################################################################################################################################
# Efficiency scores #
#################################################################################################################################################################################################################

# Variables: Accuracy, Unbiased hitrate, misclassification, mean RT, median RT, efficiency
# and bias for all variables
# per ID, Session and Emotion

all['Efficiency_mean'] = all['Accuracy']/all['RTmean']
all['Efficiency_median'] = all['Accuracy']/all['RTmedian']

# Positive bias in Efficiency Score ##############################################################################################################################################################################

Efficiency_bias = all[['ID', 'Session', 'Valence', 'Efficiency_mean', 'Efficiency_median']].groupby(['ID', 'Session', 'Valence']).mean().reset_index()
Efficiency_bias = Efficiency_bias.pivot_table(index = ['ID', 'Session'], columns = 'Valence', values = ['Efficiency_mean','Efficiency_median']).reset_index()
Efficiency_bias.columns = [''.join(col) for col in Efficiency_bias.columns]
Efficiency_bias['Positive_bias_Efficiency_mean'] = np.log( Efficiency_bias['Efficiency_meanpositive']/Efficiency_bias['Efficiency_meannegative'])
Efficiency_bias['Positive_bias_Efficiency_median'] = np.log( Efficiency_bias['Efficiency_medianpositive']/Efficiency_bias['Efficiency_mediannegative'])

all = pd.merge(all, Efficiency_bias, on=['ID','Session'])

# Combine HAMD scores with task measures
HAMD_change = pd.read_pickle('/Users/verenasarrazin/Documents/Oxford/Post-doc/TMS_trial/FERT/Analysis_files/HAMD_change.pkl')
FERT_measures = pd.merge(all, HAMD_change, on = 'ID')

# save
FERT_measures.to_pickle('/Users/verenasarrazin/Documents/Oxford/Post-doc/TMS_trial/FERT/Analysis_files/FERT_measures_TBS.pkl')







