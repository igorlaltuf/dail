#' Queries the appeals made through the Brazilian Right to Information Law
#'
#' Downloads data for the selected years, apply a filter and return it in the form of a dataframe.
#'
#' @importFrom utils download.file unzip
#'
#' @param year selects the years which data will be downloaded
#' @param search selects the keyword to be searched
#' @param answer if true, fetches the content of the search argument in the appeals responses
#'
#' @return a dataframe with appeals containing the keyword
#' @examples
#' \dontrun{appeals(search = 'PAC')}
#' @export
appeals <- function(year = 'all', answer = F, search = 'all') {
  old <- Sys.time() # to calculate execution time

  if (answer == F) col_filter <- '.desc_recurso'
  if (answer == T) col_filter <- '.resposta_recurso'

  year.options <- c(2015:format(Sys.Date(), "%Y"))
  links <- paste0('https://dadosabertos-download.cgu.gov.br/FalaBR/Arquivos_FalaBR_Filtrado/Arquivos_csv_', year.options, '.zip')
  # if the user does not enter the year, data for all years will be downloaded
  if (year == 'all') {
    year <- year.options
  }
  protocolo <- palavras <- NULL
  `%!in%` = Negate(`%in%`) # creates operator
  if(sum(stringr::str_count(search, '\\w+')) > 1){
    search <- unlist(strsplit(search, split = " "))
    search <- search[search %!in% stopwords::stopwords('portuguese')] # remove the stopwords
  }
  search <- tolower(search)
  tabela <- data.frame(matrix(NA, nrow = 0, ncol = 21)) # Create empty data frame
  nomes.colunas <- c('id_recurso','id_recurso_precedente','desc_recurso','id_pedido',
                     'id_solicitante','protocolo_pedido','orgao_destinatario','instancia',
                     'situacao','data_registro','prazo_atendimento','origem_solicitacao',
                     'tipo_recurso','data_resposta','resposta_recurso','tipo_resposta')

  colnames(tabela) <- nomes.colunas
  dir.temp <- tempdir()

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
      download.file(links[x], paste(dir.temp, stringr::str_sub(links[x],start = -21), sep = '\\')) # fazer com que o nome do arquivo seja dinâmico
    }

    # checks if the file has been previously downloaded
    if(any(grepl(paste0('Recursos_csv_', i), lista.arquivos.locais)) == T) {
      print(paste0('Os arquivos de ', i,' foram baixados anteriormente.'))
    } else{
      download_lai()
      # list zip files from the year
      lista.arquivos <- list.files(path = dir.temp, pattern = paste0("Arquivos_csv_", i, ".zip"), full.names = TRUE)
      arquivo.pedido <- unzip(zipfile = lista.arquivos, list = T)
      arquivo.pedido <- grep("Recursos", arquivo.pedido$Name, value = TRUE)
      # extract only requests files the downloaded files
      unzip(zipfile = lista.arquivos, exdir = dir.temp, files = arquivo.pedido)
    }

    # read the files
    lista.arquivos.locais <- list.files(path = dir.temp, pattern = "*.csv", full.names = TRUE)
    caminho.arquivo <- stringr::str_subset(lista.arquivos.locais, paste0("Recursos_csv_",i))
    var <- readr::read_csv2(file = caminho.arquivo, col_names = FALSE, quote = '\'', locale = readr::locale(encoding="UTF-16LE"))
    colnames(var) <- nomes.colunas

    tabela <- rbind(tabela, var)
    rm(list = 'var') # remove variável para liberar RAM
  }

  if (search == 'all') {
    tabela.final <- tabela
  } else {

  # Optimize search to reduce RAM consumption
  tabela.final <- data.frame(matrix(NA, nrow = 0, ncol = 21)) # Create empty data frame
  colnames(tabela.final) <- nomes.colunas

  n <- 5000
  nr <- nrow(tabela)
  lista.tabelas <- split(tabela, rep(1:ceiling(nr/n), each = n, length.out = nr))
  rm(list = 'tabela')

  for(i in 1:length(lista.tabelas)){
    # creates a partial table
    tabela.parcial <- as.data.frame(lista.tabelas[i]) %>%
      tidytext::unnest_tokens('palavras', paste0('X', i, col_filter), drop = F) %>%
      dplyr::filter(palavras %in% search) %>%
      unique()

    colnames(tabela.parcial) <- nomes.colunas

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

  new <- Sys.time() - old # calculate difference
  print(paste0('Consulta finalizada em ', round(new, 2),' segundos.'))
  print(paste0('Query completed in ', round(new, 2),' seconds'))
  return(tabela.final)
}
