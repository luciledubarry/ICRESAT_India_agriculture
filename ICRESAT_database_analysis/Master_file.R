library(here)
library(quarto)
rm(list = ls())
graphics.off()
cat("\014")

here::i_am("ICRESAT_database_analysis/Master_file.R")

# Sélectionner les années
annees <- 2011:2014
liste_annees <- list()

quarto_render(
  input = here::here("ICRESAT_database_analysis", "CultData1_merging_V2.qmd"),
  execute_params = list(annee = "2011")
)



# Lancer les fichiers CultData1 et CultData2 pour chaque année
for (annee in annees) {
  cat("Traitement de l'année", annee, "\n")
  
  quarto::quarto_render(
    input = here::here("ICRESAT_database_analysis", "CultData1_merging_V2.qmd"),
    execute_params = list(annee = annee)
  )
  #quarto::quarto_render("CultData2_cleaning.qmd", execute_params = list(annee = annee))
  
  tmp <- readRDS(paste0("outputs/Cultivation_", annee, ".rds"))
  tmp$annee <- annee  # Ajouter l'année
  liste_annees[[as.character(annee)]] <- tmp
}


# Fusionner les années
Cultivation_long <- dplyr::bind_rows(liste_annees)


# Sauvegarder la base finale
folder_path <- here("Base de données générées", "Cultivation_long")

if (!dir.exists(folder_path)) {
  dir.create(folder_path, recursive = TRUE)
}

write.csv(
  Cultivation_long,
  file = file.path(folder_path, "Cultivation_long.csv"),
  row.names = FALSE
)

saveRDS(
  Cultivation_long,
  file = file.path(folder_path, "Cultivation_long.rds"),
)
