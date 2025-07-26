# Phytochemicals-web-scraping
This repository contains R code to scrape phytochemical data from a target website and extract key drug-likeness properties as defined by Lipinski’s Rule of Five. The script collects following from Indian Medicinal Plants, Phytochemistry And Therapeutics 2.0 (IMPPAT 2.0):

- **SMILES**: A text representation of a compound’s chemical structure.
- **H-Bond Acceptors**: The number of hydrogen bond acceptor groups.
- **H-Bond Donors**: The number of hydrogen bond donor groups.
- **LogP**: A measure of lipophilicity.
- **Molecular Weight (g/mol)**: The mass of a compound in g/mol.


## Overview

This project demonstrates how to:

- Read a list of phytochemical identifiers or names from an Excel or CSV file.
- Construct URLs for each phytochemical to access detailed information.
- Scrape the compound’s SMILES and Lipinski properties from the resulting web pages.
- Combine and save the results to an output file (Excel or CSV).

This code serves as a starting point for further analysis, such as evaluating drug-likeness or prioritizing compounds for further study.

## Prerequisites

The following R packages are required:

- **rvest**: For parsing HTML.
- **dplyr**: For data manipulation.
- **readxl**: For reading Excel files.
- **writexl**: For writing results to Excel.
- **jsonlite**: For parsing JSON (if needed).
- **httr** (optional): For handling HTTP requests if required.

You can install these packages by running:

```r
install.packages(c("rvest", "dplyr", "readxl", "writexl", "jsonlite", "httr"))
```
