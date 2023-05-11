library(tidyverse)
library(leaflet)
library(htmlwidgets)
library(htmltools)

data <- read_csv("working/data_geocode.csv")

data$address <- paste(data$WORKSITE_ADDRESS, data$WORKSITE_CITY,
                      data$WORKSITE_STATE, data$WORKSITE_POSTAL_CODE)

Encoding( x = data$address ) <- "UTF-8"
Encoding( x = data$JOB_TITLE ) <- "UTF-8"
Encoding( x = data$WAGE ) <- "UTF-8"

# replace all non UTF-8 character strings with an empty space
data$address <-
  iconv( x = data$address
         , from = "UTF-8"
         , to = "UTF-8"
         , sub = "" )

data$JOB_TITLE <-
  iconv( x = data$JOB_TITLE
         , from = "UTF-8"
         , to = "UTF-8"
         , sub = "" )

data$WAGE <-
  iconv( x = data$WAGE
         , from = "UTF-8"
         , to = "UTF-8"
         , sub = "" )

data$popup <- paste('<b>Type:', data$TYPE, '</b><br/>',
                    '<b>Case No.:',data$CASE_NUMBER, '</b><br/>',
                    'Case status:', data$CASE_STATUS, '<br/>',
                    'Worksite address:', data$address, '<br/>',
                    'Total worksites records:', data$TOTAL_WORKSITES_RECORDS, '<br/>',
                    'Job title:', data$JOB_TITLE, '<br/>',
                    'Wage:', data$WAGE)
                    
sym_palette <- colorFactor(palette = 'RdBu', data$TYPE)
map <-  leaflet(data = data) %>% 
  addTiles() %>%
  addCircleMarkers(~ lon, ~ lat, clusterOptions = markerClusterOptions(), 
             popup = ~ popup, color = ~ sym_palette(TYPE))

saveWidget(map, file="afl_cio_map.html")