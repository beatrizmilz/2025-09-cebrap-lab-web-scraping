# Carregando pacotes necessários ----
library(httr) # Para fazer requisições HTTP
library(rvest) # Para extrair informações de páginas HTML
library(purrr) # Para trabalhar com listas e mapear funções
library(dplyr) # Para manipulação de dados

# URL do site Fake Jobs
u_rp <- "https://realpython.github.io/fake-jobs/"
r_rp <- GET(u_rp)

# Response [https://realpython.github.io/fake-jobs/]
# Date: 2025-10-03 00:22
# Status: 200
# Content-Type: text/html; charset=utf-8
# Size: 104 kB
# <!DOCTYPE html>

# Links das vagas -----------------------------------------------
## usando stringr
links <- r_rp |>
  read_html() |>
  html_elements(xpath = "//footer[@class='card-footer']") |>
  html_elements(xpath = "//a") |>
  html_attr("href") |>
  stringr::str_subset("github")

## usando xpath
links <- r_rp |>
  read_html() |>
  html_elements(
    xpath = "//footer[@class='card-footer']/a[contains(@href,'github')]"
  ) |>
  html_attr("href")

# Lendo novamente o HTML para extrair os cards de vagas ----------------
h_rp <- r_rp |>
  read_html()

# Selecionando todos os cards de vagas (cada vaga está dentro de um <div class='card'>)
cards <- h_rp |>
  html_elements(xpath = "//div[@class='card']")

# exemplo de como selecionar o mesmo elemento (card) usando
# o seletor de css
h_rp |>
  html_elements(css = "div.card")

# Exemplo de um card específico
card_exemplo <- cards[42]

card_exemplo

# Função para processar um card individual ----
# Extrai posição, empresa, local e data
processar_card <- function(card) {
  xpaths <- c(".//h2", ".//h3", ".//p[@class='location']", ".//time") # caminhos XPath para cada informação

  xpaths |>
    map(\(x) html_elements(card, xpath = x)) |> # encontra os elementos correspondentes
    map_chr(html_text) |> # extrai o texto de cada elemento
    stringr::str_squish() |> # remove espaços extras
    set_names(c("posicao", "empresa", "local", "dia")) |> # nomeia as colunas
    tibble::enframe() # transforma em tibble com colunas name/value
}

processar_card(card_exemplo)

# Testando a função com o 10º card
processar_card(cards[99])

# Processando todos os cards ----
list_cards <- map(cards, processar_card, .progress = TRUE) # aplica a função a todos os cards

da_cards <- list_cards |>
  list_rbind(names_to = "id_card") |> # combina todos os tibbles em um só
  tidyr::pivot_wider(names_from = name, values_from = value) |> # reorganiza as colunas
  mutate(link = links) # adiciona os links correspondentes

# Função para extrair a descrição detalhada de cada vaga a partir do link ----
pegar_descricao <- function(link) {
  link |>
    read_html() |>
    html_element(xpath = "//div[@class='content']/p") |> # seleciona o parágrafo de descrição
    html_text() # extrai o texto
}

# experimentou a função
pegar_descricao(links[99])

# Adicionando a descrição ao tibble final ----
da_cards_desc <- da_cards |>
  mutate(
    description = map_chr(.x = link, .f = pegar_descricao, .progress = TRUE)
  ) # percorre todos os links com barra de progresso

# Resultado final
da_cards_desc
