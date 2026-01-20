# 🏰 Clash Royale Battle Analytics Dashboard

> An interactive R Shiny application for analyzing Clash Royale battle statistics and player performance metrics.

[![R](https://img.shields.io/badge/R-4.0+-blue.svg)](https://www.r-project.org/)
[![Shiny](https://img.shields.io/badge/Shiny-Dashboard-brightgreen.svg)](https://shiny.rstudio.com/)
[![Status](https://img.shields.io/badge/Status-Work%20in%20Progress-yellow.svg)]()

**👔 [Quick Overview for Recruiters →](FOR_RECRUITERS.md)**

## 📖 Overview

This project was developed as part of a data visualization and analysis course at the University. The dashboard provides comprehensive insights into Clash Royale player statistics, including battle history, card usage patterns, trophy progression, and arena performance metrics.

**Team Members:**
- Olobr (Brandt)
- Mateusz (Jamroż)
- Karol (Kacprzak)

📚 **[Full Contributors Details →](CONTRIBUTORS.md)**

## ✨ Features

### 📊 Interactive Visualizations
- **Player Performance Tracking**: Monitor wins, losses, and three-crown victories across different arenas
- **Card Usage Analysis**: Identify most-used cards and deck compositions
- **Trophy Progression**: Track trophy count evolution over time
- **Arena Statistics**: Analyze battle performance by arena level
- **Deck Building Insights**: Understand average deck composition and card synergies

### 🎯 Key Metrics
- Battle count per arena
- Win/loss ratios
- Three-crown win statistics
- Favorite card frequency analysis
- Deck elixir cost optimization

## 🚀 Getting Started

### Prerequisites

Ensure you have R (version 4.0 or higher) installed on your system:
```bash
R --version
```

### Required R Packages

Install the necessary dependencies:
```r
install.packages(c(
  "shiny",
  "dplyr",
  "ggplot2",
  "plotly",
  "stringr",
  "tidyverse",
  "jsonlite",
  "shinythemes",
  "showtext"
))
```

### Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/clash-royale-analytics.git
cd clash-royale-analytics
```

2. Ensure data files are present:
   - `data_b.csv` - Brandt's battle data
   - `data_j.csv` - Mateusz's battle data
   - `data_k.csv` - Karol's battle data

3. Run the application:
```r
shiny::runApp("app2026.R")
```

The dashboard will launch in your default web browser.

## 📁 Project Structure

```
projectRoyale/
├── app2026.R                 # Main Shiny application
├── app.R                     # Legacy version
├── app2.r                    # Legacy version
├── kod.R                     # Utility functions
├── data_b.csv                # Player data (Brandt)
├── data_j.csv                # Player data (Jamroż)
├── data_k.csv                # Player data (Kacprzak)
├── fav_card_summary_*.txt    # Favorite cards summaries
├── cards/                    # Card images (106 cards)
├── kody_czesciowe/           # Partial analysis scripts
│   ├── 3crowsAndMore.r
│   ├── avgDeckiNaArenki.r
│   ├── battlesPerArena.r
│   ├── favouriteCardsWykresiki.r
│   ├── kartyOverall.r
│   ├── wykresy1.r
│   └── wykresy2.r
└── www/                      # Web assets
```

📖 **[Full Technical Documentation →](DOCUMENTATION.md)**

## 🎮 How to Use

### Navigation
The dashboard contains four main tabs:
1. **Strona główna** (Home): Overview and project introduction
2. **Brandt**: Brandt's player statistics and visualizations
3. **Jamroż**: Mateusz's player statistics and visualizations
4. **Kacprzak**: Karol's player statistics and visualizations

### Features by Tab
Each player tab includes:
- Interactive plotly charts
- Battle history visualization
- Card usage frequency
- Trophy progression timeline
- Arena-specific statistics

## 🔧 Technical Details

### Data Processing
- **Safe CSV Reading**: Robust error handling for data import
- **Data Validation**: Ensures required columns are present
- **Dynamic Filtering**: Player-specific data isolation

### Visualization
- Built with `ggplot2` and `plotly` for interactive charts
- Custom theme with Roboto font via Google Fonts
- Responsive layout using `shinythemes`

### Card Database
Complete collection of 106+ Clash Royale cards with:
- Rarity levels (Common, Rare, Epic, Legendary, Champion)
- Elixir costs
- Card images

## ⚠️ Known Issues

**Note:** This is a legacy project from 2025. Some features may require updates:

- ⚡ **Chart Rendering**: Some visualizations may not display correctly due to package version updates or data structure changes
- 🔄 **Work in Progress**: Active maintenance is limited; contributions welcome
- 📊 **Data Dependencies**: Requires valid CSV files with specific column structure

### Troubleshooting
If charts don't render:
1. Verify all required packages are installed and up to date
2. Check data file integrity and column names
3. Review browser console for JavaScript errors
4. Try running individual visualization scripts in `kody_czesciowe/`

📚 **[More Help → FAQ](FAQ.md)**

## 🤝 Contributing

This was a university project, but suggestions and improvements are welcome! Feel free to:
- Open issues for bugs or feature requests
- Submit pull requests for fixes
- Share your own Clash Royale data analysis ideas

📋 **[View Roadmap →](ROADMAP.md)** | 👥 **[Contributors →](CONTRIBUTORS.md)**

## 📝 License

This project was created for educational purposes. All Clash Royale assets and trademarks belong to Supercell.

The code is available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- **Supercell** for creating Clash Royale
- **RStudio** for the Shiny framework
- University course instructors for project guidance
- All contributors to the R packages used

## 📧 Contact

For questions or collaboration opportunities:
- Project maintained by: Olobr
- Created in collaboration with: Mateusz Jamroż, Karol Kacprzak

---

**Note:** This project represents work from 2025 and may require updates for current package versions. It serves as a portfolio piece demonstrating R programming, data visualization, and interactive dashboard development skills.
