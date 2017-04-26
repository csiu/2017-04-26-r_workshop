#' ---
#' title:  08 Creating Publication-Quality Graphics
#' output: html_document
#' ---

#' ## ggplot2
#' ## customization
#' ### Multi-panel figures
#' ### Modifying text

#+ echo=FALSE
# library(ggplot2)
# library(dplyr)
# gapminder <- read.csv("https://raw.githubusercontent.com/swcarpentry/r-novice-gapminder/gh-pages/_episodes_rmd/data/gapminder-FiveYearData.csv")
# gapminder %>%
#   filter(
#     # subset data set
#     #grepl("^[AZ]", country),
#     year == "2007") %>%
#   mutate(
#     # define dummy variables for ggplot
#     lifeExp2 = lifeExp < 60,
#     xmin = ifelse(lifeExp2, lifeExp, 60),
#     xmax = ifelse(lifeExp2, 60, lifeExp)
#     ) %>%
#
#   # Make plot
#   ggplot(aes(x=lifeExp,
#              y=reorder(country, lifeExp),
#              color=lifeExp2)) +
#   geom_point(size = 2) +
#   geom_errorbarh(aes(xmin=xmin, xmax=xmax), height=0) +
#   geom_vline(xintercept = 60, lty = 2)
