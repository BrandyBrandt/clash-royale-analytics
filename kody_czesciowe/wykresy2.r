library(ggplot2)
library(dplyr)


karol <- karol %>% filter(!is.na(battleCount) & !is.na(wins))
mati <- mati %>% filter(!is.na(battleCount) & !is.na(wins))
brandt <- brandt %>% filter(!is.na(battleCount) & !is.na(wins))

# funckja znajdujaca 1 wystapienie arenki w rekordach - giga wazne
find_first_exceeds <- function(data, trophy_values) {
  sapply(trophy_values, function(value) {
    first_exceed <- data$battleCount[which(data$trophies > value)[1]]
    if (length(first_exceed) == 0) NA else first_exceed
  })
}

# wskazania na arenki
trophy_values <- c(300, 600, 1000, 1300, 1600, 2000, 2300, 2600, 
                   3000, 3400, 3800, 4200, 4600, 5000, 5500)


karol_lines <- find_first_exceeds(karol, trophy_values)
mati_lines <- find_first_exceeds(mati, trophy_values)
brandt_lines <- find_first_exceeds(brandt, trophy_values)


karol_lines <- karol_lines[!is.na(karol_lines)]
mati_lines <- mati_lines[!is.na(mati_lines)]
brandt_lines <- brandt_lines[!is.na(brandt_lines)]


karol_labels <- data.frame(battleCount = karol_lines, label = 1:length(karol_lines)) %>%
  mutate(label = label + 1)

mati_labels <- data.frame(battleCount = mati_lines, label = 1:length(mati_lines)) %>%
  mutate(label = label + 1)

brandt_labels <- data.frame(battleCount = brandt_lines, label = 1:length(brandt_lines)) %>%
  mutate(label = label + 1)


ggplot() +
  # Karol: ratio wins/battleCount z pionowymi liniami and index labels
  geom_line(data = karol, mapping = aes(x = battleCount, y = wins / battleCount, color = "Karol")) +
  geom_vline(data = karol_labels, aes(xintercept = battleCount), linetype = "dashed", color = "red") +
  geom_text(data = karol_labels, aes(x = battleCount, y = 0, label = label), color = "red", vjust = -1) +
  
  # Mati: ratio wins/battleCount z pionowymi liniami and index labels
  geom_line(data = mati, mapping = aes(x = battleCount, y = wins / battleCount, color = "Mati")) +
  geom_vline(data = mati_labels, aes(xintercept = battleCount), linetype = "dashed", color = "blue") +
  geom_text(data = mati_labels, aes(x = battleCount, y = 0, label = label), color = "blue", vjust = -1) +
  
  # Brand: : ratio wins/battleCount z pionowymi liniami and index labels
  geom_line(data = brandt, mapping = aes(x = battleCount, y = wins / battleCount, color = "Brandt")) +
  geom_vline(data = brandt_labels, aes(xintercept = battleCount), linetype = "dashed", color = "green") +
  geom_text(data = brandt_labels, aes(x = battleCount, y = 0, label = label), color = "green", vjust = -1) +
  

  labs(title = "Ratio wygranych w czasie z pionowymi liniami i indeksami dla wartości pucharków",
       x = "Liczba Bitew",
       y = "Wygrane / Liczba Bitew",
       color = "Gracz") +
  theme_minimal()



# Karol
plot_karol <- ggplot() +
  geom_line(data = karol, mapping = aes(x = battleCount, y = wins / battleCount), color = "red") +
  geom_vline(data = karol_labels, aes(xintercept = battleCount), linetype = "dashed", color = "red") +
  geom_text(data = karol_labels, aes(x = battleCount, y = 0, label = label), color = "red", vjust = -1) +
  labs(title = "Ratio wygranych w czasie - Karol",
       x = "Liczba Bitew",
       y = "Wygrane / Liczba Bitew") +
  theme_minimal()

# Mati
plot_mati <- ggplot() +
  geom_line(data = mati, mapping = aes(x = battleCount, y = wins / battleCount), color = "blue") +
  geom_vline(data = mati_labels, aes(xintercept = battleCount), linetype = "dashed", color = "blue") +
  geom_text(data = mati_labels, aes(x = battleCount, y = 0, label = label), color = "blue", vjust = -1) +
  labs(title = "Ratio wygranych w czasie - Mati",
       x = "Liczba Bitew",
       y = "Wygrane / Liczba Bitew") +
  theme_minimal()

# Brandt
plot_brand <- ggplot() +
  geom_line(data = brand, mapping = aes(x = battleCount, y = wins / battleCount), color = "green") +
  geom_vline(data = brand_labels, aes(xintercept = battleCount), linetype = "dashed", color = "green") +
  geom_text(data = brand_labels, aes(x = battleCount, y = 0, label = label), color = "green", vjust = -1) +
  labs(title = "Ratio wygranych w czasie - Brand",
       x = "Liczba Bitew",
       y = "Wygrane / Liczba Bitew") +
  theme_minimal()


plot_karol
plot_mati
plot_brandt

