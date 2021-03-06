#'Extract content information from DHIS
#'
#' \code{extract_dhis_content} extracts content information from DHIS
#'
#' @param base_url The base url of the DHIS2 setting
#' @param userID your username in the given DHIS2 setting, as a character string
#' @param password your password for this DHIS2 setting, as a character string
#' @return Returns a list of seven tables :
#'
#' \strong{data_sets} The list of data sets as extracted by
#' \link{extract_dhis_datasets}.
#'
#' \strong{data_elements} The list of data elements as extracted by
#' \link{extract_data_elements}.
#'
#' \strong{data_elements_categories} The list of categories as extracted by
#' \link{extract_categories}.
#'
#' \strong{org_units_list} The list of organization units as extracted by
#' \link{extract_orgunits_list}.
#'
#' \strong{org_units_description} The description of organization units as extracted by
#' \link{extract_org_unit}.
#'
#' \strong{org_units_group} The list of the groups of organization units as extracted by
#' \link{extract_org_unit}.
#'
#' \strong{org_units_report} The list of reports for each organization unit as extracted by
#' \link{extract_org_unit}.
extract_dhis_content <- function(base_url , userID, password){
  print('Making DHIS urls')
  urls <- make_dhis_urls(base_url)

  print('Extracting Data Sets')
  data_sets <- extract_dhis_datasets(as.character(urls$data_sets_url) ,
                                     userID ,
                                     password)
  write.csv(data_sets , 'data_sets.csv', row.names = FALSE)

  ## This call only extracts data elements with regard to data sets. Needs to extract data elements in isolation.
  print('Extracting Data Elements List')
  data_elements_list <- extract_data_elements_list(urls$data_elements_url, userID, password)
  data_elements_list$de_url <- paste0(base_url, '/api/dataElements/', data_elements_list$id, '.json')
  write.csv(data_elements_list , 'data_elements_list.csv', row.names = FALSE)

  print('Extracting Data Elements')
  data_elements <- dlply(data_elements_list , .(id) ,
                         function(data){
                           extract_data_elements(as.character(data$de_url) ,
                                                 userID , password)
                           },
                         .progress = 'text')

  data_elements_metadata <- df_from_list(data_elements, 1)
  colnames(data_elements_metadata) <- c('id', 'name', 'categoryCombo_id')
  write.csv(data_elements_metadata , 'data_elements_metadata.csv', row.names = FALSE)

  data_elements_sets <- df_from_list(data_elements, 2)
  colnames(data_elements_sets) <- c('id', 'dataSet_id')
  write.csv(data_elements_sets , 'data_elements_sets.csv', row.names = FALSE)

  data_elements_groups <- df_from_list(data_elements, 3)
  colnames(data_elements_groups) <- c('id', 'dataElementGroup_id')
  write.csv(data_elements_groups , 'data_elements_groups.csv', row.names = FALSE)

  print('Extracting Categories')
  data_elements_categories <- extract_categories(as.character(urls$data_elements_categories) ,
                                                 userID ,
                                                 password )
  write.csv(data_elements_categories , 'data_elements_categories.csv', row.names = FALSE)

  print('Extracting Organisation Units List')
  org_units_list <- extract_orgunits_list(as.character(urls$org_units_url) ,
                                          userID , password)

  ## Taking out duplicate facilities
  n_units <- ddply(org_units_list  , .(id) , nrow)
  simple_units <- subset(n_units , V1 > 1)

  org_units_list <- subset(org_units_list , !(id %in% simple_units$id))
  org_units_list$url_list <- paste0(base_url, '/api/organisationUnits/', org_units_list$id, '.json')
  write.csv(org_units_list , 'org_units_list.csv', row.names = FALSE)

  print('Extracting units information')
  extracted_orgunits <- dlply(org_units_list , .(id) ,
                            function(org_units_list) {
                              try(extract_org_unit(as.character(org_units_list$url_list) ,
                                                   userID , password))
                              },
                              .progress = 'text'
                            )

  org_units_description <- df_from_org_unit_description(extracted_orgunits)
  write.csv(org_units_description , 'org_units_description.csv', row.names = FALSE)
  org_units_group <- df_from_list(extracted_orgunits, 2)
  colnames(org_units_group) <- c('id', 'id_org_units_group')
  write.csv(org_units_group , 'org_units_group.csv', row.names = FALSE)
  org_units_report <- df_from_list(extracted_orgunits, 3)
  colnames(org_units_report) <- c('id', 'id_report')
  write.csv(org_units_report , 'org_units_report.csv', row.names = FALSE)
}
