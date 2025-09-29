# Carregando o pacote necessário ----
# httr: permite fazer requisições HTTP (acessar APIs pela internet)
library(httr)

# Montando a requisição GET ----
# Definindo o dia que será usado na consulta (hoje)
dia <- Sys.Date()

# URL base da API da Sabesp
u_base <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"

# Criando a URL completa juntando a base com a data
u_dia <- paste0(u_base, dia)

# Fazendo a requisição GET (buscando os dados na API)
r_dia <- GET(u_dia)

# Extraindo o conteúdo da resposta em formato de lista/data frame
l_dia <- content(r_dia, simplifyDataFrame = TRUE)

# O objeto retornado é uma lista aninhada (listas dentro de listas).
# Aqui acessamos diretamente a parte que contém os dados dos sistemas.
l_dia$ReturnObj$sistemas


# Transformando os dados em um tibble ----
d_dia <- l_dia |>
  # Acessa o item da lista que contém os dados dos sistemas
  purrr::pluck("ReturnObj", "sistemas") |>
  # Converte em tibble (tabela organizada)
  tibble::tibble() |>
  # Limpa os nomes das colunas (deixa em minúsculas e sem acentos/espaços)
  janitor::clean_names()


# Criando uma função para baixar os dados de um dia específico ----
sabesp_baixar_dia <- function(dia) {
  u_base <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"
  # Monta a URL completa com a data fornecida
  u_dia <- paste0(u_base, dia)
  # Faz a requisição GET
  r_dia <- GET(u_dia)
  # Extrai o conteúdo da resposta
  l_dia <- content(r_dia, simplifyDataFrame = TRUE)
  # Acessa e organiza os dados em tibble
  d_dia <- l_dia |>
    purrr::pluck("ReturnObj", "sistemas") |>
    tibble::tibble() |>
    janitor::clean_names()
  d_dia
}

# Testando a função com uma data específica ----
sabesp_baixar_dia("2025-09-29")
