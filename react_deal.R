library(reactable)
library(tidyverse)
# data preparation
oa_cr_df <- readr::read_csv("data/oa_cr_df.csv")
articles_ind <- oa_cr_df %>%
  distinct(issn_l, vertrag, n) %>%
  group_by(vertrag) %>%
  summarise(articles = sum(n))
journals_ind <- oa_cr_df %>%
  group_by(vertrag) %>%
  summarise(journals_n = n_distinct(issn_l)) %>%
  inner_join(articles_ind, by = "vertrag")
publisher_ind <- oa_cr_df %>%
  # we are only interested in hybrid journals 
  filter(!oa_status %in% c("gold", "bronze", "closed")) %>%
  group_by(vertrag, oa_status) %>%
  summarise(upw_n = sum(upw_n)) %>%
  inner_join(journals_ind, by = "vertrag") %>%
  mutate(prop = upw_n / articles)
publisher_table <- publisher_ind %>%
  select(-upw_n) %>%
  pivot_wider(names_from = oa_status, values_from = c(prop))

#' Reactable represenation of oa indicators
#'
#' Inspired from <https://glin.github.io/reactable/articles/building-twitter-followers.html>
#'
#' @import reactable
#'
#' @param ind_table tibble compliance overview table
#' @param fill_col fill color for bar charts (hex code)
#'
#' @export
library(reactable)
publisher_table %>%
  select(vertrag, journals_n, articles, hybrid, green) %>%
reactable::reactable(
    pagination = FALSE,
    style = list(fontFamily = "Roboto Mono, monospace"),
    defaultSorted = "articles",
    columns = list(
      vertrag = colDef(html = TRUE,
        name = "Agreement",
        width = 200
      ),
      journals_n = colDef(html = TRUE,
        name = "Journals",
        defaultSortOrder = "desc",
        format = colFormat(separators = TRUE),
        style = list(fontFamily = "monospace", whiteSpace = "pre"),
        width = 80
      ),
      articles = colDef(html = TRUE,
        name = "Articles",
        defaultSortOrder = "desc",
        format = colFormat(separators = TRUE),
        style = list(fontFamily = "monospace", whiteSpace = "pre"),
        width = 100
      ),
      hybrid = colDef(html = TRUE,
        name = "Hybrid OA Share",
        defaultSortOrder = "desc",
        # Render the bar charts using a custom cell render function
        cell = function(value) {
          value <- paste0(format(round(value * 100, 1), nsmall = 1), "%")
          # Fix width here to align single and double-digit percentages
          value <- format(value, width = 5, justify = "right")
          react_bar_chart(value, width = value, fill = "#EF9708", background = "#e1e1e1")
        },
        align = "left",
        style = list(fontFamily = "monospace", whiteSpace = "pre")
      ),
      green = colDef(html = TRUE,
        name = "Green OA Share",
        defaultSortOrder = "desc",
        # Render the bar charts using a custom cell render function
        cell = function(value) {
          value <- paste0(format(round(value * 100, 1), nsmall = 1), "%")
          # Fix width here to align single and double-digit percentages
          value <- format(value, width = 5, justify = "right")
          react_bar_chart(value, width = value, fill = "#11C638", background = "#e1e1e1")
        },
        align = "left",
        style = list(fontFamily = "monospace", whiteSpace = "pre")
      )
    ),
    compact = TRUE
  )

htmltools::tags$link(href = "https://fonts.googleapis.com/css2?family=Roboto&family=Roboto+Mono:wght@300&display=swap",
          rel = "stylesheet")
#' React bar chart helper
#'
#' From <https://glin.github.io/reactable/articles/building-twitter-followers.html>
#'
#' @importFrom htmltools div
#'
#' @noRd
react_bar_chart <- function(label, width = "100%", height = "14px", fill = "#00bfc4", background = NULL) {
  bar <- htmltools::div(style = list(background = fill, width = width, height = height))
  chart <- htmltools::div(style = list(flexGrow = 1, marginLeft = "6px", background = background), bar)
  htmltools::div(style = list(display = "flex", alignItems = "center"), label, chart)
}
