# Technical Documentation

## Data Structure

### CSV Data Files
Each player's battle history is stored in a CSV file with the following structure:

```
battleCount, trophies, currentDeck, arena, wins, losses, threeCrownWins, name, date, player_tag
```

**Column Descriptions:**
- `battleCount`: Total number of battles played
- `trophies`: Trophy count at the time of the battle
- `currentDeck`: Comma-separated list of 8 cards used
- `arena`: Arena name/level
- `wins`: Total wins
- `losses`: Total losses
- `threeCrownWins`: Number of three-crown victories
- `name`: Player name
- `date`: Battle date
- `player_tag`: Unique player identifier

### Card Data Structure
Card information includes:
- **Card Name**: Official card name from Clash Royale
- **Rarity**: Common, Rare, Epic, Legendary, or Champion
- **Elixir Cost**: Cost to deploy the card (1-8 elixir)

## Application Architecture

### Main Components

#### 1. Data Loading (`app2026.R` lines 1-53)
- **safe_read_csv()**: Robust CSV reader with error handling
- **get_empty_structure()**: Returns empty dataframe with correct schema
- Loads data for three players: Karol, Mateusz (Jamroż), and Brandt

#### 2. Data Processing
- Card database parsing from embedded text data
- Deck analysis and card frequency calculations
- Trophy progression tracking
- Arena-specific statistics aggregation

#### 3. UI Structure
Four separate UI definitions:
- **ui1**: Brandt's statistics page
- **ui2**: Jamroż's statistics page
- **ui3**: Kacprzak's statistics page
- **ui4**: Home page with project overview
- **Main UI**: Navigation container with tabPanel structure

#### 4. Server Logic
- Reactive data filtering
- Dynamic plot generation using plotly
- Interactive chart rendering
- Player-specific calculations

### Visualization Types

1. **Battle Count by Arena**
   - Bar chart showing number of battles in each arena
   - Interactive tooltips with exact counts

2. **Trophy Progression**
   - Line chart tracking trophy changes over time
   - Helps identify performance trends

3. **Card Usage Frequency**
   - Bar chart of most-used cards
   - Card images for visual identification

4. **Win/Loss Statistics**
   - Pie charts or bar charts showing win rates
   - Three-crown win percentage

5. **Average Deck Composition**
   - Elixir cost distribution
   - Card rarity breakdown

## Code Organization

### Directory: `kody_czesciowe/`
Contains modular analysis scripts:

- **3crowsAndMore.r**: Three-crown victory analysis
- **avgDeckiNaArenki.r**: Average deck composition per arena
- **battlesPerArena.r**: Battle count distribution
- **favouriteCardsWykresiki.r**: Favorite cards visualization
- **kartyOverall.r**: Overall card statistics
- **wykresy1.r**: General plots module
- **wykresy2.r**: Additional visualizations

### Assets: `cards/` and `www/cards/`
Contains 106+ card images in PNG format for visual representation in the dashboard.

## Dependencies

### Required R Packages
```r
shiny          # Web application framework
dplyr          # Data manipulation
ggplot2        # Static plotting
plotly         # Interactive plots
stringr        # String operations
tidyverse      # Collection of data science packages
jsonlite       # JSON parsing
shinythemes    # UI themes
showtext       # Custom fonts
```

### External Resources
- **Google Fonts**: Roboto font family for consistent typography
- **Clash Royale API**: (if applicable) for real-time data

## Development Notes

### Version History
- **app.R**: Initial version
- **app2.r**: Second iteration
- **app2026.R**: Current production version (2025/2026)

### Known Limitations
1. **Static Data**: Data is loaded from CSV files, not real-time API
2. **Manual Updates**: Player data must be manually exported and updated
3. **Chart Compatibility**: Some plots may not render due to package version conflicts
4. **Large File Sizes**: CSV files can be large (>50MB) causing sync issues

### Future Improvements
- [ ] Integrate with Clash Royale API for live data
- [ ] Add player comparison features
- [ ] Implement data caching for performance
- [ ] Add more advanced statistical analysis
- [ ] Create mobile-responsive design
- [ ] Add data export functionality
- [ ] Implement user authentication for personal dashboards

## Deployment

### Local Deployment
```r
# From R console
setwd("path/to/projectRoyale")
shiny::runApp("app2026.R")
```

### Server Deployment (shinyapps.io)
```r
library(rsconnect)
rsconnect::deployApp(
  appDir = "path/to/projectRoyale",
  appName = "clash-royale-analytics"
)
```

### Docker Deployment
Create a Dockerfile:
```dockerfile
FROM rocker/shiny:latest
RUN R -e "install.packages(c('shiny','dplyr','ggplot2','plotly','stringr','tidyverse','jsonlite','shinythemes','showtext'))"
COPY . /srv/shiny-server/
EXPOSE 3838
CMD ["/usr/bin/shiny-server"]
```

## Performance Optimization

### Data Loading
- Pre-process large CSV files
- Cache frequently accessed data
- Use data.table for faster operations

### Rendering
- Limit number of data points in plots
- Use aggregated data for overview charts
- Implement lazy loading for images

## Troubleshooting

### Common Issues

**Problem**: Charts not rendering
- **Solution**: Update all packages, check data integrity, verify ggplot2/plotly compatibility

**Problem**: CSV read errors
- **Solution**: Check file encoding (UTF-8), verify column names, ensure proper separators

**Problem**: Missing card images
- **Solution**: Verify all PNG files exist in cards/ directory, check file naming conventions

**Problem**: Font not loading
- **Solution**: Ensure internet connection for Google Fonts, check showtext configuration

## Contact & Support

For technical questions or bug reports, please contact the development team:
- Olobr (Brandt)
- Mateusz Jamroż
- Karol Kacprzak

---

*Last Updated: January 2026*
