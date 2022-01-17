#' Queries all the requests made through the Brazilian Right to Information Law
#'
#' Downloads all the data and return it in the form of a dataframe.
#'
#' @importFrom utils download.file unzip
#'
#' @param year selects which years data will be downloaded
#'
#' @return a dataframe with all requests made
#' @examples
#' \dontrun{requests_all()}
#' @export
requests_all <- function(year = 'all') {
  old <- Sys.time() # to calculate execution time
  year.options <- c(2015, 2016, 2017, 2018, 2019, 2020, 2021, 2022)
  links <- paste0('https://dadosabertos-download.cgu.gov.br/FalaBR/Arquivos_FalaBR_Filtrado/Arquivos_csv_', year.options, '.zip')
  # if the user does not enter the year, data for all years will be downloaded
  if (year == 'all') {
    year <- year.options
  }
  protocolo <- palavras <- NULL

  tabela <- data.frame(matrix(NA, nrow = 0, ncol = 21)) # Create empty data frame
  nomes.colunas <- c('id_pedido','protocolo','esfera','orgao','situacao','data_registro','resumo','detalhamento','prazo',
                     'foi_prorrogado','foi_reencaminhado','forma_resposta','origem_da_solicitacao','id_solicitante',
                     'assunto','sub_assunto','tag','data_resposta','resposta','decisao','especificacao_decisao')
  colnames(tabela) <- nomes.colunas
  tabela <- tabela %>%
    dplyr::select(2,4:13,15,18:21)
  dir.temp <- tempdir()

  # allows to include more than one year at a time with a vector
  for(i in year) {
    year <- paste0('link', i)
    x <- c('link2015','link2016','link2017','link2018','link2019','link2020','link2021','link2022')
    x <- match(year, x) # returns the position of the matching string

    # check if the files of the years have already been downloaded
    lista.arquivos.locais <- list.files(path = dir.temp, pattern = "*.csv", full.names = TRUE)

    # used to select the file to extract
    data <- Sys.Date()
    pontos <- "a1~!@#$%^&*(){}_+:\"<>?,./;'[]-="
    dia.arquivo <- stringr::str_replace_all(data, "[[:punct:]]", "")

    # download_lai
    #
    # Download data from the CGU for the selected years.
    download_lai <- function() {
      download.file(links[x], paste(dir.temp, stringr::str_sub(links[x],start = -21), sep = '\\')) # fazer com que o nome do arquivo seja dinâmico
    }


    # checks if the file has been previously downloaded
    if(any(grepl(paste0('Pedidos_csv_', i), lista.arquivos.locais)) == T) {
      print(paste0('Os arquivos de ', i,' foram baixados anteriormente.'))
    } else{
      download_lai()
      # list zip files from the year
      lista.arquivos <- list.files(path = dir.temp, pattern = paste0("Arquivos_csv_", i, ".zip"), full.names = TRUE)
      # extract only requests files the downloaded files
      unzip(zipfile = lista.arquivos, exdir = dir.temp, files = paste0(dia.arquivo,"_Pedidos_csv_",i,".csv"))
    }

    # read the files
    lista.arquivos.locais <- list.files(path = dir.temp, pattern = "*.csv", full.names = TRUE)
    caminho.arquivo <- stringr::str_subset(lista.arquivos.locais, paste0("Pedidos_csv_",i))
    var <- readr::read_csv2(file = caminho.arquivo, col_names = FALSE, quote = '\'',
                            locale = readr::locale(encoding="UTF-16LE"))
    colnames(var) <- nomes.colunas
    var <- var %>%
      dplyr::select(2,4:13,15,18:21)
    tabela <- rbind(tabela, var)
    rm(list = 'var') # remove variável para liberar RAM
  }

  new <- Sys.time() - old # calculate difference
  print(paste0('Consulta finalizada em ', round(new, 2),' segundos.'))
  print(paste0('Query completed in ', round(new, 2),' seconds'))
  return(tabela)
}
