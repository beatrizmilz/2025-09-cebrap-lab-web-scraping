library(httr)
library(purrr)
library(rvest)

u_wiki <- "https://en.wikipedia.org/wiki/R_language"

r_wiki <- GET(u_wiki)

## outra alternativa
# read_html(u_wiki)
tabelas <- r_wiki |>
  read_html() |>
  html_table()

# tabela versão do R
tabelas_versao_r <- r_wiki |>
  read_html() |>
  # classe wikitable
  html_elements(xpath = "//table[@class='wikitable']") |>
  html_table()
