library(tidyverse)


# Funkcja do ekstrakcji nazw kart z decku
extract_deck <- function(deck_column) {
  fixed_json <- gsub("'", "\"", deck_column)  # Zamiana ' na "
  deck_list <- tryCatch(
    fromJSON(fixed_json, simplifyVector = FALSE), 
    error = function(e) {
      warning(paste("Błąd parsowania JSON:", fixed_json))
      return(NULL)
    }
  )
  
  # Pobranie nazw kart
  if (!is.null(deck_list) && is.list(deck_list)) {
    sapply(deck_list, function(card) {
      if (!is.null(card$name)) {
        card$name
      } else {
        NA
      }
    })
  } else {
    return(NA)
  }
}

process_player_data <- function(player_data, player_name) {
  player_data %>%
    mutate(deck_cards = lapply(currentDeck, extract_deck)) %>%
    unnest(deck_cards) %>%
    group_by(deck_cards) %>%
    summarise(count = n(), .groups = "drop") %>%
    arrange(desc(count)) %>%
    { 
      if (any(is.na(.$deck_cards))) {
        warning(paste("NA w danych dla gracza:", player_name))
      }
      .
    }
}


karol_data <- process_player_data(karol, "Karol")
mati_data <- process_player_data(mati, "Mati")
brandt_data <- process_player_data(brandt, "Brandt")


create_barplot <- function(data, title) {
  ggplot(data, aes(x = reorder(deck_cards, count), y = count, fill = deck_cards)) +
    geom_bar(stat = "identity", show.legend = FALSE) +
    coord_flip() +
    labs(
      title = title,
      x = "Karty",
      y = "Liczba wystąpień"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
      axis.text.y = element_text(size = 10),
      axis.text.x = element_text(size = 10),
      axis.title = element_text(size = 12)
    )
}

karol_plot <- create_barplot(karol_data, "Najczęściej używane karty - Karol")
mati_plot <- create_barplot(mati_data, "Najczęściej używane karty - Mati")
brandt_plot <- create_barplot(brandt_data, "Najczęściej używane karty - Brandt")

print(karol_plot)
print(mati_plot)
print(brandt_plot)

