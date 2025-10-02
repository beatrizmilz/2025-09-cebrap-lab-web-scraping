# Carregar o pacote RSelenium
library(RSelenium)

# Iniciar o servidor do RSelenium. Ele irá abrir uma janela do Firefox
# Essa etapa pode demorar um pouco
drv <- rsDriver(
  browser = "firefox",
  verbose = FALSE,
  chromever = NULL,
  phantomver = NULL
)

# ABRINDO O NAVEGADOR ---------------------------------------------------------
# Acessando uma URL
drv$client$navigate("https://google.com")

# Procurando um elemento: no caso, o campo de busca
elem <- drv$client$findElement("xpath", "//textarea[@name='q']")

# Escrevendo no campo de busca
elem$sendKeysToElement(list("Cebrap lab"))
# Clicando enter
elem$sendKeysToElement(list(key = "enter"))


# Tem um campo de autenticação. manualmente.

# Página de resultados ----------------------------
elem_click <- drv$client$findElement("xpath", "//h3")

# Clicar no elemento
elem_click$clickElement()

# voltar para a página anterior?
# drv$client$goBack()

# Esperar um pouco para a página carregar
Sys.sleep(2)

# Capturar a tela
drv$client$screenshot(file = "screenshot_selenium.png")

# Buscando o código fonte (HTML) da página

lista_page_source <- drv$client$getPageSource()[[1]]

# Salvando o código fonte em um arquivo local
readr::write_lines(lista_page_source, "codigo-da-pagina.html")

# extraindo as informações da página ------------
library(rvest)
html_pagina <- lista_page_source |>
  read_html()

# Buscando os links
tabelas <- html_pagina |>
  html_table()

titulos <- html_pagina |>
  html_elements("h3") |>
  html_text() |>
  magrittr::extract(-1) # o primeiro elemento da lista não é útil para nós


# transformar lista em uma tabela
cursos_cebrap <- tabelas |>
  # só as primeiras três tabelas são úteis
  magrittr::extract(c(1, 2, 3)) |>
  purrr::set_names(titulos) |>
  purrr::list_rbind(names_to = "trilha") |>
  dplyr::rename(nome_do_curso = X1, data_do_curso = X2, ministrante = X3)


cursos_cebrap

# Fechar o servidor
drv$client$quit()
