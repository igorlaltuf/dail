
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dail

<!-- badges: start -->
<!-- badges: end -->

O pacote DAIL (Data from Access to Information Law) faz o download dos
arquivos disponibilizados pela Controladoria-Geral da União (CGU)
referentes aos dados da Lei de Acesso à Informação (LAI) - Lei
12.527/2011 -, busca nos pedidos por determinada palavra-chave e retorna
os dados dos pedidos e suas respectivas respostas na forma de um
dataframe. É possível acessar os dados dos pedidos feitos desde 2015.

## Instalação

Para instalar via [CRAN](https://CRAN.R-project.org):

``` r
install.packages("dail")
```

Para instalar a versão em desenvolvimento [GitHub](https://github.com/):

``` r
# install.packages("devtools")
devtools::install_github("igorlaltuf/dail")
```

## Exemplo

Carregar o pacote:

``` r
library(dail)
```

Buscar por todos os pedidos de acesso à informação que contêm a palavra
“PAC” entre os anos de 2015 e 2021:

``` r
requests(search = 'PAC')
```

Também é possível pesquisar usando mais de uma palavra:

``` r
requests(search = 'Programa de Aceleração do Crescimento')
```

Buscar os pedidos apenas para anos específicos:

``` r
intervalo <- c(2016,2017,2018)
requests(year = intervalo, search = 'PAC')
```

## Citação

Para citar em trabalhos, use:

``` r
citation('dail')
#> 
#> To cite dail in publications use:
#> 
#>   LALTUF, Igor. Data from Access to Information Law. 2022. Available
#>   in: https://github.com/igorlaltuf/dail.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Misc{,
#>     title = {Data from Access to Information Law - DAIL},
#>     author = {Igor Laltuf},
#>     year = {2022},
#>     url = {https://github.com/igorlaltuf/dail},
#>   }
```

## Dicionário de dados

-   Protocolo: número do protocolo do pedido;
-   Orgão: nome do órgão destinatário do pedido;
-   Situação: descrição da situação do pedido;
-   Data Registro: data de abertura do pedido;
-   Resumo: resumo do pedido;
-   Detalhamento: detalhamento do pedido;
-   Prazo: data limite para atendimento ao pedido;
-   Foi Prorrogado: informa se houve prorrogação do prazo do pedido;
-   Foi Reencaminhado: informa se o pedido foi reencaminhado;
-   Forma Resposta: tipo de resposta escolhida pelo solicitante na
    abertura do pedido;
-   Origem Solicitacao: informa se o pedido foi aberto em um Balcão SIC
    ou pela Internet;
-   Assunto: assunto do pedido atribuído pel SIC;
-   Data Resposta: data da resposta ao pedido (campo em branco para
    pedidos que ainda estejam na situação “Em Tramitação”);
-   Resposta: resposta ao pedido;
-   Decisão: tipo resposta dada ao pedido (campo em branco para pedidos
    que ainda estejam na situação “Em Tramitação”);
-   Especificação Decisão: subtipo da resposta dada ao pedido (campo em
    branco para pedidos que ainda estejam na situação “Em Tramitação”);
