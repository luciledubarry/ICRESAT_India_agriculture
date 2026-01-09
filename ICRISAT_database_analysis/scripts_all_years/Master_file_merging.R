library(here)
library(quarto)
library(dplyr)
library(haven)
library(fs)

rm(list = ls())
graphics.off()
cat("\014")

# Déclare le fichier "ancre" pour here()
here::i_am("ICRISAT_database_analysis/scripts_all_years/Master_file_merging.R")


# Sélectionner les années
annees <- 2011:2014


# Sous-dossier pour les sorties html
output_dir <- here("ICRISAT_database_analysis", "scripts_all_years", "outputs_html")
fs::dir_create(output_dir)

# Chemins des .qmd (orthographe corrigée : ICRISAT)
qmd1 <- here("ICRISAT_database_analysis", "scripts_all_years", "CultData1_merging.qmd")
qmd2 <- here("ICRISAT_database_analysis", "scripts_all_years", "CultData2_cleaning.qmd")

# Vérifications rapides
stopifnot(fs::file_exists(qmd1), fs::file_exists(qmd2))

# Lancer les fichiers CultData1 et CultData2 pour chaque année
for (annee in annees) {
  cat("\n=== Traitement de l'année", annee, "===\n")
  
  # CultData1
  output_file1 <- paste0("CultData1_merging_", annee, ".html")
  tryCatch({
  quarto::quarto_render(
    input = qmd1,
    execute_params = list(annee = annee),
    output_file = output_file1,
    quiet = FALSE
  )
  cat("OK ->", fs::path(output_dir, output_file1), "\n")
}, error = function(e) {
  cat("ERREUR CultData1 (", annee, "): ", conditionMessage(e), "\n", sep = "")
})
  
# CultData2
output_file2 <- paste0("CultData2_cleaning_", annee, ".html")
tryCatch({
  quarto::quarto_render(
    input         = qmd2,
    execute_params = list(annee = annee),
    output_file   = output_file2,
    quiet         = FALSE
  )
  cat("OK ->", fs::path(output_dir, output_file2), "\n")
}, error = function(e) {
  cat("ERREUR CultData2 (", annee, "): ", conditionMessage(e), "\n", sep = "")
})
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

