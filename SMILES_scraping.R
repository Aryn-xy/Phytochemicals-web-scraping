install.packages("httr")
install.packages("readr")
library(httr)
library(readr)



get_pubchem_smiles <- function(compound_name) {
  # Construct the URL for the PubChem API query.This URL queries for the CanonicalSMILES property for the given compound name.
  url <- paste0("https://pubchem.ncbi.nlm.nih.gov/compound/",
                URLencode(compound_name),
                "/property/CanonicalSMILES/CSV")
  
  # Send GET request
  response <- GET(url)
  
  # this will check if the request was successful
  if (status_code(response) == 200) {
    # Get the content as text
    content_text <- content(response, as = "text", encoding = "UTF-8")
    
    # Read the CSV content into a data frame
    df <- read_csv(content_text, show_col_types = FALSE)
    
    if (nrow(df) > 0 && "CanonicalSMILES" %in% names(df)) {
      return(df$CanonicalSMILES[1])
    }
  }
  
  # If the API call fails, return NA
  return(NA)
}

# Testing the function with a compound name
print(get_pubchem_smiles("Hesperidin"))


# Example Create a small dataframe of phytochemical names
df <- data.frame(Phytochemical = c("Hesperidin", "Quercetin", "Apigenin"), stringsAsFactors = FALSE)

df$SMILES <- sapply(df$Phytochemical, get_pubchem_smiles)

print(df)


library(httr)
library(jsonlite)

get_pubchem_smiles_json <- function(compound_name) {
  # this will construct URL for JSON output
  url <- paste0("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/",
                URLencode(compound_name),
                "/property/CanonicalSMILES/JSON")
  
  response <- GET(url)
  
  # it check if the request was successful
  if (status_code(response) == 200) {
    json_content <- content(response, as = "parsed", encoding = "UTF-8")
    if (!is.null(json_content$PropertyTable$Properties)) {
      return(json_content$PropertyTable$Properties[[1]]$CanonicalSMILES)
    } else {
      message("No properties found for: ", compound_name)
      return(NA)
    }
  } else {
    message("Request failed for: ", compound_name, " with status: ", status_code(response))
    return(NA)
  }
}

# Testing the function with a known compound
print(get_pubchem_smiles_json("Hesperidin"))

df <- data.frame(Phytochemical = c("Hesperidin", "Quercetin", "Apigenin"), stringsAsFactors = FALSE)
df$SMILES <- sapply(df$Phytochemical, get_pubchem_smiles_json)
print(df)

install.packages("readxl")
install.packages("writexl")
install.packages("httr")
install.packages("jsonlite")

library(readxl)
library(writexl)
library(httr)
library(jsonlite)
get_pubchem_smiles_json <- function(compound_name, retries = 3, delay = 2) {
  # Constructing the URL for JSON output
  url <- paste0("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/name/",
                URLencode(compound_name),
                "/property/CanonicalSMILES/JSON")
  
  attempt <- 1
  while (attempt <= retries) {
    response <- tryCatch(
      {
        # Force HTTP/1.1 using config(http_version = 1)
        GET(url, config = config(http_version = 1))
      },
      error = function(e) {
        message("Error on attempt ", attempt, " for ", compound_name, ": ", e$message)
        return(NA)
      }
    )
    
    # this check if response is a list and has a status code. If not, it's an error
    if (is.list(response) && !is.null(response$status_code)) {
      if (response$status_code != 200) {
        message("Request failed for: ", compound_name, " with status: ", response$status_code)
        Sys.sleep(delay)
        attempt <- attempt + 1
        next
      } else {
        # Extract the content only if the request was successful
        json_content <- content(response, as = "parsed", encoding = "UTF-8")
        if (!is.null(json_content$PropertyTable$Properties)) {
          return(json_content$PropertyTable$Properties[[1]]$CanonicalSMILES)
        } else {
          message("No properties found for: ", compound_name)
          return(NA)
        }
      }
    } else {
      # Handling case where response is not a standard httr response object.
      message("Unexpected response format for ", compound_name, ": ", class(response))
      Sys.sleep(delay)
      attempt <- attempt + 1
    }
  }
  
  # If all attempts fail, return NA
  return(NA)
}

# just testing the function with a known compound
print(get_pubchem_smiles_json("Hesperidin"))

# Reading  Excel file
df <- read_excel("unique_phytochemicals.xlsx")

# Initializing a SMILES column
df$SMILES <- NA

# Loop over each compound and i have added a delay to avoid rate limiting
n <- nrow(df)
for (i in 1:n) {
  compound <- df$Phytochemical[i]
  cat("Processing (", i, "/", n, "):", compound, "\n")
  df$SMILES[i] <- get_pubchem_smiles_json(compound)
  Sys.sleep(0.5)
}

# Saving the updated dataframe to a new Excel file
write_xlsx(df, "phytochemicals_with_smiles.xlsx")
cat("done! Check 'phytochemicals_with_smiles.xlsx'.\n")


library(readxl)

my_data <- read_excel("phytochemicals & smiles.xlsx")

print(class(my_data))
print(head(my_data))

# Accessing "Phytochemical" named column
phytochemicals <- my_data$Phytochemical
print(head(phytochemicals))

# i encountered an issue where  from the above code some smiles couldn't be extracted. so i tried another way.
# Filter rows where SMILES is NA
missing_smiles <- my_data[is.na(my_data$SMILES), ]

# printing the number of compounds missing SMILES
cat("Number of compounds with missing SMILES:", nrow(missing_smiles), "\n")

library(writexl)
write_xlsx(missing_smiles, "phytochemicals_missing_smiles.xlsx")


library(readxl)
library(writexl)
library(rvest)
library(stringr)
library(httr)
library(jsonlite)

get_pubchem_cid <- function(imppat_id) {
  url <- paste0("https://cb.imsc.res.in/imppat/phytochemical-detailedpage/", imppat_id)
  
  page <- tryCatch({
    read_html(url)
  }, error = function(e) {
    message("Error reading ", url, ": ", e$message)
    return(NA)
  })
  if (is.na(page)) return(NA)
  
  # Get this get all text from the page
  page_text <- page %>% html_text()
  
  # Looking for the pattern "CID:" followed by digits
  cid_match <- str_match(page_text, "CID:\\s*([0-9]+)")
  
  if (!is.na(cid_match[1,2])) {
    return(cid_match[1,2])
  } else {
    message("No CID found for ", imppat_id)
    return(NA)
  }
}

get_smiles_from_cid <- function(cid) {
  if (is.na(cid) || cid == "") return(NA)
  
  url <- paste0("https://pubchem.ncbi.nlm.nih.gov/rest/pug/compound/cid/", cid, "/property/CanonicalSMILES/JSON")
  response <- tryCatch(GET(url), error = function(e) {
    message("Error querying PubChem for CID ", cid, ": ", e$message)
    return(NA)
  })
  
  if (!inherits(response, "response")) return(NA)
  
  if (status_code(response) == 200) {
    json_data <- content(response, as = "parsed", encoding = "UTF-8")
    if (!is.null(json_data$PropertyTable$Properties)) {
      return(json_data$PropertyTable$Properties[[1]]$CanonicalSMILES)
    }
  }
  return(NA)
}

missing_df <- read_excel("phytochemicals_missing_smiles.xlsx")

# Initializing the columns if they don't exist:
if (!("PubChemCID" %in% names(missing_df))) {
  missing_df$PubChemCID <- NA
}
if (!("SMILES" %in% names(missing_df))) {
  missing_df$SMILES <- NA
}

n <- nrow(missing_df)
for (i in 1:n) {
  # Firstly, ensuring that a PubChemCID for this row, is available.
  if (is.na(missing_df$PubChemCID[i]) || missing_df$PubChemCID[i] == "") {
    imp_id <- missing_df$Identifier[i]
    cat("Extracting CID for (", i, "/", n, "):", imp_id, "\n")
    missing_df$PubChemCID[i] <- get_pubchem_cid(imp_id)
    Sys.sleep(0.5)  # delay to be polite to server.
  }
  
  # Now, using the CID to get the SMILES
  cid <- missing_df$PubChemCID[i]
  cat("Processing CID (", i, "/", n, "):", cid, "\n")
  missing_df$SMILES[i] <- get_smiles_from_cid(cid)
  Sys.sleep(0.5)
}

# Save the updated data frame to a new Excel file
write_xlsx(missing_df, "phytochemicals_missing_smiles_updated.xlsx")
cat("done!!! 'phytochemicals_missing_smiles_updated.xlsx'\n")


library(readxl)
library(dplyr)
library(writexl)

# Load the original dataset
orig_df <- read_excel("phytochemicals_with_smiles_final.xlsx")

# Filter rows where SMILES are missing (i.e. NA or empty string)
missing_df <- orig_df %>% filter(is.na(SMILES) | SMILES == "")

cat("Number of compounds missing SMILES:", nrow(missing_df), "\n")

# Save the final merged dataset
write_xlsx(merged_df, "phytochemicals_with_smiles_final_combined.xlsx")
cat(" Final merged file saved as 'phytochemicals_with_smiles_final_combined.xlsx'.\n")

# i changed the file name to "phytochemicals with smiles final combined.xlsx"
df <- read_excel("phytochemicals with smiles final combined.xlsx")

# this will check for duplicates in the "Phytochemical" column
duplicate_count <- sum(duplicated(df$Phytochemical))
cat("Number of duplicate phytochemicals found:", duplicate_count, "\n")

# this will remove duplicate rows based on the "Phytochemical" column,keeping only the first occurrence of each unique phytochemical.
df_unique <- df %>% distinct(Phytochemical, .keep_all = TRUE)

# this checks the number of rows before and after, just for transparency.
cat("Original row count:", nrow(df), "\n")
cat("Unique row count:", nrow(df_unique), "\n")

write_xlsx(df_unique, "phytochemicals with smiles final unique.xlsx")
cat("Duplicate phytochemicals removed. Unique dataset saved as 'phytochemicals_with_smiles_final_unique.xlsx'.\n")

