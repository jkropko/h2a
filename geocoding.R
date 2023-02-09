library(tidyverse)
library(tmaptools)
data <- read_csv("working/data_pooled.csv")

#Possibilities:
## 1. https://rdrr.io/cran/tmaptools/man/geocode_OSM.html (open street map)
## 2. https://guides.library.duke.edu/r-geospatial/geocode (ggmap -- which pulls google maps by default)

#geocode_OSM(q = "1366 Stoney Ridge Road, Albemarle County, Virginia, United States")

data <- data %>%
  mutate(row = 1:nrow(data),
         country = "United States") %>%
  #unite(query, `EMPLOYER_ADDRESS1`, `EMPLOYER_CITY`, `EMPLOYER_STATE`, `EMPLOYER_POSTAL_CODE`, sep=", ")
  #unite(query, `EMPLOYER_CITY`, `EMPLOYER_STATE`, `EMPLOYER_POSTAL_CODE`, sep=", ") %>%
  unite(query, `EMPLOYER_POSTAL_CODE`, country, sep=", ")
  
coords_mat <- sapply(1:200, FUN = function(x){
  if ((x %% 10)==0) print(paste(c("Now working on", x, "of", nrow(data)), collapse=" "))
  geo <- geocode_OSM(q = data$query[x])
  return(c(x, geo$coords))
})

coords_df = data.frame(t(coords_mat))
colnames(coords_df) <- c("row", "lat", "lon")

data <- data %>%
  full_join(coords_df, by = 'row')

write_csv(data, "working/data_geocode.csv")