#LOAD LIBRARIES
library(tidyverse)
library(readxl)

#LOAD DATA
get_files <- list.files("original/DOL ETA Data/")
file_list <- lapply(get_files, function(x) {
  print(x)
  read_excel(paste0("original/DOL ETA Data/", x), col_types = "text", n_max = 1)  
})
colnames_list <- lapply(file_list, names)
all_names <- unique(unlist(colnames_list))
file_var_mat <- sapply(colnames_list, function(x) (all_names %in% x * 1)) 
dimnames(file_var_mat) <- list(all_names, get_files)
file_var_df <- data.frame(file_var_mat)
common_vars <- rownames(filter(file_var_df, rowMeans(file_var_df) == 1))
data_pooled <- lapply(file_list, select, all_of(common_vars)) %>%
  bind_rows()
write_csv(data_pooled, "working/data_pooled_historical.csv")


