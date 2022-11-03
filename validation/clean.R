# Cleaning awful gov spreadsheets

library(tidyverse)
library(readxl)


# Which parts of each file to extract
# Where does data start
# How many rows does it have?
sheet = 1:14
start_row = 5
rows = 10



# Create start column letters from table width
# Works with 3 tables, with single blank row between
excel_headers = paste0(rep(c("", LETTERS), each = 26),
                       LETTERS)
data_corners = function(start_col = 1, table_cols){
  excel_headers[c(start_col, table_cols + 2, 2 * table_cols + 3)]
}

# Extract useful info from table name
tab_grabber = function(var_txt, var_reg){
  x = str_extract(var_txt, var_reg)
  x = str_remove(x, "by ")
  str_replace_all(x, " ", "_")
}

# Run read and clean
dl = lapply(sheet, function(i){

  # How many columns?
  col_count = tibble(x = as.character(read_excel("../Consumption_headline_Scotland_2019.xlsx",
                                                 sheet = paste0("Table_", i),
                                                 range = paste0("A", start_row, ":AZ", start_row),
                                                 col_names = F))) %>% 
    mutate(x = replace(x, x == "NA", NA),
           is_na = if_else(is.na(x), 1, 0))
  col_count = sum(col_count[1:which(str_detect(col_count$x, "Table .*b:.*$")), ]$is_na)
  
  # table names and data
  tab_data = lapply(data_corners(table_cols = col_count), function(j){
    tab_labs = read_excel("../Consumption_headline_Scotland_2019.xlsx",
               sheet = paste0("Table_", i), range = paste0(j, start_row), col_names = F) %>% 
      separate(...1, into = c("table", "desc"), sep = ": ")
    
    # Sheet info (data names)
    tab_name = tab_grabber(tab_labs$desc, "by.*$")
    tab_col = tab_grabber(tab_labs$desc, "^.*consumption")
    fuel = str_extract(tab_col, "gas|electric")
    tab_col = str_remove(tab_col, "gas_|electricity_")
    
    # table data
    x = read_excel("../Consumption_headline_Scotland_2019.xlsx",
               sheet = paste0("Table_", i),
               range = anchored(paste0(j, start_row + 1), c(rows, col_count)),
               col_names = T) %>% 
      pivot_longer(!Year, names_to = tab_name,
                   values_to = if_else(is.na(tab_col), "properties", tab_col))
    
    # property counts or consumption?
    if (is.na(fuel)){
      x
    } else {
      x = x %>% 
        add_column(fuel = fuel, .before = 3)
    }
  })
  
  x = tab_data[[1]] %>% 
    inner_join(tab_data[[2]]) %>% 
    inner_join(tab_data[[3]]) %>% 
    rename_with(tolower)
  
  x[, 2] = str_remove(unlist(x[, 2]), "\\r\\n")
  x
})

# Run group and write
lapply(seq(1, 13, by = 2), function(i){
  bind_rows(dl[[i]], dl[[i + 1]]) %>% 
    write_csv(paste0("data_clean/consumption_scotland_", names(dl[[i]])[2], ".csv"))
})
