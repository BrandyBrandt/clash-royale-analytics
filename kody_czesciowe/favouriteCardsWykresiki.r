# ulubione karty
library(tidyverse)


# grupowanie i sumowanie
fav_card_summary_brandt <- brandt %>%
  group_by(currentFavouriteCard) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  mutate(card_number = row_number())


# grupowanie i sumowanie
fav_card_summary_karol <- karol %>%
  group_by(currentFavouriteCard) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  mutate(card_number = row_number())


# grupowanie i sumowanie
fav_card_summary_mati <- mati %>%
  group_by(currentFavouriteCard) %>%
  summarise(count = n()) %>%
  arrange(desc(count)) %>%
  mutate(card_number = row_number())



library(tidyverse)

# Słownik kart (id -> name)
card_dictionary <- c(
  "26000000" = "Knight",
  "26000001" = "Archers",
  "26000002" = "Goblins",
  "26000003" = "Giant",
  "26000004" = "P.E.K.K.A",
  "26000005" = "Minions",
  "26000006" = "Balloon",
  "26000007" = "Witch",
  "26000008" = "Barbarians",
  "26000009" = "Golem",
  "26000010" = "Skeletons",
  "26000011" = "Valkyrie",
  "26000012" = "Skeleton Army",
  "26000013" = "Bomber",
  "26000014" = "Musketeer",
  "26000015" = "Baby Dragon",
  "26000016" = "Prince",
  "26000017" = "Wizard",
  "26000018" = "Mini P.E.K.K.A",
  "26000019" = "Spear Goblins",
  "26000020" = "Giant Skeleton",
  "26000021" = "Hog Rider",
  "26000022" = "Minion Horde",
  "26000023" = "Ice Wizard",
  "26000024" = "Royal Giant",
  "26000025" = "Guards",
  "26000026" = "Princess",
  "26000027" = "Dark Prince",
  "26000028" = "Three Musketeers",
  "26000029" = "Lava Hound",
  "26000030" = "Ice Spirit",
  "26000031" = "Fire Spirits",
  "26000032" = "Miner",
  "26000033" = "Sparky",
  "26000034" = "Bowler",
  "26000035" = "Lumberjack",
  "26000036" = "Battle Ram",
  "26000037" = "Inferno Dragon",
  "26000038" = "Ice Golem",
  "26000039" = "Mega Minion",
  "26000040" = "Dart Goblin",
  "26000041" = "Goblin Gang",
  "26000042" = "Electro Wizard",
  "26000043" = "Elite Barbarians",
  "26000044" = "Hunter",
  "26000045" = "Executioner",
  "26000046" = "Bandit",
  "26000047" = "Royal Ghost",
  "26000048" = "Zappies",
  "26000049" = "Flying Machine",
  "26000050" = "Cannon Cart",
  "26000051" = "Mega Knight",
  "26000052" = "Skeleton Barrel",
  "26000053" = "Royal Hogs",
  "26000054" = "Goblin Giant",
  "26000055" = "Fisherman",
  "26000056" = "Magic Archer",
  "26000057" = "Electro Dragon",
  "26000058" = "Firecracker",
  "26000059" = "Elixir Golem",
  "26000060" = "Battle Healer",
  "26000061" = "Skeleton Dragons",
  "26000062" = "Mother Witch",
  "26000063" = "Electro Spirit",
  "26000064" = "Electro Giant",
  "26000065" = "Golden Knight",
  "26000066" = "Archer Queen",
  "26000067" = "Skeleton King",
  "26000068" = "Mighty Miner",
  "26000069" = "Monk",
  "26000070" = "Phoenix",
  "26000071" = "Archers Evolved"
)

# Funkcja do wyciągania nazwy karty z tekstu
extract_card_name <- function(card_info) {
  str_match(card_info, "'name':\\s*'([^']+)'")[, 2]
}

# Dodanie wyodrębnionej nazwy karty do zbiorów danych
fav_card_summary_brandt <- brandt %>%
  mutate(card_name = extract_card_name(currentFavouriteCard)) %>%
  group_by(card_name) %>%
  summarise(count = n(), .groups = "drop")

fav_card_summary_karol <- karol %>%
  mutate(card_name = extract_card_name(currentFavouriteCard)) %>%
  group_by(card_name) %>%
  summarise(count = n(), .groups = "drop")

fav_card_summary_mati <- mati %>%
  mutate(card_name = extract_card_name(currentFavouriteCard)) %>%
  group_by(card_name) %>%
  summarise(count = n(), .groups = "drop")

# Zapisanie wyników do plików tekstowych
write.table(
  fav_card_summary_brandt, 
  "fav_card_summary_brandt.txt", 
  sep = "\t", 
  row.names = FALSE, 
  quote = FALSE
)

write.table(
  fav_card_summary_karol, 
  "fav_card_summary_karol.txt", 
  sep = "\t", 
  row.names = FALSE, 
  quote = FALSE
)

write.table(
  fav_card_summary_mati, 
  "fav_card_summary_mati.txt", 
  sep = "\t", 
  row.names = FALSE, 
  quote = FALSE
)

# Komunikat potwierdzający
cat("Podsumowania zostały zapisane jako pliki tekstowe:\n",
    "fav_card_summary_brandt.txt\n",
    "fav_card_summary_karol.txt\n",
    "fav_card_summary_mati.txt\n")

# Usuwanie wierszy z NA w podsumowaniach
fav_card_summary_brandt <- brandt %>%
  mutate(card_name = extract_card_name(currentFavouriteCard)) %>%
  filter(!is.na(card_name)) %>%  # Usuwanie NA
  group_by(card_name) %>%
  summarise(count = n(), .groups = "drop") %>%
  mutate(card_number = row_number())

fav_card_summary_karol <- karol %>%
  mutate(card_name = extract_card_name(currentFavouriteCard)) %>%
  filter(!is.na(card_name)) %>%  # Usuwanie NA
  group_by(card_name) %>%
  summarise(count = n(), .groups = "drop") %>%
  mutate(card_number = row_number())

fav_card_summary_mati <- mati %>%
  mutate(card_name = extract_card_name(currentFavouriteCard)) %>%
  filter(!is.na(card_name)) %>%  # Usuwanie NA
  group_by(card_name) %>%
  summarise(count = n(), .groups = "drop") %>%
  mutate(card_number = row_number())

# brandt - wykres z krótkimi nazwami kart
fav_card_summary_brandt %>%
  ggplot(aes(x = "", y = count, fill = factor(card_name))) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  labs(
    title = "Częstotliwość ulubionych kart",
    fill = "Nazwa karty"
  ) +
  theme_void()

# karol - wykres z krótkimi nazwami kart
fav_card_summary_karol %>%
  ggplot(aes(x = "", y = count, fill = factor(card_name))) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  labs(
    title = "Częstotliwość ulubionych kart",
    fill = "Nazwa karty"
  ) +
  theme_void()

# mati - wykres z krótkimi nazwami kart
fav_card_summary_mati %>%
  ggplot(aes(x = "", y = count, fill = factor(card_name))) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y", start = 0) +
  labs(
    title = "Częstotliwość ulubionych kart",
    fill = "Nazwa karty"
  ) +
  theme_void()

