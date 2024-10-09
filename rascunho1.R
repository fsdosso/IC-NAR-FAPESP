library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(tsDyn)
library(forecast)
library(aTSA)
library(tseries)

dados <- read_csv("dados_nyse_diario_expandido.csv")


for (col in colnames(dados)[-1]) { # Excluindo a primeira coluna "Data"
    df <- data.frame(Data = dados$Data, get(col)) %>% drop_na()
    df$Return <- 100*log(df[col] / lag(df[col]))
    df <- df[-1]
    
    #Window size
    ws <- floor(length(df$Return))
    
    #Vetores que conterao as previsoes
    AR_1 = numeric(length = ws)
    SETAR = numeric(length = ws)
    LSTAR = numeric(length = ws)
    
    # Vetores com os resultados dos testes
    bds <-numeric(length = ws)
    acf <- numeric(length = ws)
    
    for (j in 1:ws){
        retornos <- df$Return
        ns = length(retornos) - ws #new size
        r = retornos[1 + i:ns + i]
        
        ar = arima(r, order = c(1, 0, 0))
        pred_ar = predict(ar, n.ahead = 1)[1]
        AR_1 = c(AR_1, pred_ar)
        
        
        setr = tsDyn::setar(r, m = 2, thDelay = 1,
                            trace = TRUE, include = "const", common = "none")
        pred_setar = predict(setr, n.ahead = 1)[1]
        SETAR <- c(SETAR, pred_setar)
        
        
        lstr = tsDyn::lstar(trace  = TRUE, include = "const", m = 2,
                            thDelay = 1)
        pred_lstar = predict(lstr, n.ahead = 1)[1]
        LSTAR <- c(LSTAR, pred_lstar)
    }
    
    

}