# Cleaning awful gov spreadsheets

library(tidyverse)
library(readxl)

# Which parts of each sheet to extract
tabs = list(sheet = 1:14,
            labs = list(c("A", "J", "S"),
                        c("A", "J", "S"),
                        c("A", "J", "S"),
                        c("A", "J", "S"),
                        c("A", "K", "U"),
                        c("A", "K", "U"),
                        c("A", "H", "O"),
                        c("A", "H", "O"),
                        c("A", "O", "AC"),
                        c("A", "O", "AC"),
                        c("A", "J", "S"),
                        c("A", "J", "S"),
                        c("A", "J", "S"),
                        c("A", "J", "S")),
            cols = c(8, 8, 8, 8,
                     9, 9,
                     6, 6,
                     13, 13,
                     8, 8, 8, 8))

# Extract useful info from table name
tab_grabber = function(var_txt, var_reg){
  x = str_extract(var_txt, var_reg)
  x = str_remove(x, "by ")
  str_replace_all(x, " ", "_")
}

# Run read and clean
dl = lapply(tabs$sheet, function(i){
  # table names
  tab_labs = lapply(tabs$labs[[i]], function(j){
    read_excel("../Consumption_headline_Scotland_2019.xlsx",
               sheet = paste0("Table_", i), range = paste0(j, 5), col_names = F) %>% 
      separate(...1, into = c("table", "desc"), sep = ": ")
  })
  
  # Sheet info (data name)
  tab_name = tab_grabber(tab_labs[[1]]$desc, "by.*$")
  
  # table data
  tab_data = lapply(tabs$data[[i]], function(j){
    read_excel("../Consumption_headline_Scotland_2019.xlsx",
               sheet = paste0("Table_", i), range = j, col_names = T) %>% 
      pivot_longer(!Year, names_to = tab_name)
  })
  
  
  # first 2 words for var description
  # need mean/median and gas/electric
  # which as col name? avg
  # which as col? gas/elec
  tab_col2 = tab_grabber(tab_labs[[2]]$desc, "^.*consumption")
  tab_col3 = tab_grabber(tab_labs[[3]]$desc, "^.*consumption")
  
  fuel = str_extract(tab_col2, "gas|electric")
  
  tab_col2 = str_remove(tab_col2, "gas_|electricity_")
  tab_col3 = str_remove(tab_col3, "gas_|electricity_")
  
  tab_data[[1]] %>% 
    rename(properties = value) %>% 
    inner_join(tab_data[[2]] %>% 
                 rename(!!tab_col2 := value)) %>% 
    inner_join(tab_data[[3]] %>% 
                 rename(!!tab_col3 := value)) %>% 
    rename_with(tolower) %>% 
    add_column(fuel = fuel)
})

# Run group and write
lapply(seq(1, 13, by = 2), function(i){
  bind_rows(dl[[i]], dl[[i + 1]]) %>% 
    write_csv(paste0("data_clean/consumption_scotland_", names(dl[[i]])[2], ".csv"))
})
