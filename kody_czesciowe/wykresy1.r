# Wartości y dla poziomych linii
horizontal_lines <- c(300, 600, 1000, 1300, 1600, 2000, 2300, 2600, 
                      3000, 3400, 3800, 4200, 4600, 5000, 5500)

# Wykres łączący dane 'karol', 'mati' i 'brand' z poziomymi liniami
ggplot() +
  geom_line(data = karol, mapping = aes(x = battleCount, y = trophies, color = "Karol"), size = 1) +
  geom_line(data = mati, mapping = aes(x = battleCount, y = trophies, color = "Mati"), size = 1) +
  geom_line(data = brandt, mapping = aes(x = battleCount, y = trophies, color = "Brand"), size = 1) +
  geom_hline(yintercept = horizontal_lines, linetype = "dashed", color = "gray") +
  scale_color_manual(values = c("Karol" = "red", "Mati" = "blue", "Brand" = "green")) +
  labs(title = "Ilość Bitew a Pucharki",
       x = "Liczba Bitew",
       y = "Pucharki",
       color = "Legenda") +
  theme_minimal()

horizontal_lines <- c(300, 600, 1000, 1300, 1600, 2000, 2300, 2600, 
                      3000, 3400, 3800, 4200, 4600, 5000, 5500)

# mniej linii dla matiego bo jest lipny ;3
horizontal_lines_mati <- c(300, 600, 1000, 1300, 1600, 2000, 2300, 2600)

# Karol
plot_karol <- ggplot(data = karol, aes(x = battleCount, y = trophies)) +
  geom_line(color = "red", size = 1) +
  geom_hline(yintercept = horizontal_lines, linetype = "dashed", color = "gray") +
  labs(title = "Karol: Ilość Bitew a Pucharki",
       x = "Liczba Bitew",
       y = "Pucharki") +
  theme_minimal()

# Mati
plot_mati <- ggplot(data = mati, aes(x = battleCount, y = trophies)) +
  geom_line(color = "blue", size = 1) +
  geom_hline(yintercept = horizontal_lines_mati, linetype = "dashed", color = "gray") +
  labs(title = "Mati: Ilość Bitew a Pucharki",
       x = "Liczba Bitew",
       y = "Pucharki") +
  theme_minimal()

# Brandt
plot_brandt <- ggplot(data = brandt, aes(x = battleCount, y = trophies)) +
  geom_line(color = "green", size = 1) +
  geom_hline(yintercept = horizontal_lines, linetype = "dashed", color = "gray") +
  labs(title = "Brandt: Ilość Bitew a Pucharki",
       x = "Liczba Bitew",
       y = "Pucharki") +
  theme_minimal()

# Wyświetlenie wykresów
library(gridExtra)
grid.arrange(plot_karol, plot_mati, plot_brandt, ncol = 1)
