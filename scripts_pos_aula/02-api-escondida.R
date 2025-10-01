# Carregando o pacote necessário ----
# httr: permite fazer requisições HTTP (acessar APIs pela internet)
library(httr)
library(tidyverse)

# Montando a requisição GET ----

# https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/2025-09-29

# Definindo o dia que será usado na consulta (hoje)
dia <- Sys.Date()

# URL base da API da Sabesp
u_base <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"

# Criando a URL completa juntando a base com a data
u_dia <- paste0(u_base, dia)

# Fazendo a requisição GET (buscando os dados na API)
r_dia <- GET(u_dia)
r_dia
r_dia$status_code

# Response [https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/2025-09-30]
# Date: 2025-09-30 22:31
# Status: 200
# Content-Type: application/json; charset=utf-8
# Size: 10.9 kB

# Extraindo o conteúdo da resposta em formato de lista/data frame
l_dia <- content(r_dia, simplifyDataFrame = TRUE)

content(r_dia, simplifyDataFrame = TRUE)

l_dia$ReturnObj$sistemas

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


# função -------------------

# o que a função precisa?
# nome
# function(){}
# argumentos - o que podemos passar para a função?
# o código que ela vai executar

# nome_da_funcao <- function(argumento = "valor_padrao") {
#   # o que a função vai fazer
#   # códigos que serão executados
# }

# Exemplo mais simples: converter data do BR para R ----
"30/09/2025"

as.Date("30/09/2025", format = "%d/%m/%Y")

converter_data_br <- function(data_formato_br) {
  as.Date(data_formato_br, format = "%d/%m/%Y")
}

converter_data_br("15/02/1993")


# Criando uma função para baixar os dados de um dia específico ----
sabesp_baixar_dia <- function(dia) {
  # Checar se a data está no formato esperado!!

  u_base <- "https://mananciais.sabesp.com.br/api/Mananciais/ResumoSistemas/"
  # Monta a URL completa com a data fornecida
  u_dia <- paste0(u_base, dia)
  # Faz a requisição GET
  r_dia <- GET(u_dia)

  # CHECAR STATUS CODE

  if (r_dia$status_code == 200) {
    # Extrai o conteúdo da resposta
    l_dia <- content(r_dia, simplifyDataFrame = TRUE)
    # Acessa e organiza os dados em tibble
    d_dia <- l_dia |>
      purrr::pluck("ReturnObj", "sistemas") |>
      tibble::tibble() |>
      janitor::clean_names()
    return(d_dia)
  } else {
    stop(paste("Status code é diferente de 200: ", r_dia$status_code))
  }
}

# Testando a função com uma data específica ----
sabesp_baixar_dia("2025-09-29")

sabesp_baixar_dia("sduhfaiusdhfiuhasd")
# Error in sabesp_baixar_dia("sduhfaiusdhfiuhasd") :
#   Status code é diferente de 200:  404

# iteração - deu erro
conjunto_de_datas <- paste0("2025-09-", 10:20)

l_conjunto_datas <- purrr::map(
  .x = conjunto_de_datas,
  .f = sabesp_baixar_dia,
  .progress = TRUE
)

df_conjunto_datas <- l_conjunto_datas |> purrr::list_rbind()
