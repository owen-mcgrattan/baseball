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
leaders_19 <- read_csv("trend_leaders_19.csv")
leaders_19 <- select(leaders_19, -'X1')
leaders_19[,2:length(leaders_19)] <- round(leaders_19[,2:length(leaders_19)], 3)

pitch_20 <- read_csv('savant_shiny_20.csv')
pitch_20 <- pitch_20[!duplicated(as.list(pitch_20))]
leaders_20 <- read_csv('trend_leaders_20.csv')
leaders_20 <- select(leaders_20, -'X1')
leaders_20[,2:length(leaders_20)] <- round(leaders_20[,2:length(leaders_20)], 3)



# append 2020 data 
pitch <- rbind(pitch, pitch_20)


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
            p("A Simple Dashboard to look back at 2019-20 Batter performance and trends throughout the year"),
            p("IMPORTANT: Rolling Attack Angle here is computed as the avg launch angle of 8 hardest hit balls in 30 bbe window"),
            p('The trend statistics in the table are done as (running metric - season avg)'),
            p("All data via BaseballSavant"),
            p("Last updated 3/21/21")
     ),
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
     position = 'left',
    sidebarPanel( selectInput(inputId = "player_name", label = strong("Batter"),
                 choices = unique(batted$player_name),
                 selected = "Mike Trout"),
     selectInput(inputId = 'game_year', label = 'Year',
                 choices = unique(batted$game_year),
                 selected = 2019),
    selectInput(inputId = 'metric', label = 'Metric',
                choices = c('Exit Velocity', 'xwoba'),
                selected = 'Exit Velocity')),
  # Show multiple plots
      mainPanel(
         fluidRow(
           column(12, splitLayout(cellWidths = c("100%", "75%"),  plotOutput("plot1"), DT::dataTableOutput("view"))),
           column(10, splitLayout(cellWidths = c("100%", "90%"), plotOutput("plot2"), plotOutput("plot3")))
           
           
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
    player <- filter(batted, player_name == input$player_name, game_year == input$game_year, !is.na(launch_speed), !is.na(launch_angle))
    
    rolling_attack <- rollify(.f = compute_attack, window = 30)
    player$rolling_attack <- rolling_attack(player$launch_speed, player$launch_angle)
    player$roll_launch <- rollmeanr(player$launch_angle, k = 30, fill = NA)
    player$roll_woba <- rollmeanr(player$woba_value, k = 30, fill = NA)
    player$roll_xwoba <- rollapplyr(player$xwoba, width = 30, FUN = mean, na.rm = T, fill = NA)
    player$roll_exit <- rollmeanr(player$launch_speed, k = 30, fill = NA)
    player$count <- 1:nrow(player)
    player
  })
  
  # leader <- reactive({
  #   
  # })
  output$plot1 <- renderPlot({
    colors <- c("Attack Angle" = "blue", "Launch Angle" = "black")
    ggplot(select_dat()) + geom_smooth(aes(x = count, y = rolling_attack, color = 'Attack Angle')) + 
      geom_smooth(aes(x = count, y = roll_launch, color = 'Launch Angle')) + 
      labs(x = 'Batted Ball #', y = 'Angle', title = '30 BBE Rolling Attack/Launch Angle', color = 'Legend') + 
      scale_color_manual(values = colors)
  })
  
  
  # for plot #2 just an if statement to determine which league avg to grab
  state <- reactiveValues()
  observe({
    state$x <- input$metric
    state$y <- ifelse(state$x == 'Exit Velocity', 'launch_speed', 'xwoba')
    state$z <- ifelse(state$x == 'Exit Velocity', 'roll_exit', 'roll_xwoba')
    
  })
  
  output$plot2 <- renderPlot({
    ggplot(select_dat()) + geom_line(aes_string(x = 'count', y = state$z), na.rm = T) +
      geom_hline(data = batted, yintercept = mean(batted[[state$y]], na.rm = T), linetype = 'dotted') + 
      labs(x = 'Batted Ball #', y = input$metric, title = paste('30 BBE Rolling', input$metric, sep = ' '))
    
  })
  
  output$plot3 <- renderPlot({
    colorz <- c("Player" = "blue", "League" = "black")
    ggplot(batted) + geom_density(aes(launch_speed, color = 'League'), linetype = 'dashed') + 
      geom_density(data = select_dat(), aes(launch_speed, color = 'Player')) + 
      labs(x = 'Exit Velocity') + scale_color_manual(values = colorz)
  })
  
  output$view <- DT::renderDataTable({
    if (input$game_year == 2019) {
      leaders_19
    } else {
      leaders_20
    }
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)



