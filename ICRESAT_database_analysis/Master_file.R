library(here)
library(quarto)
library(dplyr)
library(haven)

rm(list = ls())
graphics.off()
cat("\014")

here::i_am("ICRESAT_database_analysis/Master_file_tables.R")


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




################################################################################

# Au niveau de l'opération : Cultivation_oper

for (annee in annees) {
  fichier_rds <- here::here("Base de données générées", "Cutlivation_oper", paste0("Cultivation_oper_", annee, ".rds"))
  if (file.exists(fichier_rds)) {
    base <- readRDS(fichier_rds)
    base$YEAR <- annee  # Ajouter la variable année
    list_bases[[as.character(annee)]] <- base
  } else {
    message("Fichier manquant pour l'année ", annee)
  }
}

Cultivation_oper_all <- bind_rows(list_bases)
Cultivation_oper_all <- Cultivation_oper_all |> relocate(YEAR, .before = VDS_ID)

folder_path <- here("Base de données générées", "Cultivation_oper")
write.csv(
  Cultivation_oper_all,
  file = file.path(folder_path, "Cultivation_oper_all.csv"),
  row.names = FALSE
)
saveRDS(
  Cultivation_oper_all, 
  file = file.path(folder_path, "Cultivation_oper_all.rds")
)
write_dta(
  Cultivation_oper_all,
  path = file.path(folder_path, "Cultivation_oper_all.dta")
)


# Au niveau du champ : Cultivation_plot

for (annee in annees) {
  fichier_rds <- here::here("Base de données générées", "Cultivation_plot", paste0("Cultivation_plot_", annee, ".rds"))
  if (file.exists(fichier_rds)) {
    base <- readRDS(fichier_rds)
    base$YEAR <- annee  # Ajouter la variable année
    list_bases[[as.character(annee)]] <- base
  } else {
    message("Fichier manquant pour l'année ", annee)
  }
}

Cultivation_plot_all <- bind_rows(list_bases)
Cultivation_plot_all <- Cultivation_plot_all |> relocate(YEAR, .before = VDS_ID)

folder_path <- here("Base de données générées", "Cultivation_plot")
write.csv(
  Cultivation_plot_all,
  file = file.path(folder_path, "Cultivation_plot_all.csv"),
  row.names = FALSE
)
saveRDS(
  Cultivation_plot_all, 
  file = file.path(folder_path, "Cultivation_plot_all.rds")
)
write_dta(
  Cultivation_plot_all,
  path = file.path(folder_path, "Cultivation_plot_all.dta")
)


# Au niveau du ménage : Cultivation_hh

for (annee in annees) {
  fichier_rds <- here::here("Base de données générées", "Cultivation_hh", paste0("Cultivation_hh_", annee, ".rds"))
  if (file.exists(fichier_rds)) {
    base <- readRDS(fichier_rds)
    base$YEAR <- annee  # Ajouter la variable année
    list_bases[[as.character(annee)]] <- base
  } else {
    message("Fichier manquant pour l'année ", annee)
  }
}

Cultivation_hh_all <- bind_rows(list_bases)
Cultivation_hh_all <- Cultivation_hh_all |> relocate(YEAR, .before = VDS_ID)

folder_path <- here("Base de données générées", "Cultivation_hh")
write.csv(
  Cultivation_hh_all,
  file = file.path(folder_path, "Cultivation_hh_all.csv"),
  row.names = FALSE
)
saveRDS(
  Cultivation_hh_all, 
  file = file.path(folder_path, "Cultivation_hh_all.rds")
)
write_dta(
  Cultivation_hh_all,
  path = file.path(folder_path, "Cultivation_hh_all.dta")
)


