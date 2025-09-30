# Instalar pacotes -------------------
install.packages(c(
  # Pacotes de limpeza, manipulação, iteração
  "tidyverse",
  "fs",
  "janitor",
  "cli",

  # Pacotes usados para acessar a web e extrair informações do HTML
  "httr",
  "rvest",
  "xml2",

  # Pacotes necessários para os exemplos de HTML dinâmico
  "RSelenium"
))


# Carregando pacotes necessários ----
# httr: usado para fazer requisições HTTP (como acessar APIs pela internet)
# jsonlite: usado para trabalhar com dados em formato JSON
library(httr)
library(jsonlite)
library(tidyverse)

# Exemplo 1 - Brasil API ----
# A Brasil API é um projeto que oferece dados públicos sobre o Brasil
# (estados, cidades, CEPs, dados da tabela FIPE, etc.)
# Link da documentação: https://brasilapi.com.br/

# URL Base: https://brasilapi.com.br/api
# Endpoint: /cep/v1/
# Parâmetro: {cep}

paste("a", "b", "c")
paste0("a", "b", "c") # cola textos sem deixar espaço

# Definindo a URL base usada pela API
u_base <- "https://brasilapi.com.br/api"


## Vamos buscar informações sobre CEPs ----
# Endpoint para consulta de CEP: https://brasilapi.com.br/api/cep/v2/{cep}

endpoint_cep <- "/cep/v2/"

# Vamos escolher um CEP para consultar
cep <- "04015051"

# Montando a URL completa juntando base + endpoint + CEP
u_cep <- paste0(u_base, endpoint_cep, cep)
u_cep

# Fazendo a requisição GET (buscando os dados na API)
r_cep <- GET(u_cep)

# Verificando a resposta da requisição
r_cep
# Se aparecer "Status: 200", quer dizer que deu certo.
# O "Content-Type: application/json" indica que os dados estão no formato JSON.

r_cep

# como é uma lista, podemos usar o $ para explorar
r_cep$status_code

# Dica: você pode abrir o JSON no navegador para ver melhor
browseURL(u_cep)

# Pegando o conteúdo da resposta (em formato de lista no R)
conteudo_cep <- content(r_cep)

# Exibindo os dados do CEP (como lista)
conteudo_cep

# Acessando elementos específicos da lista
conteudo_cep$cep
conteudo_cep$state
conteudo_cep$city
conteudo_cep$neighborhood
conteudo_cep$street
conteudo_cep$service


# criando uma tabela/tibble com esses dados!
tab_cep <- tibble(
  cep = conteudo_cep$cep,
  estado = conteudo_cep$state,
  cidade = conteudo_cep$city,
  bairro = conteudo_cep$neighborhood,
  rua = conteudo_cep$street
)

# Exercício: consulte o seu próprio CEP e compare com as informações retornadas pela API.

## Exemplo 2 - Explorando a Tabela FIPE ----
# A Tabela FIPE mostra os preços médios de veículos no Brasil.

### 2.1 - Consultando as marcas de carro disponíveis ----
# Endpoint da API: https://brasilapi.com.br/api/fipe/marcas/v1/{tipoVeiculo}

u_base

endpoint_fipe <- "/fipe/marcas/v1/"
tipo_veiculo <- "carros"
u_fipe <- paste0(u_base, endpoint_fipe, tipo_veiculo)

# Fazendo a requisição para buscar as marcas de carros
r_fipe <- GET(u_fipe)

# Response [https://brasilapi.com.br/api/fipe/marcas/v1/carros]
# Date: 2025-09-30 00:11
# Status: 200
# Content-Type: application/json; charset=utf-8
# Size: 3.28 kB

# Vendo o conteúdo retornado (em JSON)
c_fipe <- content(r_fipe)

c_fipe
length(c_fipe)


# converter json para tibble
df_fipe <- content(r_fipe, simplifyDataFrame = TRUE)
tbl_fipe <- as_tibble(df_fipe)


# Convertendo o JSON diretamente para data frame/tibble (estrutura de tabela no R)
tabela_marcas_fipe <- content(r_fipe, simplifyDataFrame = TRUE) |>
  tibble::as_tibble()


# Criando uma pasta para salvar os dados localmente
fs::dir_create("dados/brasilapi")

# Fazendo a requisição e salvando o resultado em um arquivo JSON
r_fipe <- GET(
  u_fipe,
  write_disk("dados/brasilapi/fipe_marcas.json", overwrite = TRUE)
)

# Ainda permite acessar o resultado da requisição
r_fipe |> content(simplifyDataFrame = TRUE) |> tibble()
# A tibble: 103 × 2
# nome        valor
# <chr>       <chr>
#   1 Acura       1
# 2 Agrale      2
# 3 Alfa Romeo  3
# 4 AM Gen      4
# 5 Asia Motors 5
# 6 Audi        6
# 7 BMW         7
# 8 BRM         8
# 9 Cadillac    10
# 10 CBT Jipe    11
# # ℹ 93 more rows
# # ℹ Use `print(n = ...)` to see more rows

### 2.2 - Consultando as tabelas de referência da FIPE ----
# Essas tabelas representam diferentes meses/anos que a FIPE disponibiliza.

# Endpoint da API das tabelas FIPE
endpoint_fipe_tabelas <- "/fipe/tabelas/v1/"

# Montando a URL
u_fipe_tabelas <- paste0(u_base, endpoint_fipe_tabelas)

# Fazendo a requisição GET
r_fipe_tabelas <- GET(u_fipe_tabelas)

# Response [https://brasilapi.com.br/api/fipe/tabelas/v1]
# Date: 2025-09-30 00:27
# Status: 200
# Content-Type: application/json; charset=utf-8
# Size: 10.7 kB

# Verificando o status da requisição
r_fipe_tabelas

mes_referencia_tabela_fipe <- r_fipe_tabelas |>
  # Convertendo o conteúdo da resposta para um data frame
  content(simplifyDataFrame = TRUE) |>
  # Convertendo o data frame para um tibble
  tibble::as_tibble()

# O resultado é um tibble com os períodos de referência disponíveis,
# e o código de cada um deles.
mes_referencia_tabela_fipe |>
  print(n = 100)


# FALTA BUSCAR A TABELA COM OS CÓDIGOS DOS CARROS!-----

endpoint_cod_veiculo <- "/fipe/veiculos/v1/"
cod_marca <- "carros/23/" # 23 é referente à chevrolet
u_cod_veiculo <- paste0(u_base, endpoint_cod_veiculo, cod_marca)

r_cod_veiculo <- GET(u_cod_veiculo)

# Response [https://brasilapi.com.br/api/fipe/veiculos/v1/carro/23]
# Date: 2025-09-30 00:49
# Status: 400
# Content-Type: application/json; charset=utf-8
# Size: 86 B

tbl_cod_veiculo <- content(r_cod_veiculo, simplifyDataFrame = TRUE) |>
  tibble::tibble()

tbl_cod_veiculo
# A tibble: 548 × 1
# modelo
# <chr>
#   1 A-10 2.5/4.1
# 2 A-10 De Luxe 2.5/4.1
# 3 A-20 Custom Std. CD/ De Luxe CD
# 4 A-20 Custom/ C-20 Luxe 4.1
# 5 A-20 Custom/ C-20 S 4.1
# 6 AGILE LT 1.4 MPFI 8V FlexPower 5p
# 7 AGILE LTZ 1.4 MPFI 8V FlexPower 5p
# 8 AGILE LTZ EASYTRONIC 1.4 8V FlexPower 5p
# 9 AGILE LTZ EFFECT 1.4 8V FlexPower 5p Mec
# 10 AGILE LTZ EFFECT EASYTR.1.4 8V FlexP. 5p
# # ℹ 538 more rows
# # ℹ Use `print(n = ...)` to see more rows

# retorna apenas o modelo, sem o código T_T

### 2.3 - Consultando o preço de um veículo na Tabela FIPE ----

# Parte 1 - Preço atual ----
# Endpoint para consultar preço: /fipe/preco/v1/{codigoDoVeiculo}

endpoint_preco <- "/fipe/preco/v1/"

# Código do veículo
cod_veiculo <- "025265-4" # Kwid

# Montando a URL completa
u_preco <- paste0(u_base, endpoint_preco, cod_veiculo)

# Fazendo a requisição GET
r_preco <- GET(u_preco)

# Response [https://brasilapi.com.br/api/fipe/preco/v1/025265-4]
# Date: 2025-09-30 00:33
# Status: 200
# Content-Type: application/json; charset=utf-8
# Size: 1.42 kB

# Convertendo a resposta em tibble
tab_preco_atual <- content(r_preco, simplifyDataFrame = TRUE) |>
  tibble::as_tibble()

# Exibindo o preço atual
tab_preco_atual


# Parte 2 - Consultando preço em outro mês de referência ----
# Precisamos passar o código da tabela de referência como parâmetro

query_fipe <- list(
  "tabela_referencia" = "249" # 249 corresponde a dezembro/2019
)

# Fazendo a requisição GET com o parâmetro da tabela
r_preco_antigo <- GET(u_preco, query = query_fipe)

# Response [https://brasilapi.com.br/api/fipe/preco/v1/025265-4?tabela_referencia=249]
# Date: 2025-09-30 00:39
# Status: 200
# Content-Type: application/json; charset=utf-8
# Size: 1.13 kB

# Convertendo o resultado em tibble
tab_preco_antigo <- content(r_preco_antigo, simplifyDataFrame = TRUE) |>
  tibble::as_tibble()

# Exibindo o preço antigo
tab_preco_antigo |> View()
