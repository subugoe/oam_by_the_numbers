library(tidyverse)
oam <- readr::read_delim("data/oam_zeitschriftenlisten.csv", 
  trim_ws = TRUE, delim = ";") %>%
# exclude full oa journals
  filter(!vertrag %in% c(
    "OAM_OA-Zeitschriften_DFG-Anträge",
    "Springer Gold (DEAL)",
    "Wiley Gold (DEAL)")
    ) %>%
  filter(!is.na(issn_l))
### upload to bigquery
#' upload to big query
library(bigrquery)
bg_oam_journals <- 
  bq_table("api-project-764811344545", "tmp", "oam_journals")
if(bq_table_exists(bg_oam_journals)) 
  bq_table_delete(bg_oam_journals)
bigrquery::bq_table_upload(
  bg_oam_journals,
  oam)
#' Connection to BQ
con <- dbConnect(
  bigrquery::bigquery(),
  project = "api-project-764811344545",
  dataset = "tmp"
)
#' obtain yearly article counts by issn-l
cr_yearly <- readr::read_file("inst/sql/oam_get_cr_per_year.sql")
cr_yearly_df <- DBI::dbGetQuery(con, cr_yearly)
cr_oam <- inner_join(cr_yearly_df, oam, by = "issn_l") %>% 
  select(-issn) %>%
  distinct()
#' obtain yearly oa article counts by issn-l from unpaywall
oa_yearly <- readr::read_file("inst/sql/oam_get_oa_upw_per_year.sql")
oa_yearly_df <- DBI::dbGetQuery(con, oa_yearly)
#' fill missing colors
all_comb <- oa_yearly_df %>%
  tidyr::expand(issn_l, cr_year, oa_status) %>%
  left_join(oa_yearly_df, by = c("issn_l", "cr_year", "oa_status")) %>%
  mutate(upw_n = ifelse(is.na(upw_n), 0, upw_n))
oa_cr_df <- inner_join(cr_oam, all_comb, by = c("issn_l", "cr_year")) %>%
  # oa proportion
  mutate(prop = upw_n / n)
#' normalized jn and publisher name
cr_jn_disambiguate <- readr::read_file("inst/sql/oam_jn_disambiguate.sql")
cr_jn_disambiguate_df <- DBI::dbGetQuery(con, cr_jn_disambiguate)
oa_cr <- inner_join(oa_cr_df, cr_jn_disambiguate_df, by = "issn_l") %>%
  mutate(journal = container_title) %>%
  select(-container_title)
# export
readr::write_csv(oa_cr, "data/oa_cr_df.csv")
#' h2020 publications in oam journals
h2020_yearly <- readr::read_file("inst/sql/oam_get_h2020_per_year.sql")
h2020_yearly_df <-  DBI::dbGetQuery(con, h2020_yearly) %>%
  rename(h2020_n = n)
h2020_cr_df <- oa_cr %>%
  distinct(issn_l, cr_year, n) %>%
  left_join(h2020_yearly_df, by = c("issn_l", "cr_year")) %>%
  mutate(h2020_n = ifelse(is.na(h2020_n), 0, h2020_n)) %>%
  # h2020 proportion
  mutate(prop = h2020_n / n)
readr::write_csv(h2020_cr, "data/h2020_cr_df.csv")
