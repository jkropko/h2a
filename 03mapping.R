library(tidyverse)
library(leaflet)

data <- read_csv("working/data_geocode.csv")

leaflet(data = data) %>% 
  addTiles() %>%
  addMarkers(~lon, ~lat, clusterOptions = markerClusterOptions())

