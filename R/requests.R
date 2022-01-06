# Script containing the function to query the requests made to Brazilian federal government through Right to Information Law
# The search argument takes a string that must be found in the 'detalhamento' column
#' Query the requests made through Right to Information Law to Brazilian federal government
#'
#' Download data from the CGU for the selected years, apply a filter and return the data in the form of a dataframe
#'
#' @param year selects which years data will be downloaded
#' @param search select the keyword to be searched
#'
#' @return a dataframe with requests to access information containing the keyword
#' @examples
#' \dontrun{requests(search = 'PAC')}
#' @export
requests <- function(year = 'all', search) {
  protocolo <- palavras <- download.file <- unzip <- X1 <- X2 <- X3 <- X4 <- X5 <- X6 <- X7 <- X8 <- X9 <- X10 <- X11 <- X12 <- X13 <- X14 <- X15 <- X16 <- X17 <- X18 <- X19 <- X20 <- X21 <-NULL
  `%!in%` = Negate(`%in%`) # criar um operador de negação
  if(sum(stringr::str_count(search, '\\w+')) > 1){
    search <- unlist(strsplit(search, split = " "))
    search <- search[search %!in% stopwords::stopwords('portuguese')] # remove the stopwords
  }

  search <- tolower(search)
  tabela <- data.frame(matrix(NA, nrow = 0, ncol = 21)) # Create empty data frame
  nomes.colunas <- c('id_pedido','protocolo','esfera','orgao','situacao','data_registro','resumo','detalhamento','prazo',
                     'foi_prorrogado','foi_reencaminhado','forma_resposta','origem_da_solicitacao','id_solicitante',
                     'assunto','sub_assunto','tag','data_resposta','resposta','decisao','especificacao_decisao')
  colnames(tabela) <- nomes.colunas
  tabela <- tabela %>%
    dplyr::select(2,4:13,15,18:21)

  dir.temp <- tempdir()
  links <- c('https://dadosabertos-download.cgu.gov.br/FalaBR/Arquivos_FalaBR_Filtrado/Arquivos_csv_2015.zip',
             'https://dadosabertos-download.cgu.gov.br/FalaBR/Arquivos_FalaBR_Filtrado/Arquivos_csv_2016.zip',
             'https://dadosabertos-download.cgu.gov.br/FalaBR/Arquivos_FalaBR_Filtrado/Arquivos_csv_2017.zip',
             'https://dadosabertos-download.cgu.gov.br/FalaBR/Arquivos_FalaBR_Filtrado/Arquivos_csv_2018.zip',
             'https://dadosabertos-download.cgu.gov.br/FalaBR/Arquivos_FalaBR_Filtrado/Arquivos_csv_2019.zip',
             'https://dadosabertos-download.cgu.gov.br/FalaBR/Arquivos_FalaBR_Filtrado/Arquivos_csv_2020.zip',
             'https://dadosabertos-download.cgu.gov.br/FalaBR/Arquivos_FalaBR_Filtrado/Arquivos_csv_2021.zip')

  # if the user does not enter the year, data for all years will be downloaded
  if (year == 'all') {
    year <- c(2015,2016,2017,2018,2019,2020,2021)
  }

  # allows to include more than one year at a time with a vector
  for(i in year) {
    year <- paste0('link', i)
    x <- c('link2015','link2016','link2017','link2018','link2019','link2020','link2021')
    x <- match(year, x) # returns the position of the matching string

    # check if the files of the years have already been downloaded
    lista.arquivos.locais <- list.files(path = dir.temp, pattern = "*.csv", full.names = TRUE)

    # download_lai
    #
    # Download data from the CGU for the selected years.
    download_lai <- function() {
      download.file(links[x], paste(dir.temp, stringr::str_sub(links[x],start = -21), sep = '\\')) # fazer com que o nome do arquivo seja dinâmico
      # Extrair os arquivos baixados e excluir arquivos zip
      lista.arquivos <- list.files(path = dir.temp, pattern = "*.zip", full.names = TRUE)
      mapply(unzip, zipfile = lista.arquivos, exdir = dir.temp)
    }

    # procurar por '_2021' porque todos os arquivos contém 2021 no nome
    if (any(grepl(paste0('_', i), lista.arquivos.locais)) == F | length(lista.arquivos.locais) == 0) {
      download_lai()
    } else{
      if(i < 2021){
        print(paste0('Os arquivos de ', i,' foram baixados anteriormente.'))
      } else {
        download_lai()
      }
    }

    lista.arquivos.locais <- list.files(path = dir.temp, pattern = "*.csv", full.names = TRUE)
    caminho.arquivo <- stringr::str_subset(lista.arquivos.locais, paste0("Pedidos_csv_",i))
    var <- readr::read_csv2(file = caminho.arquivo, col_names = FALSE, quote = '\'', locale = readr::locale(encoding="UTF-16LE")) %>%
      dplyr::rename(id_pedido = X1, protocolo = X2, esfera = X3, orgao = X4, situacao = X5,
                    data_registro = X6, resumo = X7, detalhamento = X8, prazo = X9, foi_prorrogado = X10,
                    foi_reencaminhado = X11, forma_resposta = X12, origem_da_solicitacao = X13,
                    id_solicitante = X14, assunto = X15, sub_assunto = X16, tag = X17,
                    data_resposta = X18, resposta = X19, decisao = X20, especificacao_decisao = X21)
    assign(paste0('pedidos', i), var)


    dados <- get(paste0('pedidos', i)) %>%
      dplyr::select(2,4:13,15,18:21)

    tabela <- rbind(tabela, dados)

    rm(list = c(paste0('pedidos', i)),'dados','var') # remove variável para liberar RAM
  }

  # Otimizar busca para reduzir o consumo de memória RAM
  tabela.final <-  data.frame(matrix(NA, nrow = 0, ncol = 21)) # Create empty data frame
  colnames(tabela.final) <- nomes.colunas
  tabela.final <- tabela.final %>%
    dplyr::select(2,4:13,15,18:21)

  n <- 10000
  nr <- nrow(tabela)
  lista.tabelas <- split(tabela, rep(1:ceiling(nr/n), each = n, length.out = nr))
  rm(list = 'tabela')


  for(i in 1:length(lista.tabelas)){
    # creates a partial table
      tabela.parcial <- as.data.frame(lista.tabelas[i]) %>%
        tidytext::unnest_tokens('palavras', paste0('X', i,'.detalhamento'), drop = F) %>%
        dplyr::filter(palavras %in% search) %>%
        unique()

    colnames(tabela.parcial) <- c('protocolo','orgao','situacao','data_registro','resumo','detalhamento','prazo',
                                  'foi_prorrogado','foi_reencaminhado','forma_resposta','origem_da_solicitacao',
                                  'assunto','data_resposta','resposta','decisao','especificacao_decisao','palavras')

    tabela.final <- rbind(tabela.final, tabela.parcial)
  }

  if(sum(stringr::str_count(search, '\\w+')) > 1){
    count <- tabela.final %>%
      dplyr::group_by(protocolo) %>%
      dplyr::count()

    tabela.final <- tabela.final %>%
      dplyr::left_join(count) %>%
      dplyr::filter(n >= sum(stringr::str_count(search, '\\w+')))
  }

  tabela.final <- tabela.final %>% dplyr::select(1:16) %>% unique()
  return(tabela.final)
}
