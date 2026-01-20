library(dplyr)
library(ggplot2)
library(tidyr)

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

brandt_sorted <- brandt %>%
  arrange(player_tag, date)

brandt_with_changes <- brandt_sorted %>%
  group_by(player_tag) %>%
  mutate(
    arena_change = arena != lead(arena, default = last(arena)),
    next_trophies = lead(battleCount), 
    is_last_arena = row_number() == n() 
  ) %>%
  ungroup()

arena_summary_brandt <- brandt_with_changes %>%
  filter(arena_change == TRUE | is_last_arena == TRUE) %>% 
  mutate(
    battles = case_when(
      is_last_arena ~ battleCount, 
      TRUE ~ next_trophies
    )
  ) %>%
  select(player_tag, arena, battles) %>%
  distinct(player_tag, arena, battles)

arena_summary_brandt <- arena_summary_brandt %>%
  group_by(player_tag) %>%
  mutate(
    prev = lag(battles, default = 0)
  ) %>%
  ungroup()

arena_summary_brandt <- arena_summary_brandt %>%
  mutate(
    battles_played = battles - prev
  )

karol_sorted <- karol %>%
  arrange(player_tag, date)

karol_with_changes <- karol_sorted %>%
  group_by(player_tag) %>%
  mutate(
    arena_change = arena != lead(arena, default = last(arena)),
    next_trophies = lead(battleCount),
    is_last_arena = row_number() == n()
  ) %>%
  ungroup()

arena_summary_karol <- karol_with_changes %>%
  filter(arena_change == TRUE | is_last_arena == TRUE) %>%
  mutate(
    battles = case_when(
      is_last_arena ~ battleCount,
      TRUE ~ next_trophies
    )
  ) %>%
  select(player_tag, arena, battles) %>%
  distinct(player_tag, arena, battles)

arena_summary_karol <- arena_summary_karol %>%
  group_by(player_tag) %>%
  mutate(
    prev = lag(battles, default = 0)
  ) %>%
  ungroup()

arena_summary_karol <- arena_summary_karol %>%
  mutate(
    battles_played = battles - prev 
  )

mati_sorted <- mati %>%
  arrange(player_tag, date)

mati_with_changes <- mati_sorted %>%
  group_by(player_tag) %>%
  mutate(
    arena_change = arena != lead(arena, default = last(arena)), 
    next_trophies = lead(battleCount), 
    is_last_arena = row_number() == n() 
  ) %>%
  ungroup()

arena_summary_mati <- mati_with_changes %>%
  filter(arena_change == TRUE | is_last_arena == TRUE) %>%
  mutate(
    battles = case_when(
      is_last_arena ~ battleCount,
      TRUE ~ next_trophies
    )
  ) %>%
  select(player_tag, arena, battles) %>% 
  distinct(player_tag, arena, battles) 

arena_summary_mati <- arena_summary_mati %>%
  group_by(player_tag) %>%
  mutate(
    prev = lag(battles, default = 0)
  ) %>%
  ungroup()

arena_summary_mati <- arena_summary_mati %>%
  mutate(
    battles_played = battles - prev
  )

arena_summary_combined <- bind_rows(
  arena_summary_brandt %>% mutate(player_tag = "Brandt"),
  arena_summary_karol %>% mutate(player_tag = "Karol"),
  arena_summary_mati %>% mutate(player_tag = "Mati")
)

library(stringr)

# Funkcja do wyciągania poprawnej nazwy areny, no niedokonca poprawnej
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

arena_summary_combined <- arena_summary_combined %>%
  mutate(
    arena_name = sapply(arena, extract_arena_name),
    arena_name = ifelse(arena_name %in% names(correct_arena_names),
                        correct_arena_names[arena_name],
                        arena_name)
  ) %>%
  filter(!is.na(arena_name) & arena_name != "") %>%
  mutate(arena_name = factor(arena_name, levels = arena_order))

ggplot(arena_summary_combined, aes(x = arena_name, y = battles_played, fill = player_tag)) +
  geom_bar(stat = "identity", position = "dodge", color = "black", width = 0.8) +
  theme_minimal() +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Liczba bitew na każdej arenie dla każdego gracza",
    subtitle = "Porównanie bitew rozegranych przez graczy na różnych arenach",
    x = "Arena",
    y = "Liczba bitew",
    fill = "Gracz"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, margin = margin(b = 10)),
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, face = "italic"),
    axis.text.y = element_text(size = 10),
    axis.title = element_text(size = 12),
    legend.position = "top",
    legend.title = element_text(face = "bold"),
    legend.text = element_text(size = 10)
  ) +
  geom_text(
    aes(label = battles_played), 
    position = position_dodge(0.8), 
    vjust = -0.3, 
    size = 3
  )

