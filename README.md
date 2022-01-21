
<!-- README.md is generated from README.Rmd. Please edit that file -->

# dail

<!-- badges: start -->

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/dail)](https://cran.r-project.org/package=dail)
[![CRAN_Download_Badge](http://cranlogs.r-pkg.org/badges/dail)](https://CRAN.R-project.org/package=dail)
[![CRAN_Download_Badge](http://cranlogs.r-pkg.org/badges/grand-total/dail)](https://CRAN.R-project.org/package=dail)  
<!-- badges: end -->

Versão: 1.1

O pacote DAIL (Data from Access to Information Law) permite acessar via
R os dados dos pedidos e recursos no âmbito da Lei de Acesso à
Informação (LAI) - Lei 12.527/2011. No site da Controladoria-Geral da
União (CGU) estão disponíveis as estatísticas dos pedidos e recursos, no
âmbito do Executivo Federal, desde o ano de 2012. Entretanto, os
conteúdos dos pedidos, das respostas e dos recursos foram
disponibilizados apenas a partir de 2015. Segundo o órgão, isso se dá em
função das necessidades de regulamentação e da prévia
orientação/capacitação operacional dos órgãos federais para tal abertura
de dados, o que só aconteceu em 18 de maio de 2015 por meio da [Portaria
Interministerial nº
1.254/2015](https://www.gov.br/acessoainformacao/pt-br/assuntos/legislacao-relacionada-1/cgu-prt-inter-1254.pdf).
Por esta razão não é possível acessar os dados contendo os pedidos e
recursos entre 2012 e 2014.

<img src="inst/meme.png" width="60%" style="display: block; margin: auto;" />

## Instalação

Para instalar via [CRAN](https://CRAN.R-project.org):

``` r
install.packages("dail")
library(dail)
```

Para instalar a versão em desenvolvimento [GitHub](https://github.com/):

``` r
install.packages("devtools")
devtools::install_github("igorlaltuf/dail")
library(dail)
```

## Exemplo

Buscar por todos os pedidos de acesso à informação que contêm a palavra
“PAC” entre os anos de 2015 e 2021:

``` r
requests(search = 'PAC') 
```

Também é possível inserir mais de uma palavra no argumento search:

``` r
requests(search = 'Programa de Aceleração do Crescimento')
```

Buscar os pedidos apenas para anos específicos:

``` r
intervalo <- c(2016,2017,2018)
requests(year = intervalo, search = 'PAC')
```

Baixar todos os pedidos de todos os anos:

``` r
requests_all()
```

Baixar os recursos que contenham a palavra ‘Programa’:

``` r
appeals(search = 'Programa')
```

Baixar todos os recursos de todos os anos:

``` r
appeals_all()
```

## “Mas eu não sei usar o R e preciso baixar os pedidos da LAI. O que eu faço?”

``` r
# Insira a(s) palavra(s) que você procura no código abaixo onde está escrito 'DIGITE AQUI'.
# Execute o código (atalho: Ctrl + A + Enter).
# Na janela que será aberta, selecione a pasta onde o arquivo no formato csv será salvo.

install.packages('dail') 
library(dail) 
x <- requests(search = 'DIGITE AQUI') 
write.csv2(x, file = paste0(choose.dir(),'\\dados_LAI.csv')) 
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

# Pedidos

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

# Recursos

-   IdRecurso: identificador único do recurso (não mostrado no sistema);
-   IdRecursoPrecedente: identificador único do recurso que precedeu
    este (não mostrado no sistema e em branco no caso de Recursos de 1ª
    Instância e Reclamações);
-   DescRecurso: descrição do recurso;
-   IdPedido: identificador único do pedido ao qual o recurso pertence
    (não mostrado no sistema);
-   IdSolicitante: identificador único do solicitante (não mostrado no
    sistema);
-   ProtocoloPedido: número do protocolo do pedido ao qual o recurso
    pertence;
-   OrgaoDestinatario: nome do órgão destinatário do recurso;
-   Instancia: descrição da instância do recurso;
-   Situacao: descrição da situação do recurso;
-   DataRegistro: data de abertura do recurso;
-   PrazoAtendimento: data limite para atendimento ao recurso;
-   OrigemSolicitacao: informa se o recurso foi aberto em um Balcão SIC
    ou pela Internet;
-   TipoRecurso: motivo de abertura do recurso;
-   DataResposta: data da resposta ao recurso (campo em branco para
    recursos que ainda estejam na situação “Em Tramitação”);
-   RespostaRecurso: resposta ao recurso;
-   TipoResposta: tipo resposta dada ao recurso (campo em branco para
    recursos que ainda estejam na situação “Em Tramitação”);
