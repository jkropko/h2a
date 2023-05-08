library(tidyverse)
library(leaflet)
library(htmlwidgets)
library(htmltools)

data <- read_csv("working/data_geocode.csv")

data$address <- paste(data$WORKSITE_ADDRESS, data$WORKSITE_CITY,
                      data$WORKSITE_STATE, data$WORKSITE_POSTAL_CODE)

Encoding( x = data$address ) <- "UTF-8"

# replace all non UTF-8 character strings with an empty space
data$address <-
  iconv( x = data$address
         , from = "UTF-8"
         , to = "UTF-8"
         , sub = "" )


data$popup <- paste('<b>Case No.:',data$CASE_NUMBER, '</b><br/>',
                    'Case status:', data$CASE_STATUS, '<br/>',
                    'Worksite address:', data$address, '<br/>',
                    'Total worksites records:', data$TOTAL_WORKSITES_RECORDS)
                    
map <- leaflet(data = data) %>% 
  addTiles() %>%
  addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions(), 
             popup = ~popup)

saveWidget(map, file="afl_cio_map.html")