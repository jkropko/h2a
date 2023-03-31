#LOAD LIBRARIES
library(tidyverse)

#LOAD DATA
#h2a
dat_h2a <- read_csv("working/DOL_H-2A_Data_FY21_22.csv") %>%
  mutate(TYPE = "H-2A") %>%
  select(TYPE, CASE_NUMBER, CASE_STATUS, contains("WORKSITE"))

#h2b
dat_h2b <- read_csv("working/DOL_H-2B_Data_FY21_22.csv") %>%
  mutate(TYPE = "H-2B") %>%
  select(TYPE, CASE_NUMBER, CASE_STATUS, contains("WORKSITE"))

#append
dat_pool <- bind_rows(dat_h2a, dat_h2b) %>%
  filter(!CASE_STATUS %in% c("Determination Issued - Denied", 
                             "Determination Issued - Rejected",
                             "Determination Issued - Withdrawn",
                             "Withdrawn"))
write_csv(dat_pool, "working/dat_pool.csv")


