library(TSA) # Pacote para o modelo SETAR
library(tsDyn) # Pacote para o modelo LSTAR
library(tidyverse)
library(astsa)
library(tsDyn)
library(patchwork)
library(ggfortify)
library(tseries)


acoes <- c("FCF", "HY", "IO", "DHX",
             "CSR") # acoes selecionadas ao acaso

dados <- read_csv("dados_nyse_diario_expandido.csv") #leitura dos dados

bds_test <- function(ts, m = 2) {
    # Ensure data has no missing values
    ts <- na.omit(ts)
    
    sd_ts <- sd(ts)
    
    # Define a valid range for eps
    eps <- seq(0.5 * sd_ts, 2 * sd_ts, length.out = 4)
    
    bds_result <- tseries::bds.test(ts, m = m, eps = eps)
    
    # Extract and return the p-value
    pvalue <- bds_result$p.value
    
    significante <- ifelse(any(pvalue < 0.05), 1, 0)
}

verifica_primeiro_acf <- function(time_series){
    #acessa o primeiro acf da série
    acf_result <- stats::acf(time_series, plot = FALSE)
    acf_1 = acf_result$acf[2]
    
    # Encontra o ponto de decisão
    x = qnorm(1 - 0.025) / sqrt((length(time_series)))
    
    
    # Verifica se é significante ou não
    significante <- ifelse(acf_1 > x || acf_1 < -x , 1, 0)
    
    return(significante)
}


res_graficos <- function(modelo, acao){ # Função que retorna os quatro gráficos 
                                        # de análise de resíduos
    
    # Transformações necessárias
    df <- dados[acao]                   
    df <- df %>% as_tibble()
    df[[acao]] <- as.double(df[[acao]])
    df <- df %>% drop_na()
    df$Return <- 100 * log(df[[acao]] / lag(df[[acao]]))
    df <- df[-1,]
    
    retornos <- na.omit(df$Return)
    ws <- floor(length(retornos) * 0.3)
    ns <- length(retornos) - ws
    for (i in 0:(ws - 1)){ # Seleciona a primeira série com as condições desejadas
        r <- retornos[1 + i:ns + i]
        acf1 <- verifica_primeiro_acf(r)
        bds <- bds_test(r, 5)
        
        if(bds == 1 && acf1 == 1){
            break  
        } else{
            next
        } 
    }
    
    # Verifica qual modelo é
    fit_setar <- tsDyn::setar(r, m=2, d=1)
    fit_lstar <- tsDyn::lstar(r, m=2, d=1)
    fit_ar <- arima(r, c(1,0,0))
    if (modelo == "setar"){
        res <- fit_setar$residuals
    } else if (modelo == "lstar"){
        res <- fit_lstar$residuals
    } else if (modelo == "ar"){
        res <- residuals(fit_ar)
    }else{
        return(0)
    }
    
    std_res <- res / sd(res)
    # Gráfico da série temporal dos resíduos padronizados
    plot1 <- ggplot(data.frame(Index = time(std_res), Residuals = std_res), 
                    aes(x = Index, y = std_res)) +
        geom_line() +
        labs(title = "Standardized Residuals", x = "Time", y = "Residuals") +
        theme_minimal()
    
    # Gráfico de FAC dos residuos padronizados
    acf_plot <- autoplot(acf(std_res, 
        main = "ACF of Residuals",  
        lag.max = 40,               
        col = "blue",               
        ci.col = "red", plot = FALSE))
    
    
    # Gráfico dos pvalores do teste de Ljung-Box
    max_lag <- 20
    p_values <- sapply(1:max_lag, function(lag) {
        test <- Box.test(std_res, lag=lag, type="Ljung-Box")
        test$p.value
    })
    
    p_values_df <- data.frame(Lag = 1:max_lag, P_Value = p_values)
    
    pvalues_plot <- ggplot(p_values_df, aes(x = Lag, y = P_Value)) +
        geom_point(shape=21, color="black", fill="white", size=1, stroke=1) +
        labs(title = "Ljung-Box Test P-values", x = "Lag", y = "P-Value") +
        theme_minimal() +
        geom_hline(yintercept = 0.05, linetype = "dashed", color = "blue") # Add a significance threshold
    
    final <- (plot1 / acf_plot / pvalues_plot) + 
        plot_annotation(title = paste("Modelo",toupper(modelo),"de", acao))
    
    path <- paste0("/home/felipe/Documentos/IC/Codigo/Previsao/Expandido/Graficos_Res/",
                   acao, "_", toupper(modelo), "_res.jpeg")
    
    ggsave(filename = path, plot = final, width = 8, height = 6, dpi = 150)
    
    return(final)
}

for (a in acoes){
    res_graficos("setar", a)
    res_graficos("ar", a)
    res_graficos("lstar", a)
}

res_graficos("setar", "FCF")

res_graficos("ar", "FCF")
res_graficos("lstar","FCF")





