library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(tsDyn)
library(forecast)
library(aTSA)
library(tseries)

dados <- read_csv("/home/felipe/Documentos/IC/Codigo/Previsao/Expandido/dados_nyse_diario_expandido.csv")

verifica_primeiro_acf <- function(time_series){
    #acessa o primeiro acf da série
    acf_result <- stats::acf(time_series, plot = FALSE)
    acf_1 = acf_result$acf[2]
    
    # Encontra o ponto de decisão
    x = qnorm(1 - 0.025) / sqrt((length(time_series)))
    
    
    # Verifica se é significante ou não
    significante <- ifelse(acf_1 > x || acf_1 < -x , 1, 0)
    
    return(significante) #retorna 1 ou 0
}



# Função que realiza o teste BDS e retorna se pvalor<0.05
bds_test <- function(ts, m = 2) {
    # Garante que não há nenhum valor faltante
    ts <- na.omit(ts)
    
    sd_ts <- sd(ts)
    
    # Define um intervalo válido para eps
    eps <- seq(0.5 * sd_ts, 2 * sd_ts, length.out = 4)
    
    bds_result <- tseries::bds.test(ts, m = m, eps = eps)
    
    # Extrai o pvalor 
    pvalue <- bds_result$p.value
    
    significante <- ifelse(any(pvalue < 0.05), 1, 0)
}


# Substitui todas intâncias de "-" por NA
dados[dados == "-"] <- NA

# Calcula o número de valores não NA para cada coluna
non_na_counts <- colSums(!is.na(dados))

# Ordena cada coluna pelo número de valores não NA de forma crescente
sorted_columns <- names(sort(non_na_counts))

# Cria um vetor com o nome das colunas ordenadas
colunas <- sorted_columns




for (j in 1:length(colunas)) { # Para cada ação é feito o seguinte:
    # Imprime no console a seguinte mensagem
    cat("Indice atual é ", indice_atual, "\n")
    
    # Extrai o nome da ação do vetor colunas
    col <- colunas[j]
    
    # Realiza as transformações necessárias na ação
    df <- dados %>% select("Data", col) %>% as_tibble()
    df[[col]] <- as.double(df[[col]])
    df <- df %>% drop_na()
    
    # Transforma a ação no seu retorno
    df$Return <- 100 * log(df[[col]] / lag(df[[col]]))
    df <- df[-1,]
    
    # Exclui qualquer valor faltante
    retornos <- na.omit(df$Return)
    
    # Calcula o tamanho da janela (window size)
    ws <- floor(length(retornos) * 0.3)
    
    # Cria os vetores para que possa armazenar os valores preditos
    AR_1 <- numeric(length = ws)
    SETAR <- numeric(length = ws)
    LSTAR <- numeric(length = ws)
    bds <- numeric(length = ws)
    bds_3 <- numeric(length = ws)
    bds_4 <- numeric(length = ws)
    bds_5 <- numeric(length = ws)
    acf <- numeric(length = ws)
    
    error_occurred <- FALSE
    
    for (i in 0:(ws - 1)) { # Loop de estimação de Rolling Window
        if (error_occurred) break # se ocorrer um erro, encerra o loop
        
        # Imprime a seguinte mensagem no console
        cat("Iteração: ", i + 1, "\n")
        
        # A janela percorre a série da seguinte forma
        ns <- length(retornos) - ws
        r <- retornos[1 + i:ns + i]
        
        # Estima modelo AR(1) e guarda no vetor o valor predito
        ar <- arima(r, order = c(1, 0, 0))
        pred_ar <- predict(ar, n.ahead = 1)[1]
        AR_1[1 + i] <- unlist(pred_ar)
        
        # Estima SETAR(2, 1, 1) e guarda o proximo valor predito
        setar_result <- tryCatch({
            setr <- tsDyn::setar(r, m = 2, thDelay = 1, trace = TRUE, include = "const", common = "none")
            predict(setr, n.ahead = 1)[1]
        }, error = function(e) {
            message("Error in SETAR: ", e$message)
            error_occurred <<- TRUE
            return(NA)
        }) # Caso ocorra algum erro de convergência, o loop é interrompido
        
        if (error_occurred) break
        SETAR[1 + i] <- setar_result
        
        # Estima LSTAR(2, 1, 1) e guarda o proximo valor predito
        lstar_result <- tryCatch({
            lstr <- tsDyn::lstar(r, trace = TRUE, include = "const", m = 2, thDelay = 1)
            predict(lstr, n.ahead = 1)[1]
        }, error = function(e) {
            message("Error in LSTAR: ", e$message)
            error_occurred <<- TRUE
            return(NA)
        }) # Caso ocorra algum erro de convergência, o loop é interrompido
        
        if (error_occurred) break
        LSTAR[1 + i] <- lstar_result
        
        # Calcula o primeiro acf e verifica se é significante
        acf[1 + i] <- verifica_primeiro_acf(r)
        # Calcula o teste BDS
        bds[1 + i] <- bds_test_majority(r)
        bds_3[i + 1] <- bds_test(r, 3)
        bds_4[i+ 1] <- bds_test(r, 4)
        bds_5[i + 1] <- bds_test(r, 5)
    }
    
    if (error_occurred){
        cat("Houve um problema de covergência no lstar() ou setar() \n")
        next
    }
    # Valores verdadeiros da série são armazenados no vetor
    true_retornos <- retornos[(ns + 1):length(retornos)]
    
    # Cria um data frame com os vetores
    predicoes <- data.frame(AR = AR_1, SETAR = SETAR, LSTAR = LSTAR,
                            TRUE_RETORNO = true_retornos, ACF = acf, BDS = bds,
                            BDS_3 = bds_3, BDS_4 = bds_4, BDS_5 = bds_5)
    
    # Salva o data frame como um arquivo no formato csv
    write_csv(predicoes, paste0("Previsao_", col, ".csv"))
}




