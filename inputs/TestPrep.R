getwd()
setwd("RData/")
getwd()

# --------------------------------------
# 1) Načtení nezbytných balíčků
# --------------------------------------
library(rvest)    # pro webscraping
library(dplyr)    # pro práci s data framy
library(stringr)  # pro práci s regulárními výrazy

# --------------------------------------
# 2) Definujeme cílovou URL a načteme HTML
# --------------------------------------
base_url <- "https://en.wikipedia.org"
page_url <- paste0(base_url, "/wiki/Category:Women_on_the_Manhattan_Project")

# Stáhneme HTML kód hlavní stránky
page <- read_html(page_url)

# --------------------------------------
# 3) Vytáhneme jména a odkazy
#    - Na stránce vidíme <div class="mw-category-group"> s <ul><li><a ...>
# --------------------------------------
names_nodes <- page %>%
  html_elements(".mw-category-group ul li a")

# extrahujeme text (jména) a odkazy
women_names <- names_nodes %>% html_text()
women_links <- names_nodes %>% html_attr("href")

# protože href je relativní, doplníme base_url:
women_links_full <- paste0(base_url, women_links)

# Vytvoříme první tabulku
women_df <- data.frame(
  name = women_names,
  link = women_links_full,
  stringsAsFactors = FALSE
)
#Po kontrole dat: tohle je skupina, tu odstranim
women_df <- women_df[-c(1), ]
# --------------------------------------
# 4) Vybereme náhodně 4 ženy z tabulky
# --------------------------------------
set.seed(123)  # pro reprodukovatelnost
sampled_women <- sample_n(women_df, 4)

# --------------------------------------
# 5) U každé z nich načteme její stránku a zkusíme najít:
#    - rok narození,
#    - rok úmrtí,
#    - alma mater.
#
#    Použijeme kombinaci rvest (HTML parsing) a regexů.
#    Po každém načtení stránky dáme Sys.sleep(2).
# --------------------------------------
results <- data.frame(
  name = character(),
  born_year = character(),
  died_year = character(),
  alma_mater = character(),
  stringsAsFactors = FALSE
)

for(i in 1:nrow(sampled_women)) {
  Sys.sleep(2)  # pauza 2 sekundy
  
  person_name <- sampled_women$name[i]
  person_link <- sampled_women$link[i]
  
  cat("Načítám stránku:", person_link, "\n")
  person_page <- tryCatch(read_html(person_link), error = function(e) NULL)
  
  if (!is.null(person_page)) {
    # Zkusíme vyhledat text "Born" a k němu rok
    # Wikipedia často má např. <span class="bday">1917</span> nebo "Born in 1917 ..."
    # Můžeme zkusit různá místa, zde ukázkově:
    
    full_text <- person_page %>% html_text2()  # čistý text celé stránky
    
    # 1) Born year (zjednodušeně):
    born_year <- str_extract(full_text, "Born[^0-9]*([0-9]{4})")
    # extrahujeme jen 4 cifry:
    born_year <- str_extract(born_year, "[0-9]{4}")
    
    # 2) Died year:
    died_year <- str_extract(full_text, "Died[^0-9]*([0-9]{4})")
    died_year <- str_extract(died_year, "[0-9]{4}")
    
    # 3) Alma mater:
    # Často se objevuje jako "Alma mater" s univerzitami. 
    # Může být ale různě formátováno, proto jen ukázka:
    # Jedna z možností: <th scope="row">Alma&nbsp;mater</th><td> ...
    # Můžeme zkusit: vyhledat element <th> s textem "Alma mater" a poté <td>.
    alma_node <- person_page %>%
      html_element(xpath = "//th[contains(., 'Alma mater')]/following-sibling::td")
    
    alma_mater <- NA
    if (!is.null(alma_node)) {
      alma_mater <- alma_node %>% html_text2()
      alma_mater <- str_squish(alma_mater)  # ořežeme bílé znaky
    }
    
    # Zapisujeme do výsledků
    results <- rbind(results,
                     data.frame(
                       name        = person_name,
                       born_year   = ifelse(is.na(born_year), NA, born_year),
                       died_year   = ifelse(is.na(died_year), NA, died_year),
                       alma_mater  = ifelse(is.na(alma_mater), NA, alma_mater),
                       stringsAsFactors = FALSE
                     )
    )
  } else {
    # Kdyby stránku nešlo načíst:
    results <- rbind(results,
                     data.frame(
                       name        = person_name,
                       born_year   = NA,
                       died_year   = NA,
                       alma_mater  = NA,
                       stringsAsFactors = FALSE
                     )
    )
  }
}

# --------------------------------------
# 6) Výsledné tabulky:
# --------------------------------------

# Tabulka se všemi z Category:Women_on_the_Manhattan_Project
women_df

# Tabulka se 4 náhodně vybranými ženami a doplněnými údaji
results
