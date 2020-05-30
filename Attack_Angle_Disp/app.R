#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
library(readr)
library(dplyr)
library(tibbletime)
library(zoo)

# read in data
pitch <- read_csv("savant_shiny_2019.csv")
fg_split <- read_csv("splits_2019.csv")

batted <- filter(pitch, !(is.na(barrel)), description != "foul", !(is.na(bb_type)))
names <- batted %>% 
  group_by(game_year, player_name) %>%
  summarise(bb_events = n()) %>%
  filter(bb_events >= 50)
batted <- batted %>% filter(player_name %in% unique(names$player_name))
# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Rolling Attack/Launch Angle (min 50 BBE)"),
   
   fluidRow(
     column(12,
            p("A Simple Dashboard to look back at 2019 Batter performance and trends throughout the year"),
            p("IMPORTANT: Rolling Attack Angle here is computed as the avg launch angle of 8 hardest hit balls in 30 bbe window"),
            p("All data via BaseballSavant and FanGraphs")
     ),
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
     selectInput(inputId = "player_name", label = strong("Batter"),
                 choices = unique(batted$player_name),
                 selected = "Mike Trout"),
      
      # Show multiple plots
      mainPanel(
         fluidRow(
           column(12, splitLayout(cellWidths = c("100%", "50%"), plotOutput("plot1"), tableOutput("view"))),
           column(10, splitLayout(cellWidths = c("100%", "100%"), plotOutput("plot2"), plotOutput("plot3")))
           
         )
      )
   )
)
)
# Define server logic required to draw a histogram
server <- function(input, output) {
   
  # define a rolling attack angle variable
  compute_attack <- function(x, x2) {
    # take 8 hardest hit balls and compute avg launch angle
    df <- data.frame(launch_speed = x, 
                     launch_angle = x2)
    z <- df[order(-df$launch_speed),]
    return(mean(z$launch_angle[1:8]))
  }
  
  select_dat <- reactive({
    player <- filter(batted, player_name == input$player_name, !is.na(launch_speed), !is.na(launch_angle))
    
    rolling_attack <- rollify(.f = compute_attack, window = 30)
    player$rolling_attack <- rolling_attack(player$launch_speed, player$launch_angle)
    player$roll_launch <- rollmean(player$launch_angle, k = 30, fill = NA)
    player$roll_woba <- rollmean(player$woba_value, k = 30, fill = NA)
    player$roll_exit <- rollmean(player$launch_speed, k = 30, fill = NA)
    player$count <- 1:nrow(player)
    player
  })
  
  fg <- reactive({
    tab_split <- filter(fg_split, Name == input$player_name) %>% 
      select(-c(Season, wRC, wRAA, `BB/K`,OPS,  playerId))
    tab_split
  })
  output$plot1 <- renderPlot({
    colors <- c("Attack Angle" = "blue", "Launch Angle" = "black")
    ggplot(select_dat()) + geom_smooth(aes(x = count, y = rolling_attack, color = 'Attack Angle')) + 
      geom_smooth(aes(x = count, y = roll_launch, color = 'Launch Angle')) + 
      labs(x = 'Batted Ball #', y = 'Angle', title = '30 BBE Rolling Attack/Launch Angle (2019 Season)', color = 'Legend') + 
      scale_color_manual(values = colors)
  })
  
  output$plot2 <- renderPlot({
    ggplot(select_dat()) + geom_line(aes(x = count, y = roll_exit)) +
      geom_hline(yintercept = mean(batted$launch_speed), linetype = 'dotted') + 
      labs(x = 'Batted Ball #', y = 'Exit Velocity', title = '30 BBE Rolling Exit Velocity')
    
  })
  
  output$plot3 <- renderPlot({
    colorz <- c("Player" = "blue", "League" = "black")
    ggplot(batted) + geom_density(aes(launch_speed, color = 'League'), linetype = 'dashed') + 
      geom_density(data = select_dat(), aes(launch_speed, color = 'Player')) + 
      labs(x = 'Exit Velocity') + scale_color_manual(values = colorz)
  })
  
  output$view <- renderTable({
    head(fg(), n = 10)
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

