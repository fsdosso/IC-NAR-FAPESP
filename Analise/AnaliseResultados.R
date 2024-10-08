# Carregando bibliotecas necessárias
library(Metrics)  # Para calcular RMSE e MAE

# Definindo o diretório onde estão os arquivos CSV
diretorio <- "acoes_preditas_2/"

# Listando todos os arquivos CSV no diretório que começam com "Previsão_"
arquivos_csv <- list.files(path = diretorio, pattern = "^Previsao_.*\\.csv$", full.names = TRUE)

# Inicializando um data frame para armazenar os resultados
resultados <- data.frame(codigo = character(),
                         RMSE_AR = numeric(),
                         RMSE_SETAR = numeric(),
                         RMSE_LSTAR = numeric(),
                         MAE_AR = numeric(),
                         MAE_SETAR = numeric(),
                         MAE_LSTAR = numeric(),
                         stringsAsFactors = FALSE)

# Função para processar cada arquivo CSV
metricas <- function(arquivo) {
    # Extraindo o código do nome do arquivo
    sigla <- gsub("Previsao_|\\.csv", "", basename(arquivo))
    
    # Lendo o arquivo CSV
    dados <- read.csv(arquivo)
    
    # Filtrando os dados com ACF == 1 e BDS == 1
    dados_filtrados <- subset(dados, ACF == 1 & BDS_5 == 1)
    
    # Calculando RMSE e MAE para os modelos AR, SETAR e LSTAR
    rmse_ar <- rmse(dados_filtrados$TRUE_RETORNO, dados_filtrados$AR)
    rmse_setar <- rmse(dados_filtrados$TRUE_RETORNO, dados_filtrados$SETAR)
    rmse_lstar <- rmse(dados_filtrados$TRUE_RETORNO, dados_filtrados$LSTAR)
    
    mae_ar <- mae(dados_filtrados$TRUE_RETORNO, dados_filtrados$AR)
    mae_setar <- mae(dados_filtrados$TRUE_RETORNO, dados_filtrados$SETAR)
    mae_lstar <- mae(dados_filtrados$TRUE_RETORNO, dados_filtrados$LSTAR)
    
    # Adicionando os resultados ao data frame
    resultados <<- rbind(resultados, data.frame(acao = sigla,
                                                RMSE_AR = rmse_ar,
                                                RMSE_SETAR = rmse_setar,
                                                RMSE_LSTAR = rmse_lstar,
                                                MAE_AR = mae_ar,
                                                MAE_SETAR = mae_setar,
                                                MAE_LSTAR = mae_lstar,
                                                stringsAsFactors = FALSE))
}

# Aplicando a função a todos os arquivos CSV
lapply(arquivos_csv, metricas)


# Extrai somente os resultados não repetidos
resultados <- unique(resultados)

library(tidyverse)

resultados <- resultados %>% filter_all(all_vars(!is.nan(.)))

# Guarda os resultados como números de 6 dígitos
resultados$RMSE_AR <- format(resultados$RMSE_AR, digits = 6, nsmall = 6)
resultados$RMSE_SETAR <- format(resultados$RMSE_SETAR, digits = 6, nsmall = 6)
resultados$RMSE_LSTAR <- format(resultados$RMSE_LSTAR, digits = 6, nsmall = 6)
resultados$MAE_AR <- format(resultados$MAE_AR, digits = 6, nsmall = 6)
resultados$MAE_SETAR <- format(resultados$MAE_SETAR, digits = 6, nsmall = 6)
resultados$MAE_LSTAR <- format(resultados$MAE_LSTAR, digits = 6, nsmall = 6)

# Exporta os resultados como um arquivo csv
write.csv(resultados, "Resultados.csv")

