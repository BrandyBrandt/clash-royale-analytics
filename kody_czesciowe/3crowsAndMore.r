library(ggplot2)
library(tidyr)
library(dplyr)


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



brandt_sorted_v2 <- brandt %>%
  arrange(player_tag, date)


brandt_with_changes_v2 <- brandt_sorted_v2 %>%
  group_by(player_tag) %>%
  mutate(
    arena_change = arena != lead(arena, default = last(arena)),
    next_losses = lead(losses),  
    next_threeCrownWins = lead(threeCrownWins), 
    next_wins = lead(wins),  
    is_last_arena = row_number() == n() 
  ) %>%
  ungroup()


arena_summary_brandt_v2 <- brandt_with_changes_v2 %>%
  filter(arena_change == TRUE | is_last_arena == TRUE) %>% 
  mutate(
    losses_battles = case_when( 
      is_last_arena ~ losses, 
      TRUE ~ next_losses 
    ),
    threeCrownWins_battles = case_when( 
      is_last_arena ~ threeCrownWins, 
      TRUE ~ next_threeCrownWins 
    ),
    wins_battles = case_when(  
      is_last_arena ~ wins, 
      TRUE ~ next_wins 
    )
  ) %>%
  select(player_tag, arena, losses_battles, threeCrownWins_battles, wins_battles) %>%  
  distinct(player_tag, arena, losses_battles, threeCrownWins_battles, wins_battles)


arena_summary_brandt_v2 <- arena_summary_brandt_v2 %>%
  group_by(player_tag) %>%
  mutate(
    prev_losses = lag(losses_battles, default = 0), 
    prev_threeCrownWins = lag(threeCrownWins_battles, default = 0),  
    prev_wins = lag(wins_battles, default = 0)  
  ) %>%
  ungroup()


arena_summary_brandt_v2 <- arena_summary_brandt_v2 %>%
  mutate(
    losses_played = losses_battles - prev_losses,  
    threeCrownWins_played = threeCrownWins_battles - prev_threeCrownWins,  
    wins_played = wins_battles - prev_wins  
  )



process_data <- function(data) {
  

  data_sorted <- data %>%
    arrange(player_tag, date)
  
  # Dodanie informacji o zmianach areny
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
  
  # Przygotowanie tabeli wynikowej, giga istotne
  arena_summary_data <- data_with_changes %>%
    filter(arena_change == TRUE | is_last_arena == TRUE) %>% 
    mutate(
      losses_battles = case_when(  
        is_last_arena ~ losses, 
        TRUE ~ next_losses 
      ),
      threeCrownWins_battles = case_when(  
        is_last_arena ~ threeCrownWins, 
        TRUE ~ next_threeCrownWins 
      ),
      wins_battles = case_when(  
        is_last_arena ~ wins, 
        TRUE ~ next_wins 
      )
    ) %>%
    select(player_tag, arena, losses_battles, threeCrownWins_battles, wins_battles) %>% 
    distinct(player_tag, arena, losses_battles, threeCrownWins_battles, wins_battles) 
  
  
  arena_summary_data <- arena_summary_data %>%
    group_by(player_tag) %>%
    mutate(
      prev_losses = lag(losses_battles, default = 0),  
      prev_threeCrownWins = lag(threeCrownWins_battles, default = 0), 
      prev_wins = lag(wins_battles, default = 0)
    ) %>%
    ungroup()
  
  arena_summary_data <- arena_summary_data %>%
    mutate(
      losses_played = losses_battles - prev_losses, 
      threeCrownWins_played = threeCrownWins_battles - prev_threeCrownWins, 
      wins_played = wins_battles - prev_wins
    )
  
  return(arena_summary_data)
}

# Przetwarzanie danych dla Mati
arena_summary_mati_v2 <- process_data(mati)

# Przetwarzanie danych dla Karol
arena_summary_karol_v2 <- process_data(karol)





# Połączenie danych dla Mati, Karol i Brandt
arena_combined_v2 <- bind_rows(
  mutate(arena_summary_mati_v2, player_tag = "Mati"),
  mutate(arena_summary_karol_v2, player_tag = "Karol"),
  mutate(arena_summary_brandt_v2, player_tag = "Brandt")
)

# Przekształcenie danych do formatu długiego
arena_co_long_v2 <- arena_combined_v2 %>%
  gather(key = "game_type", value = "games_played", wins_played, losses_played) %>%
  mutate(game_type = factor(game_type, levels = c("wins_played", "losses_played"),
                            labels = c("Wygrane", "Przegrane")))


library(stringr)

correct_arena_names <- c(
  "Miner" = "Miner's Mine",
  "P.E.K.K.A" = "P.E.K.K.A's Playhouse",
  "Builder" = "Builder's Workshop",
  "Rascal" = "Rascal's Hideout"
)




arena_co_long_v2 <- arena_co_long_v2 %>%
  mutate(
    arena_name = sapply(arena, function(arena) {
      # Dopasowanie nazwy areny z uwzględnieniem apostrofów
      match <- regexpr("'name':\\s*['\"]([^'\"]+?)['\"]", arena, perl = TRUE)
      if (match > 0) {
        # Wyciągnij dopasowany fragment
        extracted <- regmatches(arena, match)
        # Usuń 'name': i cudzysłowy
        extracted <- sub("'name':\\s*['\"]", "", extracted)
        extracted <- sub("['\"]$", "", extracted)
        return(extracted)
      } else {
        return(NA)
      }
    }),
    # Nadpisz błędne nazwy na podstawie mapy poprawnych nazw
    arena_name = ifelse(arena_name %in% names(correct_arena_names),
                        correct_arena_names[arena_name],
                        arena_name)
  ) %>%
  filter(!is.na(arena_name) & arena_name != "") %>%
  mutate(arena_name = factor(arena_name, levels = arena_order))






# Wykres 1: Wygrane vs Przegrane na każdej arenie dla Mati
ggplot(subset(arena_co_long_v2, player_tag == "Mati"), aes(x = arena_name, y = games_played, fill = game_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black") +
  labs(
    title = "Wygrane vs Przegrane na każdej arenie - Mati",
    x = "Arena",
    y = "Liczba gier",
    fill = "Rezultat"
  ) +
  scale_fill_manual(values = c("Wygrane" = "blue", "Przegrane" = "red")) + 
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Wykres 2: Wygrane vs Przegrane na każdej arenie dla Karol
ggplot(subset(arena_co_long_v2, player_tag == "Karol"), aes(x = arena_name, y = games_played, fill = game_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black") +
  labs(
    title = "Wygrane vs Przegrane na każdej arenie - Karol",
    x = "Arena",
    y = "Liczba gier",
    fill = "Rezultat"
  ) +
  scale_fill_manual(values = c("Wygrane" = "blue", "Przegrane" = "red")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Wykres 3: Wygrane vs Przegrane na każdej arenie dla Brandt
ggplot(subset(arena_co_long_v2, player_tag == "Brandt"), aes(x = arena_name, y = games_played, fill = game_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black") +
  labs(
    title = "Wygrane vs Przegrane na każdej arenie - Brandt",
    x = "Arena",
    y = "Liczba gier",
    fill = "Rezultat"
  ) +
  scale_fill_manual(values = c("Wygrane" = "blue", "Przegrane" = "red")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


ggplot(subset(arena_co_long_v2, player_tag == "Mati"), aes(x = arena_name, y = games_played, fill = game_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black") +
  labs(
    title = "Wygrane vs Wygrane na 3 Koronki na każdej arenie - Mati",
    x = "Arena",
    y = "Liczba gier",
    fill = "Rezultat"
  ) +
  scale_fill_manual(values = c("Wygrane" = "blue", "Wygrane na 3 Koronki" = "green"), 
                    labels = c("Wygrane", "Wygrane na 3 Koronki")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(subset(arena_co_long_v2, player_tag == "Karol"), aes(x = arena_name, y = games_played, fill = game_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black") +
  labs(
    title = "Wygrane vs Wygrane na 3 Koronki na każdej arenie - Karol",
    x = "Arena",
    y = "Liczba gier",
    fill = "Rezultat"
  ) +
  scale_fill_manual(values = c("Wygrane" = "blue", "Wygrane na 3 Koronki" = "green"),
                    labels = c("Wygrane", "Wygrane na 3 Koronki")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(subset(arena_co_long_v2, player_tag == "Brandt"), aes(x = arena_name, y = games_played, fill = game_type)) +
  geom_bar(stat = "identity", position = "stack", color = "black") +
  labs(
    title = "Wygrane vs Wygrane na 3 Koronki na każdej arenie - Brandt",
    x = "Arena",
    y = "Liczba gier",
    fill = "Rezultat"
  ) +
  scale_fill_manual(values = c("Wygrane" = "blue", "Wygrane na 3 Koronki" = "green"),  
                    labels = c("Wygrane", "Wygrane na 3 Koronki")) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

dzialajProsze <- arena_co_long_v2 %>%
  mutate(
    game_type_3crown = case_when(
      game_type == "Wygrane" & threeCrownWins_played > 0 ~ "Wygrane na 3 Koronki",
      game_type == "Wygrane" & threeCrownWins_played == 0 ~ "Wygrane",
      game_type == "Przegrane" ~ "Przegrane",
      TRUE ~ NA_character_
    )
  )


ggplot(subset(dzialajProsze, player_tag == "Brandt"), aes(x = arena_name, y = games_played, fill = game_type_3crown)) +
  geom_bar(stat = "identity", position = "stack", color = "black") +
  labs(
    title = "Wygrane vs Wygrane na 3 Koronki na każdej arenie - Brandt",
    x = "Arena",
    y = "Liczba gier",
    fill = "Rezultat"
  ) +
  scale_fill_manual(values = c("Wygrane" = "blue", "Wygrane na 3 Koronki" = "green", "Przegrane" = "red"), 
                    labels = c("Wygrane", "Wygrane na 3 Koronki", "Przegrane")) + 
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(subset(dzialajProsze, player_tag == "Karol"), aes(x = arena_name, y = games_played, fill = game_type_3crown)) +
  geom_bar(stat = "identity", position = "stack", color = "black") +
  labs(
    title = "Wygrane vs Wygrane na 3 Koronki na każdej arenie - Karol",
    x = "Arena",
    y = "Liczba gier",
    fill = "Rezultat"
  ) +
  scale_fill_manual(values = c("Wygrane" = "blue", "Wygrane na 3 Koronki" = "green", "Przegrane" = "red"), 
                    labels = c("Wygrane", "Wygrane na 3 Koronki", "Przegrane")) + 
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggplot(subset(dzialajProsze, player_tag == "Mati"), aes(x = arena_name, y = games_played, fill = game_type_3crown)) +
  geom_bar(stat = "identity", position = "stack", color = "black") +
  labs(
    title = "Wygrane vs Wygrane na 3 Koronki na każdej arenie - Mati",
    x = "Arena",
    y = "Liczba gier",
    fill = "Rezultat"
  ) +
  scale_fill_manual(values = c("Wygrane" = "blue", "Wygrane na 3 Koronki" = "green", "Przegrane" = "red"), 
                    labels = c("Wygrane", "Wygrane na 3 Koronki", "Przegrane")) + 
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
write.table(arena_co_long_v2, file = "arena_co_long_v2.txt", sep = "\t", row.names = FALSE, quote = FALSE)
