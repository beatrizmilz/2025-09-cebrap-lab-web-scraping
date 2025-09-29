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

# Definindo a URL base usada pela API
u_base <- "https://brasilapi.com.br/api"


## Vamos buscar informações sobre CEPs ----
# Endpoint para consulta de CEP: https://brasilapi.com.br/api/cep/v2/{cep}

endpoint_cep <- "/cep/v2/"

# Vamos escolher um CEP para consultar (04015-051 é da região da Av. Paulista/SP)
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

# Exercício: consulte o seu próprio CEP e compare com as informações retornadas pela API.

## Exemplo 2 - Explorando a Tabela FIPE ----
# A Tabela FIPE mostra os preços médios de veículos no Brasil.

### 2.1 - Consultando as marcas de carro disponíveis ----
# Endpoint da API: https://brasilapi.com.br/api/fipe/marcas/v1/{tipoVeiculo}

endpoint_fipe <- "/fipe/marcas/v1/"
tipo_veiculo <- "carros"
u_fipe <- paste0(u_base, endpoint_fipe, tipo_veiculo)

# Fazendo a requisição para buscar as marcas de carros
r_fipe <- GET(u_fipe)

# Vendo o conteúdo retornado (em JSON)
content(r_fipe)

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

r_fipe


### 2.2 - Consultando as tabelas de referência da FIPE ----
# Essas tabelas representam diferentes meses/anos que a FIPE disponibiliza.

# Endpoint da API das tabelas FIPE
endpoint_fipe_tabelas <- "/fipe/tabelas/v1/"

# Montando a URL
u_fipe_tabelas <- paste0(u_base, endpoint_fipe_tabelas)

# Fazendo a requisição GET
r_fipe_tabelas <- GET(u_fipe_tabelas)

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


### 2.3 - Consultando o preço de um veículo na Tabela FIPE ----

# Parte 1 - Preço atual ----
# Endpoint para consultar preço: /fipe/preco/v1/{codigoDoVeiculo}

endpoint_preco <- "/fipe/preco/v1/"

# Código do veículo
cod_veiculo <- "025265-4"

# Montando a URL completa
u_preco <- paste0(u_base, endpoint_preco, cod_veiculo)

# Fazendo a requisição GET
r_preco <- GET(u_preco)

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

# Convertendo o resultado em tibble
tab_preco_antigo <- content(r_preco_antigo, simplifyDataFrame = TRUE) |>
  tibble::as_tibble()

# Exibindo o preço antigo
tab_preco_antigo
