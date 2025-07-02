# run_all.R

library(quarto)

# Analyse de la base de données ICRESAT (année 2014) dans l’ordre
quarto_render(
  input = "ICRESAT_database_analysis/CultData1_merging.qmd",
  output_format = "html"
  )


quarto_render("CultData2_cleaning.qmd")
quarto_render("CultData3_analysis_1.qmd")
quarto_render("CultData3_analysis_2.qmd")

