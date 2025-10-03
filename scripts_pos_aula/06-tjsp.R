# Carregando pacotes ----
# tidyverse: manipulação de dados (dplyr, stringr, etc.)
# httr: permite fazer requisições HTTP (GET, POST) para APIs ou páginas
# rvest: facilita extrair informações de páginas HTML
# xml2: usado para navegar na estrutura do HTML
library(tidyverse)
library(httr)
library(rvest)
library(xml2)

# Exemplo: consultas de jurisprudência do TJSP ----
# Site: https://esaj.tjsp.jus.br/cjsg/resultadoCompleta.do
# Passos manuais:
# 1. Acessar o site no navegador
# 2. Abrir o DevTools (Network)
# 3. Fazer uma busca e observar a requisição que aparece no "Network"
# 4. Copiar as informações (POST, parâmetros) para reproduzir no R

# Fazendo uma requisição POST ----
# Essa requisição corresponde à busca livre no campo do site
r_tjsp <- httr::POST(
  "https://esaj.tjsp.jus.br/cjsg/resultadoCompleta.do",
  body = list(
    dados.buscaInteiroTeor = "test", # O que escrevemos no campo da pesquisa livre
    dados.origensSelecionadas = "T"
  )
)

r_tjsp

# Response [https://esaj.tjsp.jus.br/cjsg/resultadoCompleta.do]
# Date: 2025-10-02 22:55
# Status: 200
# Content-Type: text/html;charset=UTF-8
# Size: 84.1 kB

# É necessário fazer um iterador para pegar as outras páginas.

# Status 200, Conteúdo text - HTML
# Essa requisição retorna apenas a primeira página de resultados.

# Requisição GET para mudar de página ----
# Aqui pedimos a página 2 (a URL espera o número da página como parâmetro)
r_tjsp_pag <- httr::GET(
  "https://esaj.tjsp.jus.br/cjsg/trocaDePagina.do",
  query = list(
    tipoDeDecisao = "A", # parâmetro fixo que apareceu no network
    pagina = 2, # número da página desejada
    conversationId = "" # aparece vazio na requisição capturada
  )
)
r_tjsp_pag

# Response [https://esaj.tjsp.jus.br/cjsg/trocaDePagina.do?tipoDeDecisao=A&pagina=2&conversationId=]
# Date: 2025-10-02 22:57
# Status: 200
# Content-Type: text/html;charset=UTF-8
# Size: 138 kB

# A resposta vem como HTML.
# Agora vamos extrair as tabelas que contêm os resultados ----
tab_html <- r_tjsp_pag |>
  read_html(encoding = "UTF-8") |> # garante leitura correta de acentos
  # Procurando pelas tabelas que ficam dentro de <tr class="fundocinza1">
  xml2::xml_find_all("//tr[@class='fundocinza1']")


# Pegamos a primeira tabela (exemplo) e transformamos em tibble
tab_tibble <- tab_html[[1]] |>
  html_table() |> # converte tabela HTML para data.frame
  mutate(X1 = str_squish(X1)) |> # remove espaços extras do texto
  separate(X1, sep = ": ", into = c("info", "resposta"), extra = "merge")


tab_pagina <- tab_html |>
  html_table() |>
  purrr::list_rbind(names_to = "item_lista")
