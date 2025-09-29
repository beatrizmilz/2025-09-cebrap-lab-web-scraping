# Carregando pacotes ----
# xml2: usado para ler e manipular arquivos HTML e XML
# rvest: facilita a extração de informações de páginas web (web scraping)
library(xml2)
library(rvest)

# Download do arquivo HTML de exemplo ----
# Criamos uma pasta para armazenar os dados
fs::dir_create("dados/")

# Fazemos o download de um arquivo HTML de exemplo
download.file(
  url = "https://raw.githubusercontent.com/beatrizmilz/2025-09-cebrap-lab-web-scraping/refs/heads/main/dados/html_exemplo.html",
  destfile = "dados/html_exemplo.html"
)

# Ler o HTML ----
# Lemos o arquivo e guardamos em um objeto do tipo documento HTML
html <- read_html("dados/html_exemplo.html")

# Extraindo tags específicas ----
# Procurando todas as tags <p> dentro do body
xml_find_all(html, "/html/body/p")

# Outra forma de buscar todas as tags <p> (usando XPath "//p")
nodes <- xml_find_all(html, "//p")

# Pegando o primeiro nó da lista
nodes[[1]]

# Pegando apenas o primeiro nó encontrado (forma direta)
primeiro <- xml_find_first(html, "//p")

# Extraindo o texto que está dentro das tags <p> ----
textos <- xml_text(nodes)

# Extraindo atributos das tags ----
# Aqui vemos todos os atributos associados a cada tag <p>
xml_attrs(nodes)

# Extraindo apenas o atributo "style"
xml_attr(nodes, "style")


# Usando funções do pacote rvest (atalhos mais práticos) ----

# Selecionando todos os nós <p>
nodes <- html_elements(html, xpath = "//p")

# Selecionando apenas o primeiro <p>
primeiro <- html_element(html, xpath = "//p")

# Extraindo apenas o texto de todos os <p>
html_text(nodes)

# Extraindo o valor do atributo "style" de todos os <p>
html_attr(nodes, "style")
