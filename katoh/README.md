#### Minor League position player WAR/162 projections

I was recently reading some of the old KATOH (credit [Chris Mitchell](https://tht.fangraphs.com/katoh-forecasting-a-hitters-major-league-performance-with-minor-league-stats/)) projection articles on FanGraphs and forgot how much I had missed it as a fan!  There is no shortage of prospect coverage from scouts but I wanted something more of a stats only perspective.  Keep in mind this is only for POSITION PLAYERS, building something for pitchers will take a little more time and require much more comprehensive data.  

So I decided to put together a little something projecting a minor league player's WAR per 162 games.  I decided on WAR/162 because I didn't have much interest in recreating the overall summed war projection for players before age 28 like KATOH used to do or even the summed war projection over the first six years. However the major league data and players I'm using are for players in 2006-2019 through the age 28 season. I train on minor league data from the 2007-2015 seasons to prevent any overlap with minor league seasons that may apply to younger prospects today.  I started at 2007 because I wanted to use batted ball data but ended up leaving out most of it in the end.   Low level (R, -A) minor league data was also noisy and I had left that out as well.    

The predictions in katoh_pred_19.csv are from 2019 data alone.

What's here is messy but a decent first step.  For future iterations including positions as well as building something for pitchers would be beneficial.


All data via [FanGraphs](https://www.fangraphs.com)