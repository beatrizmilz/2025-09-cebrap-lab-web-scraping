# Carregando pacotes ----
# tidyverse: pacote que inclui ferramentas para manipulação e visualização de dados
# httr: permite fazer requisições HTTP (acessar APIs pela internet)
library(tidyverse)
library(httr)

# API Olho Vivo da SPTrans ----
# Documentação: https://www.sptrans.com.br/desenvolvedores/api-do-olho-vivo-guia-de-referencia/

# URL base da API
u_sptrans <- "https://api.olhovivo.sptrans.com.br/v2.1"

# Endpoint usado para consultar a posição dos veículos
endpoint <- "/Posicao"

# Criando a URL completa
u_sptrans_posicao <- paste0(u_sptrans, endpoint)

# Tentando fazer uma requisição GET diretamente (sem login ainda)
r_posicao <- GET(u_sptrans_posicao)

# Verificando o conteúdo da resposta
r_posicao |>
  content()


# Precisamos de uma chave de autenticação para acessar a API ----
# Essa chave é obtida no site da SPTrans ao criar uma conta de desenvolvedor.
# Dica: você pode salvar sua chave no arquivo .Renviron para não precisar colar no código.
# usethis::edit_r_environ(scope = "project")

# Aqui buscamos a chave que foi salva como variável de ambiente
api_key <- Sys.getenv("API_OLHO_VIVO")
# Alternativa (não recomendado): colocar a chave direto no código
# api_key <- "cole_a_chave_aqui"

# Fazendo o login ----
# Endpoint da API para autenticação
endpoint_login <- "/Login/Autenticar"
u_sptrans_login <- paste0(u_sptrans, endpoint_login)

# A query será uma lista
q_sptrans_login <- list(token = api_key)

# Fazendo a requisição POST
# e passando a lista criada para o argumento query
r_sptrans_login <- POST(u_sptrans_login, query = q_sptrans_login)

# Acessando o conteúdo da resposta
r_sptrans_login |>
  content()


# Agora que a sessão está autenticada, conseguimos consultar as posições ----
# Isso funciona porque o httr guarda informações da sessão nos cookies
r_posicao <- GET(u_sptrans_posicao)

# Convertendo o conteúdo da resposta para tibble
# O objeto retornado tem várias listas, sendo "l" a que contém as linhas e veículos
d_posicoes <- r_posicao |>
  content(simplifyDataFrame = TRUE) |>
  pluck("l") |>
  as_tibble()

# Dentro de cada linha (linha de ônibus) existe uma lista de veículos (vs)
d_posicoes$vs[[1]]

# Desaninhando os dados para transformar em tabela completa
# e fazendo um gráfico simples da posição dos veículos (px = longitude, py = latitude)
d_posicoes |>
  unnest(vs) |>
  ggplot(aes(x = px, y = py)) +
  geom_point() +
  coord_equal()
