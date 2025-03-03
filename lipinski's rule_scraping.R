install.packages(c("rvest", "dplyr", "readxl", "writexl"))
library(rvest)
library(dplyr)
library(readxl)
library(writexl)

get_physchem_props <- function(imppat_id) {
  base_url <- "https://cb.imsc.res.in/imppat/physicochemicalproperties/"
  url <- paste0(base_url, imppat_id)
  
  # this try to reading the page
  page <- tryCatch({
    read_html(url)
  }, error = function(e) {
    message("Error reading ", url, ": ", e$message)
    return(NULL)
  })
  
  if (is.null(page)) {
    return(data.frame(
      Identifier = imppat_id,
      Molecular_Weight = NA_real_,  # numeric columns
      LogP = NA_real_,
      H_Bond_Acceptors = NA_real_,
      H_Bond_Donors = NA_real_,
      stringsAsFactors = FALSE
    ))
  }
  
  # this will locate the main table
  table_node <- page %>% html_node("table")
  if (is.null(table_node)) {
    return(data.frame(
      Identifier = imppat_id,
      Molecular_Weight = NA_real_,
      LogP = NA_real_,
      H_Bond_Acceptors = NA_real_,
      H_Bond_Donors = NA_real_,
      stringsAsFactors = FALSE
    ))
  }
  
  # Convert to a data frame
  table_df <- table_node %>% html_table(fill = TRUE)
  # Typically: "Property", "Tool", "Property value"
  colnames(table_df) <- c("Property", "Tool", "Property_value")
  
  # Helper to retrieve the property value
  get_value <- function(df, property_name) {
    row <- df %>% filter(Property == property_name)
    if (nrow(row) == 0) return(NA_character_)
    row$Property_value[1]
  }
  
  # Extract the raw text
  mw_str <- get_value(table_df, "Molecular weight (g/mol)")
  logp_str <- get_value(table_df, "Log P")
  h_acc_str <- get_value(table_df, "Number of hydrogen bond acceptors")
  h_don_str <- get_value(table_df, "Number of hydrogen bond donors")
  
  # Convert to numeric, ignoring parse warnings
  mw <- suppressWarnings(as.numeric(mw_str))
  logp <- suppressWarnings(as.numeric(logp_str))
  h_acc <- suppressWarnings(as.numeric(h_acc_str))
  h_don <- suppressWarnings(as.numeric(h_don_str))
  
  data.frame(
    Identifier = imppat_id,
    Molecular_Weight = mw,
    LogP = logp,
    H_Bond_Acceptors = h_acc,
    H_Bond_Donors = h_don,
    stringsAsFactors = FALSE
  )
}

df_ids <- read_excel("phytochemicals with smiles final_combined.xlsx")

if (!"Identifier" %in% colnames(df_ids)) {
  stop("The Excel file must have a column named 'Identifier'.")
}

results <- data.frame(
  Identifier = character(),
  Molecular_Weight = numeric(),
  LogP = numeric(),
  H_Bond_Acceptors = numeric(),
  H_Bond_Donors = numeric(),
  stringsAsFactors = FALSE
)

for (i in seq_len(nrow(df_ids))) {
  imppat_id <- df_ids$Identifier[i]
  cat("Processing:", imppat_id, "\n")
  
  row_df <- get_physchem_props(imppat_id)
  results <- bind_rows(results, row_df)
  
  #  short delay to be polite to server
  Sys.sleep(0.5)
}

write_xlsx(results, "imppat_physchem_results.xlsx")
cat("Done! Check 'imppat_physchem_results.xlsx'.\n")