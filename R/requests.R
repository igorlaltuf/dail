#' Queries the requests made through the Brazilian Right to Information Law
#'
#' Downloads data for the selected years, apply a filter and return it in the form of a dataframe.
#'
#' @importFrom utils download.file unzip
#'
#' @param year selects the years which data will be downloaded. integer.
#' @param agency selects the public agency to be searched. see the available agencies in agencies_initials. character.
#' @param search selects the keyword to be searched. character.
#' @param answer if true, fetches the content of the search argument in the request responses. boolean.
#'
#'
#' @return a dataframe with requests containing the keyword
#' @examples
#' \dontrun{requests(search = 'PAC')}
#' @export
requests <- function(year = 'all', agency = 'all', search = 'all', answer = F) {
  if (answer == F) col_filter <- '.detalhamento'
  if (answer == T) col_filter <- '.resposta'
  year.options <- c(2015:format(Sys.Date(), "%Y"))
  links <- paste0('https://dadosabertos-download.cgu.gov.br/FalaBR/Arquivos_FalaBR_Filtrado/Arquivos_csv_', year.options, '.zip')
  protocolo <- palavras <- orgao <- NULL
  `%!in%` = Negate(`%in%`) # creates operator
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

  # if the user does not enter the year, data for all years will be downloaded
  if ('all' %in% year) {
    year <- year.options
  }

  # allows to include more than one year at a time with a vector
  for(i in year) {
    year <- paste0('link', i)
    x <- paste0('link', c(2015:format(Sys.Date(), "%Y")))
    x <- match(year, x) # returns the position of the matching string

    # check if the files of the years have already been downloaded
    lista.arquivos.locais <- list.files(path = dir.temp, pattern = "*.csv", full.names = TRUE)

    # download_lai
    #
    # Download data from the CGU for the selected years.
    download_lai <- function() {
      download.file(links[x], paste(dir.temp, stringr::str_sub(links[x],start = -21), sep = '/')) # fazer com que o nome do arquivo seja dinâmico
    }

    # checks if the file has been previously downloaded
    if(any(grepl(paste0('Pedidos_csv_', i), lista.arquivos.locais)) == T) {
      message(paste0('Data for the year  ', i,' found locally.'))
    } else{
      if (RCurl::url.exists(links[x]) == F) { # network is down = message (not an error anymore)
        message("No internet connection or data source broken.")
        return(NULL)
      } else { # network is up = proceed to download
        message(paste0("Downloading ", i," dataset."))
        download_lai()
      } # /if - network up or down


      # list zip files from the year
      lista.arquivos <- list.files(path = dir.temp, pattern = paste0("Arquivos_csv_", i, ".zip"), full.names = TRUE)
      arquivo.pedido <- unzip(zipfile = lista.arquivos, list = T)
      arquivo.pedido <- grep("Pedidos", arquivo.pedido$Name, value = TRUE)
      # extract only requests files the downloaded files
      unzip(zipfile = lista.arquivos, exdir = dir.temp, files = arquivo.pedido)
    }

    # read the files
    lista.arquivos.locais <- list.files(path = dir.temp, pattern = "\\.csv", full.names = TRUE)
    caminho.arquivo <- stringr::str_subset(lista.arquivos.locais, paste0("_Pedidos_csv_",i))
    var <- readr::read_csv2(file = caminho.arquivo, col_names = FALSE, quote = '\'', show_col_types = FALSE, locale = readr::locale(encoding="UTF-16LE"))
    if(ncol(var) == 1) { # error message
      message(paste0("Inconsistent data for the year ", i, "."))
    } else{
    colnames(var) <- nomes.colunas
    var <- var %>%
      dplyr::select(2,4:13,15,18:21)
    tabela <- rbind(tabela, var)
    }
    rm(list = 'var') # remove variável para liberar RAM
  }

  if ('all' %in% agency) {
  } else {
    tabela <- tabela %>%
      dplyr::filter(stringr::str_detect(orgao, agency))
  }

  if ('all' %in% search) {
    tabela.final <- tabela
  } else {

    # Optimize search to reduce RAM consumption
    tabela.final <- data.frame(matrix(NA, nrow = 0, ncol = 21)) # Create empty data frame
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
        tidytext::unnest_tokens('palavras', paste0('X', i, col_filter), drop = F) %>%
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

  }

  message('Ended query.')
  return(tabela.final)
}
