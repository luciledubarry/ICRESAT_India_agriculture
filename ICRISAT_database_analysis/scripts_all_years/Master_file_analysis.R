library(here)
library(quarto)
library(dplyr)
library(haven)
library(fs)

rm(list = ls())
graphics.off()
cat("\014")

here::i_am("ICRISAT_database_analysis/scripts_all_years/Master_file_analysis.R")


# Sous-dossier pour les sorties html
output_dir <- here("ICRISAT_database_analysis/scripts_all_years", "outputs_html")


# Lancer les fichiers d'analyse
files_to_render <- c("Regression_labor", "Analysis_production", "Analysis_mecanisation", "Analysis_gender", "Analysis_caste")

for (file in files_to_render) {
  cat("Traitement du fichier :", file, "\n")
  quarto::quarto_render(
    input = here("ICRISAT_database_analysis/scripts_all_years", paste0(file, ".qmd")),
    output_file = paste0(file, ".html")
  )
  file_move(paste0(file, ".html"), path(output_dir, paste0(file, ".html")))
}
