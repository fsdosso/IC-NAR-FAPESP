<div style="width: 500px; word-wrap: break-word;">
# **Estimação e previsão em modelos autoregressivos não lineares**



## Resumo do Projeto

Esse repositório contem os dados e a análise de um estudo comparativo feito utilizando três modelos de séries temporais, Autoregressivo (AR),
  Autoregressivo com Limiar Auto Excitante (SETAR) e Autoregressivo de Transição Suave Logística (LSTAR), aplicados a ações da bolsa americana.
  Esse estudo foi conduzido como parte de um projeto de Iniciação Científica.

<!--
## Modelos Implementados

### AR
O modelo Autoregressivo (AR) é um dos modelos mais conhecidos de séries temporais junto com o modelo de Médias Móveis (MA) (wm inglês, *Moving Average*). O modelo AR de ordem p define a variável no tempo $t$ como combinação linear da mesma variável nos $p$ tempos anteriores, $Y_{t-1}, \cdots, Y_{t-p}$, mais um erro aleatório $\varepsilon_t$. Sua forma é dada por
$Y_t = \phi_0 + \sum_{i = 1}^p \phi_iY_{t-i} + \varepsilon_t$

### SETAR
O modelo Autoregressivo com Limiar Auto Excitante (SETAR) é um modelo de mudança de regimes. No SETAR, assume-se que a transição entre regimes é definida por uma variável pertencente à própria série temporal, especificamente $y_{t-d}$, em que $d > 0$. O modelo é dado por 

\begin{equation}
y_t = \begin{cases}
\phi_{0,1} + \phi_{1,1} y_{t-1} + \varepsilon_t & \text{se } q_t \leq c, \\
\phi_{0,2} + \phi_{1,2} y_{t-1} + \varepsilon_t & \text{se } q_t > c
\end{cases}
\end{equation}

### LSTAR
O modelo Autoregressivo de Transição Suave Logística (LSTAR) é semelhante ao modelo SETAR, mas pressupõe-se que a mudança de regime é feita de forma contínua por uma função logística que varia de 0 a 1. Sua fórmula é dada por
$y_t = (\phi_{0,1} + \phi_{1,1}y_{t-1})(1 - G(y_{t-1};\gamma, c)]) \\
        + (\phi_{0,2} + \phi_{1,2}y_{t-1})G(y_{t-1};\gamma, c) + \varepsilon_t$

em que 
$G(y_{t-1};\gamma, c) = \frac{1}{1 + \exp{(-\gamma[y_{t-1} - c]})}$
-->

## Descrição dos dados
Os dados brutos são um data frame contendo mais de 1.400 colunas e quase 10.000 observações, extraídos da bolsa de valores americana. A primeira coluna é a data em que os dados foram observados, e as demais representam ações; cada observação corresponde ao valor de fechamento diário em dólares. Na fase de tratamento dos dados, renomeamos todas as colunas para que apenas o código da ação aparecesse no nome e substituímos todos os valores '-' por NaN. Por fim, criamos outro conjunto de dados, composto por todas as ações que possuem mais de 2.000 valores não NaN e a data, chamado 'dados_nyse_diario_expandido.csv'.



## Instrução de execução dos arquivos
- Abra o diretório Dados e baixe "Limpeza.ipynb" e "economatica_nyse_diario.xlsx"
- Execute o arquivo "Limpeza.ipynb" e exporte o arquivo "dados_nyse_diario_expandido.csv"
- Baixe o arquivo "PredicaoExpandido.R" do diretório Estimacao_Previsao. Certifique-se que todos os pacotes necessários estão instalados. 
- Execute o código até produzir arquivos contendo a predição de 100 ações (apenas um terço das ações vai converjir)
- Baixe o arquivo "AnaliseResultados.R" da pasta Analise e calcule as métricas RMSE e MAE com os dados gerados do passo anterior
- Se achar necessário, execute o arquivo "AnaliseResiduos.R" do diretório Analise para obter os gráficos de análise de resíduos.


</div>



