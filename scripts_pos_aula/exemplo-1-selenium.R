# ATUALIZAR ESSE SCRIPT NO SLIDE!
# Carregar o pacote RSelenium
library(RSelenium)

# Iniciar o servidor do RSelenium. Ele irá abrir uma janela do Firefox
# Essa etapa pode demorar um pouco
drv <- rsDriver(browser = "firefox", verbose = FALSE, chromever = NULL,
                phantomver = NULL)

# descobrindo os métodos!
# drv$client$


# Acessando uma URL
drv$client$navigate("https://google.com")

# Procurando um elemento: no caso, o campo de busca
elem <- drv$client$findElement("xpath", "//textarea")

# Escrevendo no campo de busca
elem$sendKeysToElement(list("Beatriz Milz", key = "enter"))

# Esperar um pouco para a página carregar
Sys.sleep(2)

# Capturar a tela
drv$client$screenshot(file = "screenshot_selenium.png")

# fechar
drv$client$quit()
