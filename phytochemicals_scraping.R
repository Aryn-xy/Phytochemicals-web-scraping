install.packages("rvest")
install.packages("dplyr")


library(rvest)
library(dplyr)


install.packages("readxl")
library(readxl)

plant_names<-read_excel("finalized plants.xlsx") # this file contain list of plants with antibacterial agents obtained from IMPPAT
head(plant_names)
tail(plant_names)

results <- data.frame(PlantName = character(),
                      Phytochemicals = character(),
                      stringsAsFactors = FALSE)


for(i in seq_len(nrow(plant_names))) {
  plant <- plant_names$PlantName[i]
  cat("Processing:", plant, "\n")
  formatted_plant <- tolower(plant)
}

formatted_plant <- gsub(" ", "-", formatted_plant)
formatted_plant <- URLencode(formatted_plant)

base_url <-"https://cb.imsc.res.in/imppat/basicsearch/phytochemical/"
plant_url <- paste0(base_url, formatted_plant)
library(rvest)

page <- read_html("https://cb.imsc.res.in/imppat/phytochemical/Abies%20pindrow")

table <- page %>% html_node("table") %>% html_table(fill = TRUE)

print(table)

View(table)
phytochem_table <- page %>% html_node("table") %>% html_table(fill = TRUE)
results <- bind_rows(results, phytochem_table)

Sys.sleep(1)

write.csv(results, "imppat_phytochemicals.csv", row.names = FALSE)
head(results)

