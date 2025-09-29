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

# A resposta vem como HTML.
# Agora vamos extrair as tabelas que contêm os resultados ----
tab_html <- r_tjsp_pag |>
  read_html(encoding = "UTF-8") |> # garante leitura correta de acentos
  # Procurando pelas tabelas que ficam dentro de <tr class="fundocinza1">
  xml2::xml_find_all("//tr[@class='fundocinza1']//table")

# Pegamos a primeira tabela (exemplo) e transformamos em tibble
tab_tibble <- tab_html[[1]] |>
  html_table() |> # converte tabela HTML para data.frame
  as_tibble() |> # converte para tibble (tidyverse)
  mutate(X1 = str_squish(X1)) # remove espaços extras do texto
