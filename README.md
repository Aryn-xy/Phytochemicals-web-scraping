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

## Usage

1. **Prepare your Input File:**  
   Create a CSV (or Excel) file containing a list of plant name or phytochemical names (if available) or identifiers. For example, your CSV file might include a column named `PhytochemicalName`.

2. **Configure the Script:**  
   - Modify the input file path in the script.
   - Set the base URL pattern for the target website.
   - Adjust the CSS selectors used to extract the SMILES string and Lipinski properties (e.g., if the SMILES are found in an element with a specific class or if the property values are in a table with a particular id).
   - If any JSON data is returned by the website, use **jsonlite** to parse it.

3. **Run the Script:**  
   Execute the R script. The script will loop through each phytochemical, scrape the necessary details, and save the combined results to an output file.

# Modify: 
- The **base URL** to match the target website.
- The **CSS selectors** (e.g., `.smiles`, `#lipinski-table`) to correctly target the desired elements.
- The **property names** in the Lipinski table if they differ.
- If the website returns any JSON data, you can use **jsonlite** to parse it:
>   ```r
>   json_data <- fromJSON(content)
>   ```
- If you need to handle HTTP requests (for example, using API endpoints), the **httr** package can be helpful.




This code represents a basic implementation of web scraping techniques using R to extract phytochemical data and evaluate key Lipinski’s rule properties, including SMILES, hydrogen bond acceptors, hydrogen bond donors, logP, and molecular weight. Developed as part of my final year project dissertation, the script is intentionally simple to demonstrate the fundamental concepts of data extraction and processing from web sources.
