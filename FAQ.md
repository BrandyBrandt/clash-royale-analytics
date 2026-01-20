# Frequently Asked Questions (FAQ)

## General Questions

### What is this project?
This is an interactive R Shiny dashboard for analyzing Clash Royale battle statistics. It was created as a university data visualization course project by a team of three students.

### Who created this?
The project was collaboratively developed by:
- Brandt (Olobr) - [@BrandyBrandt](https://github.com/BrandyBrandt)
- Mateusz Jamroż
- Karol Kacprzak

### When was this created?
This project was developed in 2025 as part of a university course on data visualization and analysis.

### Is this project actively maintained?
This is a legacy university project. While it's not under active development, it's well-documented and serves as a portfolio piece. See [ROADMAP.md](ROADMAP.md) for potential future enhancements.

## Technical Questions

### What technologies does this use?
- **R** (version 4.0+)
- **Shiny** for the web application framework
- **ggplot2** and **plotly** for visualizations
- **dplyr** and **tidyverse** for data manipulation
- Various other R packages (see [README.md](README.md#required-r-packages))

### How do I run this locally?

1. Install R (4.0 or higher)
2. Install required packages:
```r
install.packages(c("shiny", "dplyr", "ggplot2", "plotly", 
                   "stringr", "tidyverse", "jsonlite", 
                   "shinythemes", "showtext"))
```
3. Clone the repository
4. Run: `shiny::runApp("app2026.R")`

### Why are some charts not displaying?
This is a known issue. The project was created in 2025, and some package updates may have caused compatibility issues. Potential causes:
- Package version conflicts
- Deprecated syntax
- Data structure changes
- Missing dependencies

This is documented in the README as "Work in Progress."

### Where does the data come from?
The data consists of actual battle history from three Clash Royale players' accounts. Each player exported their own battle data in CSV format.

### Can I use my own Clash Royale data?
Yes! You would need to:
1. Export your battle data in CSV format
2. Ensure it matches the required column structure (see [DOCUMENTATION.md](DOCUMENTATION.md#data-structure))
3. Replace one of the data files (data_b.csv, data_j.csv, or data_k.csv)
4. Update the player name in the code if needed

## Data Questions

### How much data is included?
The project includes battle history data from three players with thousands of battle records. The exact number varies by player.

### Is the data real or synthetic?
All data is real battle history from actual Clash Royale accounts.

### Why is data_b.csv so large?
Some players have extensive battle histories. The CSV format stores each battle as a row with multiple columns, which can result in large file sizes (>50MB).

### Can I see the raw data?
Yes, the CSV files are included in the repository (except data_b.csv which may be excluded due to size). You can open them with any spreadsheet application or text editor.

## Usage Questions

### Can I use this for my own project?
Yes! This project is open source under the MIT License. See [LICENSE](LICENSE) for details. Please provide attribution to the original authors.

### Can I contribute to this project?
Absolutely! We welcome contributions:
- Bug fixes
- Feature enhancements
- Documentation improvements
- Performance optimizations

See [ROADMAP.md](ROADMAP.md) for ideas and open an issue or pull request!

### How do I report a bug?
Open a [new issue](https://github.com/BrandyBrandt/clash-royale-analytics/issues/new) using the bug report template.

### How do I suggest a feature?
Open a [new issue](https://github.com/BrandyBrandt/clash-royale-analytics/issues/new) using the feature request template.

## Deployment Questions

### Can I deploy this online?
Yes! You can deploy Shiny apps to:
- **shinyapps.io** (easiest, free tier available)
- **Shiny Server** (self-hosted)
- **Docker** containers
- **RStudio Connect**

See [DOCUMENTATION.md](DOCUMENTATION.md#deployment) for more details.

### Is there a live demo?
Currently, there is no live demo. The project needs to be run locally. Deploying to shinyapps.io is a potential future enhancement.

## Academic Questions

### Can I reference this project in my work?
Yes, but please provide proper attribution:
```
Brandt, Olobr, Mateusz Jamroż, and Karol Kacprzak. (2025). 
Clash Royale Analytics Dashboard. 
GitHub repository: https://github.com/BrandyBrandt/clash-royale-analytics
```

### Can I use this as inspiration for my own project?
Absolutely! That's why it's open source. We'd love to see what you create!

### What did you learn from this project?
Key learnings included:
- Team collaboration on a data science project
- R Shiny application development
- Interactive data visualization techniques
- Data cleaning and preprocessing
- Version control with Git/GitHub
- Documentation best practices

## Clash Royale Specific Questions

### Does this work with the latest Clash Royale updates?
The core functionality should work regardless of game updates. However:
- New cards would need to be added to the card database
- New arenas might not be recognized
- Balance changes don't affect historical data analysis

### Where can I get Clash Royale data?
Options include:
- Clash Royale API (official)
- RoyaleAPI (community)
- Manual data export from game replays
- Third-party tools and libraries

### What insights can I gain from this dashboard?
The dashboard helps you understand:
- Battle performance by arena level
- Most used cards and deck patterns
- Trophy progression over time
- Win/loss ratios
- Three-crown victory rates
- Deck composition preferences

## Troubleshooting

### The app won't start
Check:
1. R version (4.0+)
2. All required packages installed
3. Working directory is set correctly
4. Data files are present
5. No syntax errors in console

### Charts are blank
Try:
1. Updating all packages: `update.packages(ask = FALSE)`
2. Checking data file integrity
3. Looking for errors in R console
4. Testing with smaller datasets first

### Performance is slow
Tips:
1. Close other R sessions
2. Use a subset of data for testing
3. Increase available RAM
4. Check for infinite loops or inefficient code

### I get encoding errors
Ensure:
1. CSV files are UTF-8 encoded
2. Special characters are properly escaped
3. File paths use correct separators (/ or \\)

## Contact & Support

### How can I get help?
1. Check this FAQ
2. Review [DOCUMENTATION.md](DOCUMENTATION.md)
3. Search existing [GitHub Issues](https://github.com/BrandyBrandt/clash-royale-analytics/issues)
4. Open a new issue if your question isn't answered

### Can I contact the developers directly?
For general questions, please use GitHub Issues so others can benefit from the answers. For private inquiries, you can reach out through GitHub.

---

**Don't see your question answered here?** [Open an issue](https://github.com/BrandyBrandt/clash-royale-analytics/issues/new) and we'll add it to this FAQ!

*Last Updated: January 2026*
