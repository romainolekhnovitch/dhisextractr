% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract_wrapper.R
\name{extract_all_data}
\alias{extract_all_data}
\title{Extracting multiple sets of data value}
\usage{
extract_all_data(base_url, data_sets, org_units, deb_period, end_period,
  pace = 1, userID, password, update_date)
}
\arguments{
\item{base_url}{The base url of the DHIS2 setting}

\item{data_sets}{A table of data sets, as extracted by \link{extract_dhis_datasets}}

\item{userID}{your username in the given DHIS2 setting, as a character string}

\item{password}{your password for this DHIS2 setting, as a character string}

\item{org_unit}{A table of organization units, as extracted by \link{extract_org_unit}}

\item{period_start}{Date of the beginning of the period from which to extract data}

\item{period_end}{Date of the end of the period from which to extract data}
}
\value{
Returns an url that calls on the data to be extracted based on inputted
parameters
}
\description{
\code{extract_all_data} Extracts a data based on list of data sets, organisation units, #' and a period.Can be used to make complete extraction.
}
