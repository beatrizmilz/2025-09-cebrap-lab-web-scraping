# Carregando pacotes ----
# httr: permite fazer requisições HTTP (acessar páginas na web)
# purrr: facilita o trabalho com listas (não usado ainda, mas já carregado)
# rvest: usado para web scraping (extrair informações de páginas HTML)
library(httr)
library(purrr)
library(rvest)
library(tidyverse)

# Definindo a URL da página da Wikipedia sobre a linguagem R ----
u_wiki <- "https://en.wikipedia.org/wiki/R_language"

# Fazendo a requisição GET (baixando o conteúdo da página)
r_wiki <- GET(u_wiki)

r_wiki

# Response [https://en.wikipedia.org/wiki/R_language]
# Date: 2025-10-02 22:31
# Status: 200
# Content-Type: text/html; charset=UTF-8
# Size: 450 kB

## Outra alternativa seria ler o HTML diretamente sem usar GET:
html <- read_html(u_wiki)

html
# {html_document}

# Extraindo todas as tabelas da página ----
# 1. Convertemos a resposta (r_wiki) em HTML
# 2. Selecionamos todas as tabelas
# 3. Convertendo para listas/data frames
tabelas <- r_wiki |>
  read_html() |>
  html_table()


class(tabelas)

tabela_modo_subset <- tabelas[[2]]


# Extraindo apenas tabelas que têm a classe "wikitable" ----
# Muitas páginas da Wikipedia usam essa classe para formatar tabelas

# xpath
tabelas_versao_r <- r_wiki |>
  read_html() |>
  # Selecionando as tabelas com classe = 'wikitable'
  html_elements(xpath = "//table[@class='wikitable']") |>
  # Convertendo cada tabela em data frame
  html_table() |>
  purrr::pluck(1)


# CSS path
tabelas_versao_r_css <- r_wiki |>
  read_html() |>
  # Selecionando as tabelas com classe = 'wikitable'
  html_elements(css = "table.wikitable") |>
  # Convertendo cada tabela em data frame
  html_table() |>
  purrr::pluck(1)
