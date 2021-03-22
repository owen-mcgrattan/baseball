# load in, clean, and save savant data for 2020
library(baseballr)
library(readr)
library(dplyr)
library(rsconnect)

setwd('/Users/owenmcgrattan/baseball/Attack_Angle_Disp')
source('leaderboard_func.R')

# load in existing 2020 savant data
pitch_20 <- read_csv('savant_shiny_20.csv')
# scrape savant data 
prev_day <- scrape_statcast_savant_batter_all(start_date = Sys.Date() - 1, end_date = Sys.Date())

# select only few columns
prev_day <- select(prev_day, "description", "barrel", "player_name", "game_year", "bb_type" ,    
                   "launch_speed", "launch_angle" , "woba_value", "estimated_woba_using_speedangle")

prev_day <- prev_day %>% rename(xwoba = estimated_woba_using_speedangle)

# change name format
f <- function(x) paste(rev(unlist(strsplit(x, ", "))), collapse = " ")
prev_day$player_name <- sapply(f, X = prev_day$player_name)

# append prev_day to our pitch_20
pitch_20 <- rbind(pitch_20, prev_day)

# save
write.csv(file = 'savant_shiny_20.csv', x = pitch_20)

deployApp(appId = 2351698)