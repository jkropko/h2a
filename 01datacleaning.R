#LOAD LIBRARIES
library(tidyverse)

#LOAD DATA
#h2a
dat_h2a <- read_csv("working/DOL_H-2A_Data_FY21_22.csv") %>%
  mutate(TYPE = "H-2A",
         PER = tolower(PER)) %>%
  unite(WAGE, WAGE_OFFER, PER, sep = " per ") %>%
  select(TYPE, CASE_NUMBER, CASE_STATUS, 
         contains("WORKSITE"), JOB_TITLE, WAGE)

#h2b
dat_h2b <- read_csv("working/DOL_H-2B_Data_FY21_22.csv") %>%
  mutate(TYPE = "H-2B",
         PER = tolower(PER)) %>%
  unite(WAGE, BASIC_WAGE_RATE_FROM, BASIC_WAGE_RATE_TO, sep = "-") %>%
  unite(WAGE, WAGE, PER, sep = " per ") %>%
  select(TYPE, CASE_NUMBER, CASE_STATUS, 
         contains("WORKSITE"), JOB_TITLE, WAGE)

#append
dat_pool <- bind_rows(dat_h2a, dat_h2b) %>%
  filter(!CASE_STATUS %in% c("Determination Issued - Denied", 
                             "Determination Issued - Rejected",
                             "Determination Issued - Withdrawn",
                             "Withdrawn"))
write_csv(dat_pool, "working/dat_pool.csv")


