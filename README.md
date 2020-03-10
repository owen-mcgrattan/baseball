# baseball

Some baseball research and related work.


- Katoh:  A minor league WAR/162 projection model for position players.  Built on XGBoost with non-lower level minor league data from 2006-2016.  Predictions csv is for position players from the 2019 season.  

- hit_predicting: Predicting extra base hits from exit velocity, launch angle, batter stance, and spray angle.  Wrote about the results [here](https://medium.com/@owenmcgrattan/an-attempt-at-understanding-pitcher-ability-in-limiting-extra-base-hits-a1b79c94b9ed)

- swstr_predict: Predicting swinging strike rates for given pitches. Trying to loosely answer what we can figure out from "stuff" alone.  Wrote more about it [here](https://medium.com/@owenmcgrattan/predicting-offspeed-swstr-off-stuff-alone-7f4c597968be)

- swstr_neural_net:  Gathering some familiarity with the nnet package in trying to predict individual swinging strikes

- PitcherSimilarity.ipynb:  Simple notebook going through and creating a pitcher similarity function (Euclidian Distance) that returns the N most similar pitches for that given pitcher.  For example, (Josh Hader, FF) would return the 5 4-seam fastballs that are most similar to Josh Hader's.