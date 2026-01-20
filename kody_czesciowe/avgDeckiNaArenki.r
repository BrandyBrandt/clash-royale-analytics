library(tidyverse)
library(jsonlite)

# funkcja do wyciągania poprawnej nazwy areny
extract_arena_name <- function(arena) {
  match <- regexpr("'name':\\s*['\"]([^'\"]+?)['\"]", arena, perl = TRUE)
  if (match > 0) {
    extracted <- regmatches(arena, match)
    extracted <- sub("'name':\\s*['\"]", "", extracted)
    extracted <- sub("['\"]$", "", extracted)
    return(extracted)
  } else {
    return(NA)
  }
}

correct_arena_names <- c(
  "Miner" = "Miner's Mine",
  "P.E.K.K.A" = "P.E.K.K.A's Playhouse",
  "Builder" = "Builder's Workshop",
  "Rascal" = "Rascal's Hideout"
)

# funkcja do ekstrakcji i obliczania średniego kosztu eliksiru
extract_average_deck_cost <- function(deck_column) {
  fixed_json <- gsub("'", "\"", deck_column)
  deck_list <- tryCatch(
    fromJSON(fixed_json, simplifyVector = FALSE), 
    error = function(e) {
      warning(paste("Błąd parsowania JSON:", fixed_json))
      return(NULL)
    }
  )
  
  if (!is.null(deck_list) && is.list(deck_list)) {
    elixir_costs <- sapply(deck_list, function(card) {
      if (!is.null(card$elixirCost)) {
        card$elixirCost
      } else {
        NA
      }
    })
    return(mean(elixir_costs, na.rm = TRUE))
  } else {
    return(NA)
  }
}

# funkcja przetwarzajaca dane gracza
process_player_data <- function(dataset) {
  dataset %>%
    mutate(
      average_deck_cost = sapply(currentDeck, extract_average_deck_cost),
      arena_name = sapply(arena, function(arena) {
        arena_extracted <- extract_arena_name(arena)
        if (!is.na(arena_extracted) && arena_extracted %in% names(correct_arena_names)) {
          correct_arena_names[[arena_extracted]]
        } else {
          arena_extracted
        }
      })
    ) %>%
    select(player_name = name, date, arena_name, average_deck_cost) %>%
    filter(!is.na(average_deck_cost))
}

# Kolejność aren
arena_order <- c(
  "Training Camp",
  "Goblin Stadium",
  "Bone Pit",
  "Barbarian Bowl",
  "P.E.K.K.A's Playhouse",
  "Spell Valley",
  "Builder's Workshop",
  "Royal Arena",
  "Frozen Peak",
  "Jungle Arena",
  "Hog Mountain",
  "Electro Valley",
  "Spooky Town",
  "Rascal's Hideout",
  "Serenity Peak",
  "Miner's Mine",
  "Executioner's Kitchen",
  "Royal Crypt",
  "Silent Sanctuary",
  "Dragon Spa",
  "Boot Camp",
  "Clash Fest",
  "Legendary Arena"
)

deckiBrandona <- process_player_data(brandt)
deckiMatiego <- process_player_data(mati)
deckiKarola <- process_player_data(karol)

# funkcja tworzaca wykres dla gracza
plot_arena_summary <- function(player_data, player_name) {
  arena_summary <- player_data %>%
    group_by(arena_name) %>%
    summarise(avg_deck_cost = mean(average_deck_cost, na.rm = TRUE)) %>%
    mutate(arena_name = factor(arena_name, levels = arena_order)) %>%
    arrange(arena_name)
  
  ggplot(arena_summary, aes(x = arena_name, y = avg_deck_cost)) +
    geom_bar(stat = "identity", fill = "steelblue") +
    geom_text(aes(label = round(avg_deck_cost, 2)), 
              hjust = -0.1, size = 4, fontface = "bold") +  # Pogrubione liczby z prawej
    geom_hline(yintercept = mean(arena_summary$avg_deck_cost, na.rm = TRUE), 
               color = "red", linetype = "dashed") +
    coord_flip() +
    labs(
      title = paste("Średni koszt decku dla każdej areny -", player_name),
      x = "Nazwa areny",
      y = "Średni koszt decku"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 16, face = "bold"),
      axis.title = element_text(size = 12, face = "bold"),
      axis.text = element_text(size = 10)
    )
}


plot_arena_summary(deckiBrandona, "Brandt")
plot_arena_summary(deckiMatiego, "Mati")
plot_arena_summary(deckiKarola, "Karol")


combined_data_yet_again <- bind_rows(
  deckiBrandona %>% mutate(player = "Brandon"),
  deckiMatiego %>% mutate(player = "Mati"),
  deckiKarola %>% mutate(player = "Karol")
)

arena_summary_combined_yet_again <- combined_data_yet_again %>%
  group_by(player, arena_name) %>%
  summarise(avg_deck_cost = mean(average_deck_cost, na.rm = TRUE)) %>%
  mutate(arena_name = factor(arena_name, levels = arena_order)) %>%
  arrange(arena_name)

ggplot(arena_summary_combined_yet_again, aes(x = arena_name, y = avg_deck_cost, fill = player)) +
  geom_bar(stat = "identity", position = position_dodge(width = 0.8)) +
  geom_text(aes(label = round(avg_deck_cost, 2)), 
            position = position_dodge(width = 0.8), 
            vjust = -0.5, size = 4, fontface = "bold") +  # Napisy nad słupkami
  coord_flip() +
  labs(
    title = "Średni koszt decku dla każdej areny - porównanie graczy",
    x = "Nazwa areny",
    y = "Średni koszt decku",
    fill = "Gracz"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold"),
    axis.title = element_text(size = 12, face = "bold"),
    axis.text = element_text(size = 10),
    legend.title = element_text(size = 12, face = "bold"),
    legend.text = element_text(size = 10)
  )
