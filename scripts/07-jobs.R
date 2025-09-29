# Carregando pacotes necessários ----
library(httr) # Para fazer requisições HTTP
library(rvest) # Para extrair informações de páginas HTML
library(purrr) # Para trabalhar com listas e mapear funções
library(dplyr) # Para manipulação de dados

# URL do site Fake Jobs
u_rp <- "https://realpython.github.io/fake-jobs/"
r_rp <- GET(u_rp)

## usando stringr
# r_rp |>
#   read_html() |>
#   html_elements(xpath = "//footer[@class='card-footer']/a") |>
#   html_attr("href") |>
#   stringr::str_subset("github")

## usando xpath
links <- r_rp |>
  read_html() |>
  html_elements(
    xpath = "//footer[@class='card-footer']/a[contains(@href,'github')]"
  ) |>
  html_attr("href")

# Lendo novamente o HTML para extrair os cards de vagas
h_rp <- r_rp |>
  read_html()

# Selecionando todos os cards de vagas (cada vaga está dentro de um <div class='card'>)
cards <- h_rp |>
  html_elements(xpath = "//div[@class='card']")

# Exemplo de um card específico
card <- cards[42]

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

# Testando a função com o 10º card
processar_card(cards[10])

# Processando todos os cards ----
da_cards <- map(cards, processar_card) |> # aplica a função a todos os cards
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

# Adicionando a descrição ao tibble final ----
da_cards_desc <- da_cards |>
  mutate(desc = map_chr(link, pegar_descricao, .progress = TRUE)) # percorre todos os links com barra de progresso

# Resultado final
da_cards_desc
