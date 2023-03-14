# SpotifySongPopularity
Analysis of select Spotify songs from 1920-2020

Contributors: Jenny Guo, Isabella McGlone, Edith Garcia, Kai Vincent, Prableen Kaur, Reva Chaudhry

## Data Summary
To limit the dataset to songs, we identified a datum as an outlier if it obtains the following characteristics:
- exceeds the duration range between 30000 and 720000 milliseconds
- instrumentalness of 0
- loudness greater than 0
- speechiness more than 0.66
- tempo of 0

We identified these ranges as normal for a song, assuming that any datum beyond these ranges is not a song, but rather a podcast or a soundbite.
For the purposes of this analysis, we also excluded songs with a liveliness exceeding 0.8 since live performances are not relevant to suggestions relating to what new songs Universal Music should produce.

Using these measures, we created a subset of the dataset and ran our analyses on this significant dataset.

We further divided the data in order to investigate if the subgroup with speechiness less than 0.66 and greater than 0.33 (which includes rap music and has 19000 songs) have different variable correlations with popularity versus the subgroup with speechiness less than 0.33 (non-speech tracks, whose heat map is almost identical to that of the entire group).

## Variable Correlations
### Correlations with Popularity
- We visualized correlations between the variables in a heat map and found that the three most positively related to popularity were year, energy, and loudness (0.877, 0.479, and 0.393 respectively). **This indicates that the newest music with high energy and loudness tends to be the most popular.**
- We also discovered that there were high correlations between these variables which relate to popularity, indicating that there may be interaction. Most notably, loudness and energy had a correlation of 0.783.
- Further supporting the conclusion that there may be interaction between the variables which contribute to popularity, we found that valence and danceability, which were lowly correlated with popularity,  were individually correlated with both loudness and energy (Appendix A).

### Correlations Grouped by Speechiness Level
- Within the subset defined by speechiness between 0.33 and 0.66, we found significant changes in correlations. Duration and explicitness are more highly correlated with popularity in the “speechier” subgroup versus the overall/more musical subgroup.
- Danceability was also significantly less positively correlated, and mode and valence were significantly more negatively correlated (Appendix B).

### Comparing Mean of Variables with Popular Songs
To further understand what variables correlate with the highest performing sounds, we compared the mean of each numeric variable from the entire dataset (excluding outliers) with that of sounds with popularity > 50. 
The higher performing songs were louder, had more energy, were more likely to be explicit, and were less likely to be acoustic or instrumental (Appendix C).

## Variables Over Time
Here are our findings from visualizing the average value of several variables over time:
- We saw a sharp decline in acousticness & instrumentalness from the 50’s to the 80’s which may be attributed to the rising popularity of rock and electronic music; they have been on a gradual decline since then.
- There is an overall sharper increase in the energy of the sounds and a gradual increase in the danceability.
- Liveness has been relatively steady, while speechiness has gradually increased since the 60’s, which may parallel the rise in rap music (Appendix D). 

**Based on these trends, we can predict that music will continue to be characterized by increasing energy and danceability, as opposed to being instrumental or acoustic.**

We visualized the correlation between each variable & popularity after grouping the dataset by year in order to discern any trends over time (Appendix E).
Findings:
- These values and correlations varied, sometimes unpredictably (i.e., they did not seem to follow a particular pattern over the course of several years). Furthermore,
- Trends changed wildly over the last five years of the dataset (2015-2020). One potential explanation for this volatility is the rise of TikTok during the same time period and the increasing relationship between short-form social media content in general with music.
- It appears that there is a disconnect between musical trends followed by artists and the musical tastes of listeners. This may help explain why indie or undiscovered artists have enjoyed a surge in popularity in recent years; such artists may be producing the content that listeners are searching for before mainstream artists catch on.

## Regression Models
### Popularity ~ Energy + Valence
We constructed a regression model taking into account how popularity would be affected by the inclusion of energy and valence in songs. We found the p-values of the model to be significant (less than 5%).

We used valence as a categorical variable, making songs with a valence < 0.5 “sad”, and the rest “happy”. We were able to conclude the following functions:

    Happy Songs: Popularity = 3.47 + 46.70 * Energy
    Sad Songs: Popularity = 3.47 + 12.21 + ( 46.70 -9.82) * Energy
  
For happy songs, every decibel increase in Energy, Popularity increases, on average by 46.7. For a sad song we first add 12.21(the intercept adjustment for sad songs) to the initial intercept, subtract 9.82 from the energy slope, meaning that for every decibel increase in Energy, Popularity increases, on average by 36.88. 

**This means sad songs are generally more popular than happier ones, regardless of their energy level.**

### Popularity ~ Loudness * Danceability
We created a regression model testing how popularity is affected by the combination of loudness and danceability. We found the p-values of these models to be significant (less than 5%).

We turned danceability into a categorical variable, by making values 0 to 0.33 low, values 0.33 to 0.66 medium, and values 0.66 to 1 high. From using the summary function, we determined the following equations:

    Low Danceability:  Popularity = (57.58 - 24.34) + (2.14 - 1.51) * Loudness 
    Medium Danceability: Popularity = (57.58 - 11.04) + (2.14 - 0.61) * Loudness
    High Danceability: Popularity = 57.58 + 2.14 * Loudness

When a song has low danceability, popularity increases by only 0.63 and if danceability is medium, popularity increases by 1.53. However, if danceability is high, popularity increases by 2.14. We can conclude that louder songs are more popular if they have high danceability, and softer songs are most popular if they have less danceability.

## Final Recommendations
Based on the interactive regression model of energy and valence over popularity, we suggest that Universal Music:
- Produces more sad songs that are louder, have more energy, are more explicit, and less acoustic
- When producing happy danceable songs, make the songs loud
- Danceable happy songs should be promoted through TikTok via dance trends
- Sign more artists from social media who produce niche music genres

### Future Variables for Consideration:
- **Remix**: 1 if the song is a remix, 0 otherwise. The song is a remix if it is a new or different version of a recorded song that is made by changing or adding to the original recording of the song.
- **Duplicate**: 1 if the song is a duplicate, 0 otherwise. Sometimes on Spotify the same song will be released by different artists/repeated on an album and a single/etc. This variable can check how repeats of the same song affect the data.
- **Language**: language(s) of the lyrics of the song.
- **Geography**: most popular country the song exists in.
- **Genre**: conventional category of a song. Examples include pop, rap, EDM, classical, etc.
- **Mean age of listeners**: average age of unique listeners of a song.
