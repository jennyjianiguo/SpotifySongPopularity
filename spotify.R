library(tidyverse)
library(moderndive)
library(GGally)
library(reshape2)

# Import the spotify dataset
spotify <- read.csv("Spotify_SP23.csv")

################## Jenny Guo's contribution ##########################
# Initial exploration of Spotify data

#### 1. Dataset Exploration ####

# List of all variables
ls(spotify)

# Find all variable types
sapply(spotify, class)
# acousticness: numeric
# artists: character
# danceability: numeric
# duration_ms: numeric
# energy: numeric
# explicit:: numeric
# id: character
# instrumentalness: numeric
# key: numeric
# liveness: numeric
# loudness: numeric
# mode: numeric
# name: character
# popularity: numeric
# speechiness: numeric
# tempo: numeric
# valence: numeric
# year: numeric

# Summary of dataset
summary(spotify)
# Findings:
# - There exists no NA values for any column.
# - Minimum duration_ms is 5108, meaning the shortest song is 5 seconds. 
#   This datapoint may be an outlier.

# Looking at outliers using histogram and boxplot: duration_ms
spotify %>% 
  ggplot(aes(x=duration_ms)) +
  geom_histogram()
spotify %>% 
  ggplot(aes(x=duration_ms)) +
  geom_boxplot()

# Create significant subset (data points that are likely songs)
# Slide 4
spotify_songs <- spotify %>% 
  filter(duration_ms>30000 & duration_ms<720000
         & instrumentalness!=0
         & loudness<=0
         & speechiness<0.66
         & tempo!=0
         & liveness<0.8)

### 2. Correlation Analysis ####

# Build correlation matrix with all numeric variables
spotify.numeric <- select_if(spotify_songs, is.numeric)
spotify_num_cor <- round(cor(na.omit(spotify.numeric)), 3)
# Findings:
# - Year has a low correlation with acousticness (-0.648).
# - Year has a high correlation with energy (0.509)
# - Year has a high correlation with popularity (0.877).
# - Valence has a high correlation with danceability (0.593).
# - Popularity has a negative correlation with acousticness (-0.62)
# - Loudness has a negative correlation with acousticness (-0.582).
# - Loudness has positive correlation with energy (0.783).
# - Energy has a negative correlation with acousticness (-0.799).

# Create scatterplot matrix --error loading due to size
ggpairs(spotify.numeric)

# Create heat map of correlation between variables
# Slide 5
spotify_melt <- melt(spotify_num_cor)
spotify_melt %>% 
  ggplot(aes(x=Var1, y=Var2, fill=value)) +
  geom_tile() +
  scale_fill_gradient2(low='lightblue',
                       high='lightgreen',
                       mid='white',
                       midpoint=0) +
  geom_text(aes(x=Var1, y=Var2, label=value), size=3) +
  theme(axis.text.x=element_text(size=8,
                                 angle=30,
                                 hjust=0.8)) +
  ggtitle("Heatmap of Spotify Dataset")
# What are the key factors related to popularity of songs?
# Popularity has the strongest correlations with:
# - acousticness (-0.62)
# - energy (0.479)
# - instrumentalness (-0.313)
# - loudness (0.393)
# - year (0.877)


##################### Edith Garcia's contribution ####################### 
# Focus Question:
# What are the key factors related to popularity of songs?
# Are there simple rules to select songs with potentials of high popularity?
# Variables: dance ability, loudness, year

# Regression Models in executive summary and Found on Slide 6 
# The regression model basically tells us the impact valance and energy have in the popularity of a song. 
# I first had to make valence a categorical variable by mutating it before finding the regression model
spotify_songs=spotify_songs %>% 
  mutate(v_songs=ifelse(valence<0.5,"sad","happy"))

lm3=lm(popularity~energy * v_songs, spotify_songs)
summary(lm3)

### happy songs: popularity = 3.47 + 46.70 * energy
### sad songs: popularity = 3.47 + 12.21 +( 46.70 -9.82) * energy

###### What the formula means? 
# For every decibel increase in Energy, Popularity increases, on average 46.7
# If it is a sad song then we add 12.21(the intercept adjustment for sad songs) to the initial intercept,
# subtract 9.82 from the energy slope, meaning that for every decibel increase in Energy, 
# Popularity increases, on average 36.88. 

# Scatter plot of the Regression Model helping see that sad songs tend to be more popular
# than happy songs on Spotify. 
# Graph also found on Slide 6
lm3 %>% 
  ggplot(aes(x=energy, y=popularity, color=v_songs)) +
  geom_point(alpha=0.15) +
  geom_parallel_slopes(se=FALSE)



############ Prableen Kaur's contribution ################
# Analysis of loudness and danceability using regression model
# All these findings are on slide 7 and the 'regression models' section of the summary

# Changing danceability to low, medium, high (a categorical variable)
spotify_songs <- spotify_songs %>% 
  mutate(dance_cat=ifelse(danceability<0.33, "L",
                          ifelse(danceability<0.66, "M", "H")))
# dance_cat = variable name for splitting danceability into high, med, low
# Low: 0 to 0.33
# Medium: 0.33 to 0.66
# High: 0.66 to 1


# Regression model of loudness and danceability
lmdanceloud <- lm(popularity~loudness*dance_cat, spotify_songs)
summary(lmdanceloud)
# lmdanceloud = variable name for the linear model of how popularity 
# interacts with loudness and the categories of danceabilitiy 
# significant

# dance_catL: popularity = (57.58 - 24.34) + (2.14 - 1.51) * loudness 

# dance_catM: popularity = (57.58 - 11.04) + (2.14 - 0.61) * loudness


# Graph of model
spotify_songs %>% 
  ggplot(aes(color=dance_cat, y=popularity, x=loudness)) +
  geom_point(alpha=0.03) +
  geom_smooth(method="lm", se=FALSE) +
  ggtitle("Linear model for Popularity over Danceability and Loudness")



############ Reva Chaudhry's contribution - ####################
# Looking into different speechiness subgroups and qualities of high performing songs

# According to project doc:
# speechiness > 0.66: exclusively speech-like recordings (like audiobooks, podcasts)
# 0.66 > speechiness > 0.33: contain both music and speech, like rap
# speechiness < 0.33: music and non speech tracks

# Do different variables influence the popularity of "Speechier" sounds 
# (that most likely include rap), and more musical songs?

# Filtering out speechier and more musical subgroups 
spotify_songs_rap <- spotify %>% 
  filter(duration_ms >30000 &
           duration_ms < 720000 &
           instrumentalness != 0 &
           loudness <= 0 &
           speechiness < 0.66 &
           speechiness > 0.33 &
           tempo != 0 &
           liveness < 0.8)
view(spotify_songs_rap)

spotify_songs_pop <- spotify %>% 
  filter(duration_ms >30000 &
           duration_ms < 720000 &
           instrumentalness != 0 &
           loudness <= 0 &
           speechiness < 0.33 &
           tempo != 0 &
           liveness < 0.8)


# Heat map of "speechier" subgroup 
rap.numeric <- select_if(spotify_songs_rap, is.numeric)
rap.cor <- round(cor(rap.numeric), 2)
rap.cor.melt <- melt(rap.cor)
rap.cor.melt
rap.cor.melt %>% 
  ggplot(aes(x=Var1, y=Var2, fill=value)) +
  geom_tile() + 
  scale_fill_gradient2(low="lightblue",
                       high="lightgreen",
                       mid="white",
                       midpoint=0) +
  geom_text(aes(x=Var1, y=Var2, label=value)) +
  theme(axis.text.x=element_text(size=8,
                                 angle=30,
                                 hjust=0.8)) +
  ggtitle("Heatmap of of Speechier subgroup (speechiness 0.33-0.66)")


# Heat map of musical subgroup
pop.numeric <- select_if(spotify_songs_pop, is.numeric)
pop.cor <- round(cor(pop.numeric), 2)
pop.cor.melt <- melt(pop.cor)
pop.cor.melt
pop.cor.melt %>% 
  ggplot(aes(x=Var1, y=Var2, fill=value)) +
  geom_tile() + 
  scale_fill_gradient2(low="lightblue",
                       high="lightgreen",
                       mid="white",
                       midpoint=0) +
  geom_text(aes(x=Var1, y=Var2, label=value)) +
  theme(axis.text.x=element_text(size=8,
                                 angle=30,
                                 hjust=0.8)) +
  ggtitle("Heatmap of Musical subgroup (speechiness<0.33)")

# Visualizing how valence and rap music are connected ####
spotify_songs_rap %>% 
  ggplot(aes(x=valence, y=popularity)) +
  geom_point() +
  geom_smooth(method="lm", se=0)


#### Factors that differentiate the most popular songs #########

# Filtering out songs with popularity>50 from dataset
spotify_50 <- spotify_songs %>% 
  filter(popularity > 50)

spotify_songs %>% 
  summarize(mean_danceability=mean(danceability, na.rm=TRUE),
            mean_loudness=mean(loudness, na.rm = TRUE), 
            mean_duration=mean(duration_ms, na.rm = TRUE),
            mean_energy=mean(energy, na.rm = TRUE),
            mean_explicit=mean(explicit, na.rm=TRUE),
            mean_valence=mean(valence, na.rm=TRUE),
            mean_acousticness=mean(acousticness, na.rm=TRUE),
            mean_tempo=mean(tempo, na.rm=TRUE),
            mean_instrument=mean(instrumentalness, na.rm=TRUE))

spotify_50 %>% 
  summarize(mean_danceability=mean(danceability, na.rm=TRUE),
            mean_loudness=mean(loudness, na.rm = TRUE), 
            mean_duration=mean(duration_ms, na.rm = TRUE),
            mean_energy=mean(energy, na.rm = TRUE),
            mean_explicit=mean(explicit, na.rm=TRUE),
            mean_valence=mean(valence, na.rm=TRUE),
            mean_acousticness=mean(acousticness, na.rm=TRUE),
            mean_tempo=mean(tempo, na.rm=TRUE),
            mean_instrument=mean(instrumentalness, na.rm=TRUE))

# Seeing if this comparison holds true even for "speechier" sub group
rap50 <- spotify_songs_rap %>% 
  filter(popularity > 50)

rap50 %>% 
  summarize(mean_danceability=mean(danceability, na.rm=TRUE),
            mean_loudness=mean(loudness, na.rm = TRUE), 
            mean_duration=mean(duration_ms, na.rm = TRUE),
            mean_energy=mean(energy, na.rm = TRUE),
            mean_explicit=mean(explicit, na.rm=TRUE),
            mean_valence=mean(valence, na.rm=TRUE),
            mean_acousticness=mean(acousticness, na.rm=TRUE),
            mean_tempo=mean(tempo, na.rm=TRUE),
            mean_instrument=mean(instrumentalness, na.rm=TRUE))



######### Kai Vincent's contribution #################
# Trends and future predictions

# Calculate average values for selected variables on an annual basis.
# Looking for any trends overall with different variables over time.
subset_avg_values_by_year <- spotify_songs %>%
  group_by(year) %>% 
  summarise(acousticness=round(mean(acousticness), 2),
            danceability=round(mean(danceability), 2),
            energy=round(mean(energy), 2),
            instrumentalness=round(mean(instrumentalness), 2),
            liveness=round(mean(liveness), 2),
            speechiness=round(mean(speechiness), 2),
            valence=round(mean(valence), 2)
  )

view(subset_avg_values_by_year)

# Create a visualization (as seen in the presentation & in appendix E) of the
# average values of selected variables by year
subset_avg_values_by_year %>% 
  pivot_longer(acousticness:valence, names_to = "variable", values_to = "avg") %>%
  ggplot(aes(x=year, y=avg, color=variable))+
  geom_line(size=1)+
  labs(title = "Average value of selected variables in songs by year")

# Now the same graph but limited to the last five years of the dataset
subset_avg_values_by_year %>% 
  pivot_longer(acousticness:valence, names_to = "variable", values_to = "avg") %>%
  filter(year>2014) %>% 
  ggplot(aes(x=year, y=avg, color=variable))+
  geom_line(size=1)+
  labs(title = "Average value of selected variables in songs by year (2015-2020)")


# Calculate cor values between several variables and popularity on an annual basis
subset_cor_by_year <- spotify_songs %>%
  group_by(year) %>% 
  summarise(acousticness=cor(acousticness, popularity, use="complete.obs"),
            danceability=cor(danceability, popularity, use="complete.obs"),
            energy=cor(energy, popularity, use="complete.obs"),
            instrumentalness=cor(instrumentalness, popularity, use="complete.obs"),
            liveness=cor(liveness, popularity, use="complete.obs"),
            speechiness=cor(speechiness, popularity, use="complete.obs"),
            valence=cor(valence, popularity, use="complete.obs")
  )

# Complete.obs essentially does na.rm for cor(). Based on info from:
# https://stackoverflow.com/questions/31412514/na-values-not-being-excluded-in-cor


# Create a data visualization (as seen in the presentation & in appendix E) of
# the correlations between a selection of variables and popularity, by year.
subset_cor_by_year %>% 
  pivot_longer(acousticness:valence, names_to = "variable", values_to = "cor") %>% 
  ggplot(aes(x=year, y=cor, color=variable))+
  geom_line(size=1)+
  labs(title = "Correlation of selected variables to popularity by year")
# pivot_longer() converts cor_by_year into one row per cor value per year
# rather than one row per year for all cor values. This makes the graph creation
# far simpler because I can then simply have ggplot show different color lines
# for each variable's cor with popularity. Based on info from:
# https://cameronpatrick.com/post/2019/11/plotting-multiple-variables-ggplot2-tidyr/


# Now the same graph but limited to the last five years of the dataset.
subset_cor_by_year %>% 
  pivot_longer(acousticness:valence, names_to = "variable", values_to = "cor") %>% 
  filter(year>2014) %>% 
  ggplot(aes(x=year, y=cor, color=variable))+
  geom_line(size=1)+
  labs(title = "Correlation of selected variables to popularity by year (2015-2020)")



############ Isabella McGlone's Contribution ##############
# Further exploration of correlations

# Liveness (slight negative cor w/ popularity)
spotify_songs %>% 
  ggplot(aes(x=liveness)) + geom_histogram()
spotify_songs %>% 
  ggplot(aes(x=liveness)) + geom_boxplot()
summary(spotify$liveness)
# Liveness is right skewed
# A high percent of the data could be considered outliers, 
# 1.5*IQR rule may not suffice
# Things to consider: 
# Liveness for a particular artist might be more popular than liveness for others

# Find corr of liveliness w other variables:
cor(select_if(spotify_songs, is.numeric), spotify_songs$liveness)
# Liveness/speechiness: 0.140916397

# There may be particular "artists" who are actually comics/podcasts/entertainers/etc
# whose "speechiness"is more valuable than others.
# Listeners may want certain iconic audios memorialized by a Spotify recording.

# Liveness/danceability: -0.112599069
# Liveness/energy: 0.135625587
# Energetic songs correlate with popularity and liveness correlates with energy.


# Interactive regression model for popularity over liveness interacting with energy
lm1 <- lm(liveness~popularity*energy, spotify)
lm1_points <- get_regression_points(lm1)

# Tempo analysis (slight positive cor w/ popularity)
spotify_songs %>% 
  ggplot(aes(x=tempo)) + geom_histogram()
# Data points with no tempo may be an outlier

spotify_songs %>% 
  ggplot(aes(x=tempo)) + geom_boxplot()
summary(spotify_songs$tempo)

cor(select_if(spotify_songs, is.numeric), spotify_songs$tempo)
# Tempo/acousticnes: -0.208052846

# Tempo/energy: 0.250470374
# Energetic songs are popular and songs with high tempos correlate to songs with high energy.
# Tempo/ loudness: 0.211087119
# Loud songs are popular and songs with high tempos correlate to loud songs. 
# Tempo/valence: 0.174105329
# Tempo/year: 0.136930175
# Songs have gotten faster over time. People like to listen to modern music. 


# Mutates so that acoustbool shows whether or not a song is acoustic
spotify_songs <- spotify_songs %>% 
  mutate(acoustbool= ifelse(acousticness>.5, TRUE,FALSE))

# Visualization of popularity over valence grouped by acoustic or not
spotify_songs %>% 
  ggplot(aes(x = valence, y  = popularity, color = acoustbool)) + geom_point(a=.3)

# New dataset of just non acoustic songs
noAcoust <- spotify_songs %>% 
  filter(acoustbool == FALSE)

accoustOnly <- spotify_songs %>% 
  filter(acoustbool == TRUE)

cor(select_if(noAcoust, is.numeric), noAcoust$popularity)
cor(select_if(accoustOnly, is.numeric), accoustOnly$popularity)
# Did not find any notable differences between variable correlations when grouped by acoustic or not
