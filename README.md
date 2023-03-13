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
