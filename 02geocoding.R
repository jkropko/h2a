## Note: the following fails to geocode 1 row: case no. "H-300-21253-575561"
## Failed geocodes are listed in working/data_failedgeocode.csv

library(tidyverse)

#Load pooled data, remove "-" and trailing numbers from some ZIP codes, and capitalize city and state
data <- read_csv("working/dat_pool.csv") %>%
  separate("WORKSITE_POSTAL_CODE", into = c("WORKSITE_POSTAL_CODE", "junk"), sep="-") %>%
  select(-junk) 
data <- data %>%
  mutate(WORKSITE_CITY = gsub("\xd5", "'", data$WORKSITE_CITY)) %>%
  filter(!(WORKSITE_STATE %in% c("PR","MP","VI"))) %>%
  mutate(WORKSITE_CITY = toupper(WORKSITE_CITY),
         WORKSITE_STATE = toupper(WORKSITE_STATE))

#update bad zip codes  
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-21245-561148"] <-"04945"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-21350-770955"] <-"62092"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-22017-833578"] <-"55129"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-22019-838226"] <-"62859"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-22183-329486"] <-"04945"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-22225-415190"] <-"04945"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-20269-845960"] <-"04945"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-20302-890861"] <-"04945"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-21225-522094"] <-"04945"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-21230-529894"] <-"04945"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-21198-468317"] <-"62330"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-21016-017992"] <-"55129"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-20317-910676"] <-"85320"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-20317-910759"] <-"85320"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-21048-081188"] <-"85320"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-300-21048-083779"] <-"85320"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-400-22004-805437"] <-"98198"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-400-22003-803818"] <-"35216"
data$WORKSITE_POSTAL_CODE[data$CASE_NUMBER =="H-400-20260-826552"] <-"33009"

#Load ZIP code lat/lon data
#Source: http://download.geonames.org/export/zip/US.zip
zipdata <- read_delim("US.txt", delim = "\t", col_names = FALSE) 

#From ZIP code data, create ZIP code level data and city/state level data
zip <- zipdata %>%
  select(X2, X10, X11) %>%
  rename(`WORKSITE_POSTAL_CODE` = X2,
         lat = X10,
         lon = X11)
  
city <- zipdata %>% 
  select(X3, X5, X10, X11) %>%
  rename(`WORKSITE_CITY` = X3,
         `WORKSITE_STATE` = X5) %>%
  mutate(WORKSITE_CITY = toupper(WORKSITE_CITY),
         WORKSITE_STATE = toupper(WORKSITE_STATE)) %>%
  group_by(WORKSITE_CITY, WORKSITE_STATE) %>%
  summarize(lat = mean(X10),
            lon = mean(X11))

#Joining data to zipcode lat/lon if available
latlon_data <- data %>%
  left_join(zip, by = "WORKSITE_POSTAL_CODE")

#Split rows with no match
data_match <- filter(latlon_data, !is.na(lat))
data_nomatch <- filter(latlon_data, is.na(lat))%>%
  select(-lat, -lon)

#Try joining on city/state if no ZIP code match. Place matches back with data_match
data_nomatch <- data_nomatch %>%
  left_join(city, by = c("WORKSITE_CITY", "WORKSITE_STATE")) 
data_match <- bind_rows(data_match, filter(data_nomatch, !is.na(lat)))
data_nomatch <- filter(data_nomatch, is.na(lat)) 

#Write matched data to CSV
write_csv(data_match, "working/data_geocode.csv")

#Write non-matched data to CSV
write_csv(data_nomatch, "working/data_failedgeocode.csv")