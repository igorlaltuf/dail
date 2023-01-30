#' Queries presidential expenses with the corporate card
#'
#' Downloads data from 2002 to 2022 and return it in the form of a dataframe.
#' Deflated values refer to values in November 2022.
#'
#' @importFrom utils download.file unzip
#' @return a dataframe with the data from 2002 to 2022.
#' @examples
#' \dontrun{df <- corporateCardExpenses()}
#' @export
corporateCardExpenses <- function() {

cdic <- cpf_cnpj_fornecedor <- cpf_servidor <- data_pgto <- nome_fornecedor <- valor_deflacionado <- presidente <- subelemento_de_despesa <- tipo <- valor <- NULL

link <- "https://www.gov.br/secretariageral/pt-br/acesso-a-informacao/informacoes-classificadas-e-desclassificadas/Planilha12003a2022.csv"

message('Please wait for the download to complete.')

df_credit_card <- readr::read_csv2(link, locale = readr::locale(encoding = "latin1"),
                                   show_col_types = FALSE) %>%
  janitor::clean_names() %>%
  dplyr::filter(data_pgto != c('Fonte: SUPRIM', 'At  19/12/2022')) %>%
  dplyr::mutate(data_pgto = lubridate::dmy(data_pgto),
                valor = readr::parse_number(stringr::str_remove(valor, "R\\$ "),
                                     locale = readr::locale(decimal_mark = ",")),
                presidente = dplyr::case_when(
                  lubridate::year(data_pgto) <= 2010 ~ "Lula",
                  lubridate::year(data_pgto) <= 2016 ~ "Dilma",
                  lubridate::year(data_pgto) <= 2018 ~ "Temer",
                  lubridate::year(data_pgto) <= 2022 ~ "Bolsonaro"),
                valor_deflacionado = round(deflateBR::deflate(valor, data_pgto, "12/2022", "ipca"), 2)) %>%
  dplyr::select(nome_fornecedor, cpf_cnpj_fornecedor, data_pgto, cpf_servidor, cdic,
                presidente, subelemento_de_despesa, tipo, valor, valor_deflacionado)

return(df_credit_card)

}
