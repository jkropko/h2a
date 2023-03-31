## Note: the following script geocodes 96973 of the 97403 rows. It fails to geocode 430 rows.
## Failed geocodes are listed in working/data_failedgeocode.csv

library(tidyverse)

#Load pooled data, remove "-" and trailing numbers from some ZIP codes, and capitalize city and state
data <- read_csv("working/data_pooled.csv") %>%
  separate("EMPLOYER_POSTAL_CODE", into = c("EMPLOYER_POSTAL_CODE", "junk"), sep="-") %>%
  select(-junk) %>%
  mutate(EMPLOYER_CITY = toupper(EMPLOYER_CITY),
         EMPLOYER_STATE = toupper(EMPLOYER_STATE))

#Load ZIP code lat/lon data
#Source: http://download.geonames.org/export/zip/US.zip
zipdata <- read_delim("US.txt", delim="\t", col_names=FALSE) 

#From ZIP code data, create ZIP code level data and city/state level data
zip <- zipdata %>%
  select(X2, X10, X11) %>%
  rename(`EMPLOYER_POSTAL_CODE` = X2,
         lat = X10,
         lon = X11)
  
city <- zipdata %>% 
  select(X3, X5, X10, X11) %>%
  rename(`EMPLOYER_CITY` = X3,
         `EMPLOYER_STATE` = X5) %>%
  mutate(EMPLOYER_CITY = toupper(EMPLOYER_CITY),
         EMPLOYER_STATE = toupper(EMPLOYER_STATE)) %>%
  group_by(EMPLOYER_CITY, EMPLOYER_STATE) %>%
  summarize(lat = mean(X10),
            lon = mean(X11))

#Joining data to zipcode lat/lon if available
data <- data %>%
  left_join(zip, by = "EMPLOYER_POSTAL_CODE")

#Split rows with no match
data_match <- filter(data, !is.na(lat))
data_nomatch <- filter(data, is.na(lat))%>%
  select(-lat, -lon)

#Try joining on city/state if no ZIP code match. Place matches back with data_match
data_nomatch <- data_nomatch %>%
  left_join(city, by = c("EMPLOYER_CITY", "EMPLOYER_STATE")) 
data_match <- bind_rows(data_match, filter(data_nomatch, !is.na(lat)))
data_nomatch <- filter(data_nomatch, is.na(lat)) 

#Write matched data to CSV
write_csv(data_match, "working/data_geocode.csv")

#Write non-matched data to CSV
write_csv(data_nomatch, "working/data_failedgeocode.csv")