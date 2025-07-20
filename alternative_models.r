# Advanced Ancient Ancestry Analysis
# More comprehensive modeling like commercial services

library(admixtools)
library(tidyverse)

# Load your data
f2_data <- extract_f2("merged_dataset")
your_sample <- "IND1"

# Define comprehensive source populations by region/time including Pakistani/Shia Muslim specific
ancient_sources <- list(
  # Western Eurasian Hunter-Gatherers
  "WHG" = c("Loschbour", "WHG", "Cheddar_Man"),
  
  # Eastern European Hunter-Gatherers  
  "EHG" = c("Karelia_HG", "EHG", "Sidelkino_HG"),
  
  # Caucasus Hunter-Gatherers
  "CHG" = c("CHG", "Satsurblia", "Kotias"),
  
  # Anatolian Farmers
  "Anatolian_N" = c("Anatolia_N", "Barcin_N", "Tepecik_Ciftlik_N"),
  
  # Steppe Pastoralists
  "Steppe_EN" = c("Khvalynsk_EN", "Progress_EN", "Vonyuchka_EN"),
  "Steppe_EBA" = c("Yamnaya_RUS_Samara", "Yamnaya_UKR", "Afanasievo"),
  "Steppe_MLBA" = c("Andronovo", "Sintashta", "Srubnaya"),
  
  # Later European populations
  "Germanic_IA" = c("Germanic_IA", "Cimbri", "Anglo-Saxon"),
  "Celtic_IA" = c("Celtic_IA", "Hallstatt_Bylany", "La_Tene"),
  "Slavic_IA" = c("Slavic_IA", "Srubna", "Scythian_Pontic"),
  
  # Mediterranean/Southern European
  "Sardinian_N" = c("Sardinian.DG", "Sardinia_N", "Sicily_N"),
  "Iberian_BA" = c("Iberia_BA", "Iberia_Beaker", "Iberia_Celtic"),
  
  # Ancient DNA from Central/Northern Europe
  "Central_European_BA" = c("Corded_Ware_Germany", "Bell_Beaker_Germany", "Unetice"),
  "Northern_European_BA" = c("Sweden_BA", "Norway_BA", "Battle_Axe"),
  
  # === PAKISTANI/SHIA MUSLIM SPECIFIC ADDITIONS ===
  
  # Ancient Ancestral South Indian (AASI)
  "AASI" = c("Indian_GreatAndaman_100BP.SG", "Onge.DG", "Jarawa.DG"),
  
  # Iranian farmer-related (crucial for Pakistani ancestry)
  "Iranian_Farmers" = c("Iran_ShahrISokhta_BA2", "Iran_Hajji_Firuz_ChL", "Iran_Ganj_Dareh_N"),
  "Iranian_Plateau" = c("Iran_TepeAbdulHosein_N", "Iran_ShahrISokhta_BA1", "Iran_WesternZagros_N"),
  
  # Central Asian (Islamic period migrations)
  "Central_Asian_Islamic" = c("Uzbekistan_Ksirov_700CE", "Turkmenistan_Gonur_BA_1", "Tajikistan_Sarazm_EN"),
  "Central_Asian_Bronze" = c("Turkmenistan_Parkhai_MBA", "Kazakhstan_Begash_MLBA", "Uzbekistan_Bustan_BA"),
  
  # South Asian Steppe (Indo-Aryan migrations)
  "South_Asian_Steppe" = c("Kazakhstan_Andronovo.SG", "Kazakhstan_Alakul_MLBA", "Russia_Sintashta_MLBA"),
  
  # BMAC (Bactria-Margiana) - Central Asian Bronze Age
  "BMAC" = c("Turkmenistan_Gonur_BA_1", "Turkmenistan_Gonur_BA_2", "Uzbekistan_Sapalli_BA"),
  
  # Indus Valley Civilization (when available)
  "IVC" = c("Pakistan_Harappa_2800BP", "Pakistan_Rakhigarhi_4700BP"),
  
  # West Asian/Middle Eastern
  "West_Asian" = c("Turkey_Kumtepe_N", "Armenia_ChL", "Georgia_Kotias"),
  "Levantine" = c("Israel_PPNB", "Israel_Natufian", "Jordan_PPNB"),
  "Mesopotamian" = c("Iraq_Nemrik9_PPN", "Iran_Abdul_Hosein_N"),
  
  # Additional Caucasus
  "Caucasus_Extended" = c("Georgia_Kotias", "Georgia_Satsurblia", "Armenia_MLBA"),
  
  # Scythian/Saka (relevant for Central Asian history)
  "Scythian_Saka" = c("Scythian_RUS_Pazyryk", "Scythian_MDA", "Kazakhstan_Karasuk"),
  
  # === BROADER GEOGRAPHIC COVERAGE ===
  
  # Siberian/North Asian (for unexpected northern admixture)
  "Siberian" = c("Russia_MA1", "Russia_AfontovaGora3", "Russia_Ust_Ishim"),
  "North_Asian" = c("Siberia_N", "Mongolia_N"),
  
  # East Asian (for potential eastern admixture)
  "East_Asian" = c("China_Tianyuan", "China_DevilsCave_N", "Japan_Jomon"),
  
  # African (for potential ancient African admixture)
  "African" = c("Morocco_Iberomaurusian", "Ethiopia_4500BP", "Sudan_Medieval"),
  "Sub_Saharan_African" = c("Kenya_Pastoral_N", "Tanzania_Luxmanda", "Cameroon_SMA"),
  
  # European Neolithic variations
  "European_EN_LBK" = c("LBK_EN", "Germany_EN", "Hungary_EN"),
  "European_EN_Mediterranean" = c("Iberia_EN", "Sardinia_N", "Sicily_EBA"),
  
  # Balkan Neolithic
  "Balkan_Neolithic" = c("Serbia_EN", "Croatia_N", "Bulgaria_EN"),
  "Balkan_Bronze" = c("Romania_EN", "Greece_N", "Crete_Minoan"),
  
  # Additional Steppe variants
  "Steppe_Variants" = c("Russia_Catacomb", "Russia_Poltavka", "Ukraine_Mezmaiskaya"),
  "Later_Steppe" = c("Russia_Srubnaya_Alakul.SG", "Kazakhstan_Karasuk"),
  
  # Medieval/Islamic period
  "Islamic_Medieval" = c("Iran_ShahrISokhta_IA", "Iran_HasanluTepe_IA"),
  
  # Arabian Peninsula (when available)
  "Arabian" = c("Saudi_Arabia_Neolithic", "Yemen_Bronze_Age"),
  
  # Indus periphery
  "Indus_Periphery" = c("Turkmenistan_Gonur_BA_1", "Iran_ShahrISokhta_BA2"),
  
  # Additional Iranian populations
  "Iranian_Extended" = c("Iran_Hasanlu_IA", "Iran_Dinkha_BronzeAge"),
  
  # Turkic populations (when available)
  "Turkic_Medieval" = c("Mongolia_Medieval", "Kazakhstan_Medieval"),
  
  # Additional South Asian
  "South_Asian_Extended" = c("Bangladesh_IronAge", "India_RoopkundA"),
  
  # Southeast Asian (for complete coverage)
  "Southeast_Asian" = c("Malaysia_Neolithic", "Philippines_Neolithic")
)

# Define comprehensive outgroups
outgroups <- c("Mbuti.DG", "Ju_hoan_North.DG", "Oroqen.DG", "Onge.DG", 
               "Papuan.DG", "Karitiana.DG", "Mixe.DG", "She.DG")

# Function to test multiple source combinations
test_qpadm_models <- function(target, source_groups, outgroups, max_sources=4) {
  results <- list()
  
  # Get all available populations
  all_pops <- unique(f2_data$pop)
  
  # Filter source groups to only include available populations
  available_sources <- list()
  for(group_name in names(source_groups)) {
    available <- intersect(source_groups[[group_name]], all_pops)
    if(length(available) > 0) {
      available_sources[[group_name]] <- available[1]  # Take first available
    }
  }
  
  cat("Available source populations:\n")
  print(available_sources)
  
  # Test 2-way, 3-way, and 4-way models
  for(n_sources in 2:min(max_sources, length(available_sources))) {
    cat(paste("\n=== Testing", n_sources, "source models ===\n"))
    
    # Generate all combinations
    source_combinations <- combn(names(available_sources), n_sources, simplify=FALSE)
    
    for(i in 1:min(10, length(source_combinations))) {  # Limit to first 10 combinations
      combo <- source_combinations[[i]]
      sources <- unlist(available_sources[combo])
      
      # Check if all populations exist
      missing <- setdiff(c(target, sources, outgroups), all_pops)
      if(length(missing) > 0) next
      
      tryCatch({
        result <- qpadm(f2_data, 
                       target = target,
                       left = sources,
                       right = outgroups,
                       allsnps = TRUE)
        
        if(result$pvalue > 0.01) {  # Only keep reasonable fits
          model_name <- paste(combo, collapse="_")
          results[[model_name]] <- list(
            sources = sources,
            pvalue = result$pvalue,
            weights = result$weights,
            model = combo
          )
          
          cat("Model:", model_name, "- P-value:", round(result$pvalue, 4), "\n")
          cat("Proportions:", paste(round(result$weights, 3), collapse=", "), "\n\n")
        }
      }, error = function(e) {
        cat("Error with model:", paste(combo, collapse="_"), "\n")
      })
    }
  }
  
  return(results)
}

# Run comprehensive testing
cat("Running comprehensive ancient ancestry analysis...\n")
results <- test_qpadm_models(your_sample, ancient_sources, outgroups)

# Sort results by p-value (best fits first)
if(length(results) > 0) {
  results_sorted <- results[order(sapply(results, function(x) x$pvalue), decreasing=TRUE)]
  
  cat("\n=== TOP 5 BEST-FITTING MODELS ===\n")
  for(i in 1:min(5, length(results_sorted))) {
    model <- results_sorted[[i]]
    cat("Model", i, ":", names(results_sorted)[i], "\n")
    cat("P-value:", round(model$pvalue, 6), "\n")
    cat("Sources:", paste(model$sources, collapse=", "), "\n")
    cat("Proportions:", paste(round(model$weights, 3), collapse=", "), "\n\n")
  }
  
  # Create visualization for best model
  best_model <- results_sorted[[1]]
  best_weights <- data.frame(
    Population = best_model$sources,
    Proportion = as.numeric(best_model$weights)
  )
  
  # Create detailed ancestry plot
  library(ggplot2)
  p <- ggplot(best_weights, aes(x=reorder(Population, Proportion), y=Proportion, fill=Population)) +
    geom_bar(stat="identity") +
    coord_flip() +
    scale_y_continuous(labels=scales::percent_format()) +
    labs(title=paste("Best-Fitting Ancient Ancestry Model"),
         subtitle=paste("P-value:", round(best_model$pvalue, 4)),
         x="Ancient Population", y="Ancestry Proportion") +
    theme_minimal() +
    theme(legend.position="none")
  
  ggsave("best_ancient_ancestry_model.png", p, width=10, height=6, dpi=300)
  
  # Save comprehensive results
  save(results_sorted, best_model, file="comprehensive_ancestry_results.RData")
  
} else {
  cat("No well-fitting models found. You may need to:\n")
  cat("1. Check your sample name in the dataset\n")
  cat("2. Try different source populations\n")
  cat("3. Ensure data merged correctly\n")
}

cat("\nAnalysis complete! Check PNG files for visualizations.\n")
