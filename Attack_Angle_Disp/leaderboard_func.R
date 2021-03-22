
gen_leaderboard <- function(x) {


batted <- filter(x, #!(is.na(barrel)), description != "foul", !(is.na(bb_type)))
                 !is.na(woba_value))
names <- batted %>% 
  group_by(game_year, player_name) %>%
  summarise(bb_events = n()) %>%
  filter(bb_events >= 50)
batted <- batted %>% filter(player_name %in% unique(names$player_name))



# define a rolling attack angle variable
compute_attack <- function(x, x2) {
  # take 8 hardest hit balls and compute avg launch angle
  df <- data.frame(launch_speed = x, 
                   launch_angle = x2)
  z <- df[order(-df$launch_speed),]
  return(mean(z$launch_angle[1:8]))
}



# create data frame
len <- length(unique(batted$player_name))
leaders_20 <- data.frame(Name = character(len),
                         launch = double(len),
                         attack = double(len),
                         exit = double(len),
                         xwoba = double(len),
                         launch_trend = double(len),
                         attack_trend = double(len),
                         exit_trend = double(len),
                         xwoba_trend = double(len),
                         pa = double(len))
leaders_20$Name <- as.character(leaders_20$Name)


for (i in 1:length(unique(batted$player_name))) {
  player <- filter(batted, player_name == unique(batted$player_name)[i],
                   #!is.na(launch_speed), !is.na(launch_angle))
                   !is.na(woba_value))
  
  # make sure our xwoba metric is correct
  player$xwoba <- ifelse(is.na(player$xwoba), player$woba_value, player$xwoba)
  
  rolling_attack <- rollify(.f = compute_attack, window = 30)
  player$rolling_attack <- rolling_attack(player$launch_speed, player$launch_angle)
  player$roll_launch <- rollapplyr(player$launch_angle, width = 30, FUN = mean, na.rm = T, fill = NA)
  player$roll_woba <- rollmeanr(player$woba_value, k = 30, fill = NA)
  player$roll_xwoba <- rollapplyr(player$xwoba, width = 30, FUN = mean, na.rm = T, fill = NA)
  player$roll_exit <- rollapplyr(player$launch_speed, width = 30, FUN = mean, na.rm = T, fill = NA)
  player$pa <- 1:nrow(player)
  
  leaders_20$Name[i] <- unique(batted$player_name)[i]
  leaders_20$launch[i] <- mean(player$launch_angle, na.rm = T)
  leaders_20$attack[i] <- mean(player$roll_launch, na.rm = T)
  leaders_20$exit[i] <- mean(player$roll_exit, na.rm = T)
  leaders_20$xwoba[i] <- mean(player$xwoba, na.rm = T)
  
  
  leaders_20$launch_trend[i] <- player$roll_launch[nrow(player)] - leaders_20$launch[i] 
  leaders_20$attack_trend[i] <- player$rolling_attack[nrow(player)] - leaders_20$attack[i]  
  leaders_20$exit_trend[i] <- player$roll_exit[nrow(player)] - leaders_20$exit[i] 
  leaders_20$xwoba_trend[i] <- player$roll_xwoba[nrow(player)] - leaders_20$xwoba[i] 
  leaders_20$pa[i] <- nrow(player)
  
}

return(leaders_20)

}