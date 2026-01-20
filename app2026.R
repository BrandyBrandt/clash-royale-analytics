library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(stringr)
library(tidyverse)
library(jsonlite)
library(shinythemes)
library(showtext)
font_add_google(name = "Roboto", family = "Roboto")
showtext_auto()

################################################ DATA LOADING #################################

get_empty_structure <- function() {
  data.frame(
    battleCount = numeric(),
    trophies = numeric(),
    currentDeck = character(),
    arena = character(),
    wins = numeric(),
    losses = numeric(),
    threeCrownWins = numeric(),
    name = character(),
    date = character(),
    player_tag = character(),
    stringsAsFactors = FALSE
  )
}

safe_read_csv <- function(file_path) {
  required_cols <- c("battleCount", "arena")
  
  if (!file.exists(file_path)) {
    warning(paste("Plik nie istnieje:", file_path))
    return(get_empty_structure())
  }
  
  try1 <- tryCatch({
    df <- read.csv(file_path, sep=",", stringsAsFactors = FALSE)
    if (all(required_cols %in% names(df))) df else NULL
  }, error = function(e) NULL)
  
  if (!is.null(try1)) return(try1)
  
  return(get_empty_structure())
}

karol <- safe_read_csv("data_k.csv")
mati <- safe_read_csv("data_j.csv")
brandt <- safe_read_csv("data_b.csv")

input_data<-"
Hog Rider	Rare	4
Little Prince	Champion	3
Lava Hound	Legendary	7
Bomber	Common	3
Fireball	Rare	4
Cannon	Common	3
Mega Knight	Legendary	7
The Log	Legendary	2
Goblin Curse	Epic	2
Mighty Miner	Champion	4
Royal Ghost	Legendary	3
Phoenix	Legendary	4
Monk	Champion	5
Valkyrie	Rare	4
Goblin Machine	Legendary	5
Skeleton King	Champion	4
Ice Spirit	Common	1
Archer Queen	Champion	5
Barbarian Launcher	Common	5
Earthquake	Rare	3
Poison	Epic	4
Tornado	Epic	3
P.E.K.K.A.	Epic	7
Mini P.E.K.K.A	Rare	4
Lumberjack	Legendary	4
Party Hat	Legendary	5
Zap	Common	2
Wizard	Rare	5
Giant Snowball	Common	2
Night Witch	Legendary	4
Party Rocket	Legendary	5
Mega Minion	Rare	3
Balloon	Epic	5
Fire Spirit	Common	2
Mini P.E.K.K.A.	Rare	4
Electro Wizard	Legendary	4
Goblinstein	Champion	2
Executioner	Epic	5
Minion Horde	Common	5
Firecracker	Common	3
Ram Rider	Legendary	5
Bandit	Legendary	3
Magic Archer	Legendary	4
Furnace	Rare	4
Fisherman	Legendary	3
Hunter	Epic	4
Knight	Common	3
Goblin Giant	Epic	6
Ice Golem	Rare	2
Royal Giant	Common	6
Arrows	Common	3
Witch	Epic	5
Goblin Drill	Epic	4
Goblin Barrel	Epic	3
Barbarian Barrel	Epic	2
Sparky	Legendary	4
Skeleton Dragons	Common	4
Skeletons	Common	1
Goblin Gang	Common	3
Dark Prince	Epic	4
Royal Delivery	Common	3
Royal Hogs	Rare	5
Goblin Demolisher	Rare	4
Inferno Tower	Rare	5
Rascals	Common	5
Mortar	Common	4
Rocket	Rare	6
Tesla	Common	4
Lightning	Epic	6
Baby Dragon	Epic	4
Musketeer	Rare	4
Ice Wizard	Legendary	3
Miner	Legendary	3
Skeleton Army	Epic	3
Prince	Epic	5
Electro Dragon	Epic	5
Snowball	Common	2
Xbow	Epic	6
Golem	Epic	8
Goblins	Common	2
Battle Ram	Rare	4
Graveyard	Legendary	5
Mother Witch	Legendary	4
Bomb Tower	Rare	4
Guards	Epic	3
Freeze	Epic	4
Elixir Golem	Rare	3
Royal Hogs	Rare	5
Rage	Epic	2
Canon	Common	3
Canon Cart	Epic	5
Inferno Dragon	Legendary	4
Tombstone	Rare	3
Giant Skeleton	Epic	6
Spear Goblins	Common	2
Minions	Common	3
Bats	Common	2
Clone	Epic	3
Skeleton Barrel	Common	3
Electro Giant	Epic	8
Giant	Rare	5
Bowler	Epic	5
Princess	Legendary	3
Zappies	Rare	4
Goblin Hut	Rare	4
Barbarians	Common	5
Elixir Collector	Rare	6
Barbarian Hut	Rare	7
Royal Recruits	Common	7
Golden Knight	Champion	4
Electro Spirit	Common	1
Three Musketeers	Rare	9
Heal Spirit	Rare	1
Dart Goblin	Rare	3
Mother Witch	Legendary	4
Battle Healer	Rare	4
Goblin Cage	Rare	4
Flying Machine	Rare	4
Elite Barbarians	Common	6
Electro Spirit	Common	1
Electro Giant	Epic	7
Mirror	Epic	0
Archers	Common	2
X-Bow	Epic	7
Wall Breakers	Epic	2"

library(data.table)
nazwy <- tryCatch({
  fread(text = input_data, header = FALSE, col.names = c("deck_cards", "rarity", "cost"))
}, error = function(e) data.frame(deck_cards=character(), rarity=character(), cost=numeric()))

correct_arena_names <- c(
  "Miner" = "Miner's Mine",
  "P.E.K.K.A" = "P.E.K.K.A's Playhouse",
  "Builder" = "Builder's Workshop",
  "Rascal" = "Rascal's Hideout"
)
arena_order <- c(
  "Training Camp", "Goblin Stadium", "Bone Pit", "Barbarian Bowl", "Spell Valley",
  "Builder's Workshop", "P.E.K.K.A's Playhouse", "Royal Arena", "Frozen Peak",
  "Jungle Arena", "Hog Mountain", "Electro Valley", "Spooky Town",
  "Rascal's Hideout", "Serenity Peak", "Miner's Mine", "Executioner's Kitchen",
  "Royal Crypt", "Silent Sanctuary", "Dragon Spa", "Boot Camp", "Clash Fest",
  "Legendary Arena"
)

################################################ HELPERS #######################################

smart_extract_arena_name <- function(arena_str) {
  if (length(arena_str) == 0 || is.na(arena_str) || arena_str == "") return(NA_character_)
  
  match <- regexpr("'name':\\s*['\"]([^'\"]+?)['\"]", arena_str, perl = TRUE)
  if (match > 0) {
    extracted <- regmatches(arena_str, match)
    extracted <- sub("'name':\\s*['\"]", "", extracted)
    extracted <- sub("['\"]$", "", extracted)
    return(as.character(extracted))
  }
  
  try_json <- tryCatch({
    fixed_json <- gsub("'", "\"", arena_str)
    parsed <- fromJSON(fixed_json, simplifyVector = FALSE)
    if (!is.null(parsed$name)) return(as.character(parsed$name))
    NULL
  }, error = function(e) NULL)
  
  if (!is.null(try_json)) return(try_json)
  return(NA_character_)
}

safe_arena_name_replacement <- function(arena_name) {
  if (is.na(arena_name) || arena_name == "") return(NA_character_)
  if (arena_name %in% names(correct_arena_names)) {
    return(as.character(unname(correct_arena_names[arena_name])))
  }
  return(as.character(arena_name))
}

extract_average_deck_cost <- function(deck_column) {
  if (length(deck_column) == 0 || is.na(deck_column) || deck_column == "") return(NA_real_)
  fixed_json <- gsub("'", "\"", deck_column)
  
  deck_list <- tryCatch(fromJSON(fixed_json, simplifyVector = FALSE), error = function(e) NULL)
  
  if (!is.null(deck_list) && is.list(deck_list) && length(deck_list) > 0) {
    costs <- sapply(deck_list, function(c) if(!is.null(c$elixirCost)) as.numeric(c$elixirCost) else NA_real_)
    return(mean(costs, na.rm = TRUE))
  }
  return(NA_real_)
}

extract_deck <- function(deck_column) {
  if (length(deck_column) == 0 || is.na(deck_column) || deck_column == "") return(NA_character_)
  fixed_json <- gsub("'", "\"", deck_column)
  deck_list <- tryCatch(fromJSON(fixed_json, simplifyVector = FALSE), error = function(e) NULL)
  if (!is.null(deck_list) && is.list(deck_list) && length(deck_list) > 0) {
    res <- sapply(deck_list, function(c) if(!is.null(c$name)) as.character(c$name) else NA_character_)
    return(res)
  } else {
    return(NA_character_)
  }
}

################################################ PROCESSING ###################################

process_player_data <- function(dataset) {
  if (nrow(dataset) == 0) return(data.frame())
  if (!all(c("currentDeck", "arena", "name", "date") %in% names(dataset))) return(data.frame())
  
  dataset %>%
    mutate(
      average_deck_cost = sapply(currentDeck, extract_average_deck_cost),
      arena_name = sapply(arena, function(a) {
        val <- smart_extract_arena_name(a)
        safe_arena_name_replacement(val)
      })
    ) %>%
    select(player_name = name, date, arena_name, average_deck_cost) %>%
    filter(!is.na(average_deck_cost))
}


cards_frequency <- function(player_data) {
  if (nrow(player_data) == 0) return(data.frame(deck_cards=character(), count=numeric(), image=character()))
  if (!"currentDeck" %in% names(player_data)) return(data.frame(deck_cards=character(), count=numeric(), image=character()))
  
  result <- tryCatch({
    player_data %>%
      mutate(deck_cards = lapply(currentDeck, extract_deck)) %>%
      unnest(deck_cards) %>%
      filter(!is.na(deck_cards)) %>%
      group_by(deck_cards) %>%
      summarise(count = n(), .groups = "drop") %>%
      mutate(image=paste0("cards/", tolower(gsub(" ", "_", deck_cards)), ".png")) %>%  # POPRAWKA!
      arrange(desc(count))
  }, error = function(e) {
    return(data.frame(deck_cards=character(), count=numeric(), image=character()))
  })
  
  return(result)
}

plot_arena_summary <- function(player_data, player_name) {
  if (nrow(player_data) < 1) return(ggplot() + theme_void())
  if (!"arena_name" %in% names(player_data)) return(ggplot() + theme_void())
  
  arena_summary <- player_data %>%
    filter(!is.na(arena_name)) %>%
    group_by(arena_name) %>%
    summarise(avg_deck_cost = mean(average_deck_cost, na.rm = TRUE)) %>%
    ungroup() %>%
    mutate(arena_name = factor(arena_name, levels = arena_order)) %>%
    filter(!is.na(arena_name)) %>%
    arrange(arena_name)
  
  if (nrow(arena_summary) == 0) return(ggplot() + theme_void())
  
  arena_summary <- arena_summary %>%
    mutate(
      label_pos = -round(avg_deck_cost, 2) + 0.32,
      label_txt = format(round(avg_deck_cost, 1), 1)
    )
  
  ggplot(arena_summary, aes(x = arena_name, y = avg_deck_cost)) +
    geom_bar(stat = "identity", fill = "#ab0eb4") +
    geom_text(aes(label = label_txt, y = label_pos), 
              size = 4, fontface = "bold", color="white") +
    geom_hline(yintercept = mean(arena_summary$avg_deck_cost, na.rm = TRUE), 
               color = "#760089", linetype = "dashed") +
    coord_flip() +
    labs(x = "", y = "Średni koszt decku") +
    theme_minimal() +
    theme(
      panel.grid.major = element_blank(), 
      panel.grid.minor = element_blank(),
      plot.title = element_text(size = 16, face = "bold"),
      axis.title = element_text(size = 14, face = "bold", family= "Arial Black"),
      axis.text = element_text(size = 10)
    )
}


process_data <- function(data) {
  if (nrow(data) == 0) return(data.frame())
  if (!all(c("player_tag", "date", "arena", "losses", "wins", "threeCrownWins") %in% names(data))) return(data.frame())
  
  result <- tryCatch({
    data_sorted <- data %>% arrange(player_tag, date)
    
    data_with_changes <- data_sorted %>%
      group_by(player_tag) %>%
      mutate(
        arena_change = arena != lead(arena, default = last(arena)), 
        next_losses = lead(losses),  
        next_threeCrownWins = lead(threeCrownWins), 
        next_wins = lead(wins),  
        is_last_arena = row_number() == n() 
      ) %>%
      ungroup()
    
    arena_summary_data <- data_with_changes %>%
      filter(arena_change == TRUE | is_last_arena == TRUE) 
    
    if (nrow(arena_summary_data) == 0) return(data.frame())
    
    arena_summary_data %>%
      mutate(
        losses_battles = ifelse(is_last_arena, losses, next_losses),
        threeCrownWins_battles = ifelse(is_last_arena, threeCrownWins, next_threeCrownWins),
        wins_battles = ifelse(is_last_arena, wins, next_wins)
      ) %>%
      select(player_tag, arena, losses_battles, threeCrownWins_battles, wins_battles) %>% 
      distinct(player_tag, arena, losses_battles, threeCrownWins_battles, wins_battles) %>%
      group_by(player_tag) %>%
      mutate(
        prev_losses = lag(losses_battles, default = 0),  
        prev_threeCrownWins = lag(threeCrownWins_battles, default = 0), 
        prev_wins = lag(wins_battles, default = 0)
      ) %>%
      ungroup() %>%
      mutate(
        losses_played = losses_battles - prev_losses, 
        threeCrownWins_played = threeCrownWins_battles - prev_threeCrownWins, 
        wins_played = wins_battles - prev_wins
      ) %>% 
      gather(key = "game_type", value = "games_played", wins_played, losses_played) %>%
      mutate(game_type = factor(game_type, levels = c("wins_played", "losses_played"),
                                labels = c("Wygrane", "Przegrane"))) %>%
      mutate(
        arena_name = sapply(arena, function(a) {
          val <- smart_extract_arena_name(a)
          safe_arena_name_replacement(val)
        })
      ) %>%
      filter(!is.na(arena_name) & arena_name != "") %>%
      mutate(arena_name = factor(arena_name, levels = arena_order))
  }, error = function(e) {
    return(data.frame())
  })
  
  return(result)
}

#####################################  UI  ################################################

safe_min <- function(x) if(length(x) > 0 && !all(is.na(x))) min(x, na.rm=TRUE) else 0
safe_max <- function(x) if(length(x) > 0 && !all(is.na(x))) max(x, na.rm=TRUE) else 100

ui1 <- fluidPage(
  titlePanel("Brandt"),
  sidebarLayout(
    fluidRow(
      sidebarPanel(
        sliderInput("b_battles", "Wybór zakresu:", 
                    min = safe_min(brandt$battleCount), max = safe_max(brandt$battleCount),
                    value = c(safe_min(brandt$battleCount), safe_max(brandt$battleCount)))
      )
    ),
    mainPanel = (
      fluidRow(
        column(h3("Wygrane vs Przegrane na każdej arenie"), plotlyOutput("brandt_win_loss"), width=6),
        column(h3("Zależność między liczbą bitew, a ilością pucharków"), plotlyOutput("brandt_trophies"), width=6),
        column(h3("Średni koszt postaci w decku na arenach"), plotlyOutput("brandt_elixir_cost"), width=6),
        column(h3("Obecność postaci w używanym decku"), plotlyOutput("brandt_deck"), width=6)
      )
    )
  )
)

ui2 <- fluidPage(
  titlePanel("Mati"),
  sidebarLayout(
    fluidRow(
      sidebarPanel(
        sliderInput("m_battles", "Wybór zakresu:",
                    min = safe_min(mati$battleCount), max = safe_max(mati$battleCount),
                    value = c(safe_min(mati$battleCount), safe_max(mati$battleCount)))
      )
    ),
    mainPanel = (
      fluidRow(
        column(h3("Wygrane vs Przegrane na każdej arenie"), plotlyOutput("mati_win_loss"), width=6),
        column(h3("Zależność między liczbą bitew, a ilością pucharków"), plotlyOutput("mati_trophies"), width=6),
        column(h3("Średni koszt postaci w decku na arenach"), plotlyOutput("mati_elixir_cost"), width=6),
        column(h3("Obecność postaci w używanym decku"), plotlyOutput("mati_deck"), width=6)
      )
    )
  )
)

ui3  <- fluidPage(
  titlePanel("Karol"),
  sidebarLayout(
    fluidRow(
      sidebarPanel(
        sliderInput("k_battles", "Wybór zakresu:",
                    min = safe_min(karol$battleCount), max = safe_max(karol$battleCount),
                    value = c(safe_min(karol$battleCount), safe_max(karol$battleCount)))
      )
    ),
    mainPanel = (
      fluidRow(
        column(h3("Wygrane vs Przegrane na każdej arenie"), plotlyOutput("karol_win_loss"), width=6),
        column(h3("Zależność między liczbą bitew, a ilością pucharków"), plotlyOutput("karol_trophies"), width=6),
        column(h3("Średni koszt postaci w decku na arenach"), plotlyOutput("karol_elixir_cost"), width=6),
        column(h3("Obecność postaci w używanym decku"), plotlyOutput("karol_deck"), width=6)
      )
    )
  )
)

ui4 <- fluidPage(
  titlePanel("Strona główna"),
  fluidRow(
    column(4, img(src = "barbarians.png", height = "200px", width = "auto"), h3("Gracz 1"), p("Nigdy nie grałam w Clash Royale, więc wszystko jest dla mnie zupełnie nowe. Nie znam ani postaci, ani kart, ani żadnych taktyk, które są używane w grze. Muszę zacząć od podstaw, ucząc się zasad i mechaniki krok po kroku.")),
    column(4, img(src = "prince.png", height = "200px", width = "auto"), h3("Gracz 2"), p("Kiedyś grałem w Clash Royale bardzo intensywnie, ale od dłuższego czasu miałem przerwę. Pamiętam niektóre postacie i strategie, ale wiele z nich pewnie się zmieniło albo zostało dodanych nowych. Teraz muszę odświeżyć swoje umiejętności i na nowo zapoznać się z mechaniką gry.")),
    column(4, img(src = "wizard.png", height = "200px", width = "auto"), h3("Gracz 3"), p(" Gram w Clash Royale od dłuższego czasu i dobrze znam większość kart oraz strategii. Regularnie grałem w klanie, zdobywałem nagrody i rywalizowałem w różnych trybach gry. Teraz rozpoczynam nową rozgrywkę, ale z doświadczeniem, które zdobyłem przez wszystkie te lata."))
  ),
  fluidRow(
    column(12, h3("Porównanie wyników graczy"), plotlyOutput("linePlot"))
  )
)

####################################################  SERVER   ######################################
server <- function(input, output) {
  
  filter_data <- function(df, range_input) {
    if (is.null(range_input) || nrow(df) == 0) return(df[0, ])
    if (!"battleCount" %in% names(df)) return(df[0, ])
    
    tryCatch({
      df %>% filter(battleCount >= range_input[1], battleCount <= range_input[2])
    }, error = function(e) {
      return(df[0, ])
    })
  }
  
  b <- reactive({ req(input$b_battles); filter_data(brandt, input$b_battles) })
  m <- reactive({ req(input$m_battles); filter_data(mati, input$m_battles) })
  k <- reactive({ req(input$k_battles); filter_data(karol, input$k_battles) })
  
  safe_render <- function(expr) {
    renderPlotly({
      tryCatch(expr, error = function(e) {
        print(paste("Błąd wykresu:", e$message))
        ggplotly(ggplot() + theme_void() + 
                   annotate("text", x=0.5, y=0.5, label="Brak danych", color="red", size=6))
      })
    })
  }
  
  plot1<- function(data){
    if(nrow(data) == 0) return(ggplotly(ggplot() + theme_void() + labs(title="Brak danych")))
    
    processed <- process_data(data)
    if(nrow(processed) == 0) return(ggplotly(ggplot() + theme_void() + labs(title="Brak danych")))
    
    ggplotly(
      ggplot(processed, aes(x = arena_name, y = games_played, fill = game_type)) +
        geom_bar(stat = "identity", position = "stack", color = "black") +
        labs(x = "", y = "Liczba gier", fill = "Rezultat") +
        scale_fill_manual(values = c("Wygrane" = "#50a0e5", "Przegrane" = "#e82733")) + 
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1),
              panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
              panel.background = element_rect(fill = "transparent", color = NA),
              plot.background = element_rect(fill = "transparent", color = NA),
              axis.title = element_text(size = 14, color = "#000000", family= "Arial Black"),
              axis.text = element_text(color="#000000")
        )
    )
  }
  
  output$brandt_win_loss <- safe_render({ plot1(b()) })
  output$mati_win_loss <- safe_render({ plot1(m()) })
  output$karol_win_loss <- safe_render({ plot1(k()) })
  
  plot2<-function(data){
    if(nrow(data) == 0) return(ggplotly(ggplot() + theme_void() + labs(title="Brak danych")))
    p <- plot_arena_summary(process_player_data(data), "Brandt")
    ggplotly(p + theme(
      panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "transparent", color = NA),
      plot.background = element_rect(fill = "transparent", color = NA),
      axis.text = element_text(size = 16, color = "#000000")
    ))
  }  
  
  output$brandt_elixir_cost <- safe_render({ plot2(b()) })
  output$mati_elixir_cost <- safe_render({ plot2(m()) })
  output$karol_elixir_cost <- safe_render({ plot2(k()) })
  
  plot3 <- function(data) {
    if(nrow(data) == 0) return(plotly_empty())
    
    encode_image <- function(path) {
      if(!file.exists(path)) return("")
      tryCatch(base64enc::dataURI(file = path), error = function(e) "")
    }
    
    data_freq <- cards_frequency(data) 
    if(nrow(data_freq) == 0) return(plotly_empty())
    
    data_freq$image_encoded <- sapply(data_freq$image, encode_image)
    data_freq <- data_freq[order(data_freq$count), ]
    
    if(nrow(nazwy) > 0 && "deck_cards" %in% names(nazwy)) {
      data_freq <- inner_join(data_freq, nazwy, by="deck_cards") %>% distinct()
    } else {
      data_freq$rarity <- "Common"
      data_freq$cost <- 0
    }
    
    if(nrow(data_freq) < 1) return(plotly_empty())
    
    data_freq$deck_cards <- factor(data_freq$deck_cards, levels = data_freq$deck_cards)
    if(!"rarity" %in% names(data_freq)) data_freq$rarity <- "Common"
    
    fig <- plot_ly(
      data_freq,
      x = ~count, y = ~deck_cards, type = "bar", orientation = "h",
      marker = list(color = case_when(
        data_freq$rarity == "Common" ~ "lightblue",
        data_freq$rarity == "Rare" ~ "orange",
        data_freq$rarity == "Epic" ~ "purple",
        TRUE ~ "pink")
      )
    )
    
    images <- lapply(seq_len(nrow(data_freq)), function(i) {
      list(
        source = if("image_encoded" %in% names(data_freq)) data_freq$image_encoded[i] else "",
        x = data_freq$count[i] - 1, y = data_freq$deck_cards[i],
        xref = "x", yref = "y", xanchor = "left", yanchor = "middle",
        sizex = 200, sizey = 1.3, layer = "above"
      )
    })
    
    fig %>% layout(
      images = images,
      xaxis = list(title = "Liczba wystąpień", titlefont = list(color = "#000000", size = 18, family = "Arial Black", weight = "bold"), tickfont = list(color = "#000000")),
      yaxis = list(title = "", titlefont = list(color = "#000000", size = 16, family = "Arial", weight = "bold"), tickfont = list(color = "#000000")),
      plot_bgcolor = "rgba(0,0,0,0)", paper_bgcolor = "rgba(0,0,0,0)"
    )
  } 
  
  output$brandt_deck <- safe_render({ plot3(b()) })
  output$mati_deck <- safe_render({ plot3(m()) })
  output$karol_deck <- safe_render({ plot3(k()) })
  
  plot4 <- function(data) {
    if(nrow(data) == 0) return(plotly_empty())
    if(!"trophies" %in% names(data)) return(plotly_empty())
    
    horizontal_lines <- c(300, 600, 1000, 1300, 1600, 2000, 2300, 2600, 3000, 3400, 3800, 4200, 4600, 5000, 5500)
    
    valid_data <- data %>% filter(!is.na(trophies) & !is.na(battleCount))
    if(nrow(valid_data) == 0) return(plotly_empty())
    
    min_t <- min(valid_data$trophies, na.rm=T)
    max_t <- max(valid_data$trophies, na.rm=T)
    
    active_lines <- horizontal_lines[horizontal_lines <= (max_t + 500) & horizontal_lines >= (min_t - 500)]
    
    p <- ggplot(data = valid_data, aes(x = battleCount, y = trophies)) +
      geom_line(color = "#efa600", size = 1) +
      labs(x = "Liczba Bitew", y = "Pucharki") +
      theme_minimal() +
      theme(
        text = element_text(family = "Roboto", color = "black"),
        axis.title = element_text(size = 14, color = "black",family="Arial Black"),
        axis.text = element_text(size = 14, color = "black"),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent", color = NA),
        plot.background = element_rect(fill = "transparent", color = NA)
      )
    
    if(length(active_lines) > 0) {
      p <- p + geom_hline(yintercept = active_lines, linetype = "dashed", color = "gray")
    }
    ggplotly(p)
  }
  
  output$brandt_trophies <- safe_render({ plot4(b()) })
  output$karol_trophies <- safe_render({ plot4(k()) })
  output$mati_trophies <- safe_render({ plot4(m()) })
  
  output$linePlot <- safe_render({
    p <- ggplot() + theme_minimal()
    
    if(nrow(karol)>0 && all(c("wins", "battleCount") %in% names(karol))) {
      p <- p + geom_line(data = karol, mapping = aes(x = battleCount, y = wins / pmax(battleCount, 1), color = "Karol"), size = 1, alpha = 0.7)
    }
    if(nrow(mati)>0 && all(c("wins", "battleCount") %in% names(mati))) {
      p <- p + geom_line(data = mati, mapping = aes(x = battleCount, y = wins / pmax(battleCount, 1), color = "Mati"), size = 1, alpha = 0.7)
    }
    if(nrow(brandt)>0 && all(c("wins", "battleCount") %in% names(brandt))) {
      p <- p + geom_line(data = brandt, mapping = aes(x = battleCount, y = wins / pmax(battleCount, 1), color = "Brandt"), size = 1, alpha = 0.7)
    }
    
    p <- p +
      scale_color_manual(values = c("Karol" = "red", "Mati" = "blue", "Brandt" = "green")) +
      labs(color = "Gracze", x = "Liczba bitew", y = "Procent wygranych") +
      scale_y_continuous(limits = c(0, 1)) +
      scale_x_continuous(limits = c(0, NA)) +
      theme(
        text = element_text(family = "Roboto", color = "black"),
        axis.title = element_text(size = 14, color = "black", face = "bold"),
        axis.text = element_text(size = 14, color = "black"),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "transparent", color = NA),
        plot.background = element_rect(fill = "transparent", color = NA)
      )
    
    ggplotly(p)
  })
}

##################################### Kolorki #################################

ui <- fluidPage(
  theme = shinytheme("cyborg"), 
  tags$head(
    tags$link(href = "https://fonts.googleapis.com/css2?family=Bangers&family=Roboto:wght@300;400;700&display=swap", rel = "stylesheet")
  ),
  tags$style(HTML("
    body { background-color: #2B4F81; color: #ffffff; font-family: 'Roboto', sans-serif; }
    .navbar-default { background-color: #f9a602; border-color: #f9a602; }
    .navbar-default .navbar-brand, .navbar-default .navbar-nav > li > a { color: #ffffff; font-family: 'Bangers', cursive; }
    .navbar-default .navbar-brand:hover, .navbar-default .navbar-nav > li > a:hover { color: #ffd700; }
    .btn-primary { background-color: #f9a602; border-color: #ffd700; font-family: 'Roboto', sans-serif; font-weight: 700; }
    .btn-primary:hover { background-color: #ffd700; border-color: #f9a602; }
    h1, h2, h3, h4, h5, h6 { color: #ffd700; font-family: 'Bangers', cursive; }
    .well { background-color: #243763; border-color: #f9a602; color: #ffffff; font-family: 'Roboto', sans-serif; }
    p, label { color: #dcdcdc; font-family: 'Roboto', sans-serif; }
  ")),
  navbarPage(
    title = "Statystyka gier Clash Royale",
    tabPanel("Strona główna", ui4),
    tabPanel("Brandt", ui1),
    tabPanel("Jamroż", ui2),
    tabPanel("Kacprzak", ui3)
  )
)

shinyApp(ui = ui, server = server)