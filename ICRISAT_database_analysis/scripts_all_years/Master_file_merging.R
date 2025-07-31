library(here)
library(quarto)
library(dplyr)
library(haven)
library(fs)

rm(list = ls())
graphics.off()
cat("\014")

here::i_am("ICRISAT_database_analysis/scripts_all_years/Master_file_merging.R")


# Sélectionner les années
annees <- 2011:2014


# Sous-dossier pour les sorties html
output_dir <- here("ICRISAT_database_analysis/scripts_all_years", "outputs_html")


# Lancer les fichiers CultData1 et CultData2 pour chaque année
for (annee in annees) {
  cat("Traitement de l'année", annee, "\n")
  
  # CultData1
  output_file1 <- paste0("CultData1_merging_", annee, ".html")
  quarto::quarto_render(
    input = here::here("ICRESAT_database_analysis/scripts_all_years", "CultData1_merging.qmd"),
    execute_params = list(annee = annee),
    output_file = output_file1
  )
  file_move(output_file1, path(output_dir, output_file1))
  
  # CultData2
  output_file2 <- paste0("CultData2_cleaning_", annee, ".html")
  quarto::quarto_render(
    input = here::here("ICRESAT_database_analysis/scripts_all_years", "CultData2_cleaning.qmd"),
    execute_params = list(annee = annee),
    output_file = output_file2
  )
  file_move(output_file2, path(output_dir, output_file2))
}


# Fonction pour joindre les années et enregistrer
merge_save_files <- function(name_file) {
  list_bases <- list()
  
  for (annee in annees) {
    fichier_rds <- here("Base de données générées", name_file, paste0(name_file, "_", annee, ".rds"))
    
    if (file.exists(fichier_rds)) {
      base <- readRDS(fichier_rds)
      base$YEAR <- annee
      list_bases[[as.character(annee)]] <- base
    } else {
      message("Fichier manquant pour l'année ", annee, " pour ", name_file)
    }
  }
  
  df_all <- bind_rows(list_bases) |>
    relocate(YEAR, .before = VDS_ID)
  
  folder_path <- here("Base de données générées", name_file)
  
  write.csv(df_all, file = file.path(folder_path, paste0(name_file, "_all.csv")), row.names = FALSE)
  saveRDS(df_all, file = file.path(folder_path, paste0(name_file, "_all.rds")))
  write_dta(df_all, path = file.path(folder_path, paste0(name_file, "_all.dta")))
  
  return(df_all)
}


# Appliquer à chaque table
Cultivation_expand_all <- merge_save_files("Cultivation_expand")
Cultivation_oper_all <- merge_save_files("Cultivation_oper")
Cultivation_plot_all <- merge_save_files("Cultivation_plot")
Cultivation_hh_all   <- merge_save_files("Cultivation_hh")

