# Cleaning awful gov spreadsheets

library(tidyverse)
library(readxl)

# Which parts of each sheet to extract
tabs = list(sheet = 1:14,
            labs = list(c("A5", "J5", "S5"),
                        c("A5", "J5", "S5"),
                        c("A5", "J5", "S5"),
                        c("A5", "J5", "S5"),
                        c("A5", "K5", "U5"),
                        c("A5", "K5", "U5"),
                        c("A5", "H5", "O5"),
                        c("A5", "H5", "O5"),
                        c("A5", "O5", "AC5"),
                        c("A5", "O5", "AC5"),
                        c("A5", "J5", "S5"),
                        c("A5", "J5", "S5"),
                        c("A5", "J5", "S5"),
                        c("A5", "J5", "S5")),
            data = list(c("A6:H15", "J6:Q15", "S6:Z15"),
                        c("A6:H15", "J6:Q15", "S6:Z15"),
                        c("A6:H15", "J6:Q15", "S6:Z15"),
                        c("A6:H15", "J6:Q15", "S6:Z15"),
                        c("A6:I15", "K6:S15", "U6:AC15"),
                        c("A6:I15", "K6:S15", "U6:AC15"),
                        c("A6:F15", "H6:M15", "O6:T15"),
                        c("A6:F15", "H6:M15", "O6:T15"),
                        c("A6:M15", "O6:AA15", "AC6:AO15"),
                        c("A6:M15", "O6:AA15", "AC6:AO15"),
                        c("A6:H15", "J6:Q15", "S6:Z15"),
                        c("A6:H15", "J6:Q15", "S6:Z15"),
                        c("A6:H15", "J6:Q15", "S6:Z15"),
                        c("A6:H15", "J6:Q15", "S6:Z15")))

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
               sheet = paste0("Table_", i), range = j, col_names = F) %>% 
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