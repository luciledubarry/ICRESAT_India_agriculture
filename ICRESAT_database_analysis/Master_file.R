library(here)
library(quarto)
library(dplyr)
library(haven)

rm(list = ls())
graphics.off()
cat("\014")

here::i_am("ICRESAT_database_analysis/Master_file.R")

# Sélectionner les années
annees <- 2011:2014

# Lancer les fichiers CultData1 et CultData2 pour chaque année
for (annee in annees) {
  cat("Traitement de l'année", annee, "\n")
  
  quarto::quarto_render(
    input = here::here("ICRESAT_database_analysis", "CultData1_merging_V2.qmd"),
    execute_params = list(annee = annee),
    output_file = paste0("CultData1_merging_", annee, ".html")
    )
  
  quarto::quarto_render(
    input = here::here("ICRESAT_database_analysis", "CultData2_cleaning_V2.qmd"),
    execute_params = list(annee = annee),
    output_file = paste0("CultData2_cleaning_", annee, ".html")
  )
}

list_bases <- list()

# Enregistrer les tables par année
for (annee in annees) {
  fichier_rds <- here::here("Base de données générées", "Cultivation_expand", paste0("Cultivation_expand_", annee, ".rds"))
  if (file.exists(fichier_rds)) {
    base <- readRDS(fichier_rds)
    base$YEAR <- annee  # Ajouter la variable année
    list_bases[[as.character(annee)]] <- base
  } else {
    message("Fichier manquant pour l'année ", annee)
  }
}

# Fusionner les années
Cultivation_expand_all <- bind_rows(list_bases)
Cultivation_expand_all <- Cultivation_expand_all |> relocate(YEAR, .before = VDS_ID)

# Enregistrer la table finale
folder_path <- here("Base de données générées", "Cultivation_expand")

write.csv(
  Cultivation_expand_all,
  file = file.path(folder_path, "Cultivation_expand_all.csv"),
  row.names = FALSE
)

saveRDS(
  Cultivation_expand_all, 
  file = file.path(folder_path, "Cultivation_expand_all.rds")
)

write_dta(
  Cultivation_expand_all,
  path = file.path(folder_path, "Cultivation_expand_all.dta")
)
