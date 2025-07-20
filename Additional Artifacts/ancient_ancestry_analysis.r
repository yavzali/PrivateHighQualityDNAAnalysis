# Ancient Ancestry Analysis using ADMIXTOOLS 2
# Replicating IllustrativeDNA/Ancestral Brew analysis

library(admixtools)
library(tidyverse)

# Load your merged dataset
data_path <- "merged_dataset"  # your PLINK files (without extension)

# Read the data into ADMIXTOOLS format
f2_data <- extract_f2(data_path, 
                      maxmiss = 0.99,  # Allow high missingness for ancient samples
                      auto_only = TRUE)  # Use only autosomes

# Define your sample name (replace with actual name from your dataset)
your_sample <- "IND1"  # This should match what's in your .fam file

# Check available populations
pops <- unique(f2_data$pop)
print("Available populations:")
print(pops[order(pops)])

# Define source populations for different time periods and regions
# These represent major ancestral components from around the world

# Mesolithic/Early Neolithic sources
mesolithic_sources <- c("Russia_MA1", "WHG", "CHG", "EHG", "Anatolia_N")

# Bronze Age sources (more specific)
bronze_age_sources <- c("Yamnaya_RUS_Samara", "Anatolia_N", "WHG", "CHG")

# Iron Age sources (even more specific)
iron_age_sources <- c("Scythian_MDA", "Germanic_IA", "Slavic_IA", "Celtic_IA")

# Ancient Ancestral South Indian (AASI) - Indigenous South Asian component
aasi_sources <- c("Indian_GreatAndaman_100BP.SG", "Onge.DG", "Jarawa.DG")

# Iranian farmer-related populations (crucial for Pakistani ancestry)
iranian_sources <- c("Iran_ShahrISokhta_BA2", "Iran_Hajji_Firuz_ChL", "Iran_Ganj_Dareh_N", 
                    "Iran_TepeAbdulHosein_N", "Iran_ShahrISokhta_BA1")

# Central Asian populations (important for Islamic period migrations)
central_asian_sources <- c("Uzbekistan_Ksirov_700CE", "Turkmenistan_Gonur_BA_1", 
                          "Turkmenistan_Parkhai_MBA", "Kazakhstan_Begash_MLBA",
                          "Tajikistan_Sarazm_EN", "Uzbekistan_Bustan_BA")

# Steppe populations that migrated to South Asia
steppe_sources <- c("Kazakhstan_Andronovo.SG", "Kazakhstan_Alakul_MLBA", 
                   "Russia_Sintashta_MLBA", "Kazakhstan_Karasuk")

# BMAC (Bactria-Margiana Archaeological Complex) - Central Asian Bronze Age
bmac_sources <- c("Turkmenistan_Gonur_BA_1", "Turkmenistan_Gonur_BA_2", 
                 "Uzbekistan_Sapalli_BA")

# Indus Valley Civilization related (when available)
ivc_sources <- c("Pakistan_Harappa_2800BP", "Pakistan_Rakhigarhi_4700BP") # May not be in all datasets

# Islamic period and medieval sources (Iran/Central Asia)
islamic_period_sources <- c("Iran_ShahrISokhta_IA", "Iran_HasanluTepe_IA", 
                           "Scythian_RUS_Pazyryk", "Scythian_MDA")

# Combined South Asian specific model
south_asian_sources <- c("Iran_ShahrISokhta_BA2", "Kazakhstan_Andronovo.SG", "Indian_GreatAndaman_100BP.SG")

# Pakistani-specific 4-way model (based on Narasimhan et al. 2019)
pakistani_4way_sources <- c("Iran_ShahrISokhta_BA2", "Kazakhstan_Andronovo.SG", 
                           "Indian_GreatAndaman_100BP.SG", "Turkmenistan_Gonur_BA_1")

# West Asian/Middle Eastern sources (relevant for Islamic migrations)
west_asian_sources <- c("Turkey_Kumtepe_N", "Armenia_ChL", "Georgia_Kotias", 
                       "Lebanon_MBA", "Jordan_PPNB")

# Levantine sources (early Neolithic farmers)
levantine_sources <- c("Israel_PPNB", "Israel_Natufian", "Jordan_PPNB", "Turkey_Epipaleolithic")

# Mesopotamian sources 
mesopotamian_sources <- c("Iraq_Nemrik9_PPN", "Iran_Abdul_Hosein_N", "Iran_WesternZagros_N")

# Caucasus sources (important transition zone)
caucasus_sources <- c("Georgia_Kotias", "Georgia_Satsurblia", "Armenia_ChL", "Armenia_MLBA")

# Siberian/North Asian sources (for potential northern admixture)
siberian_sources <- c("Russia_MA1", "Russia_AfontovaGora3", "Russia_Ust_Ishim", "Siberia_N")

# East Asian sources (for potential eastern admixture)
east_asian_sources <- c("China_Tianyuan", "Mongolia_N", "China_DevilsCave_N", "Japan_Jomon")

# African sources (for potential ancient African admixture)
african_sources <- c("Morocco_Iberomaurusian", "Ethiopia_4500BP", "Sudan_Medieval", "Kenya_Pastoral_N")

# European Neolithic/Bronze Age (comprehensive)
european_neolithic_sources <- c("LBK_EN", "Iberia_EN", "Sardinia_N", "Hungary_EN", "Germany_EN")
european_bronze_sources <- c("Bell_Beaker_Germany", "Corded_Ware_Germany", "Unetice", "Nordic_BA")

# Mediterranean sources
mediterranean_sources <- c("Sardinia_N", "Sicily_EBA", "Iberia_BA", "Cyprus_BA", "Crete_Minoan")

# Balkan sources
balkan_sources <- c("Serbia_EN", "Croatia_N", "Bulgaria_EN", "Romania_EN", "Greece_N")

# Additional Steppe variants
additional_steppe_sources <- c("Russia_Catacomb", "Russia_Poltavka", "Ukraine_Mezmaiskaya", 
                              "Russia_Srubnaya_Alakul.SG")

# Define outgroups (populations for f4-statistics)
outgroups <- c("Mbuti.DG", "Oroqen.DG", "Papuan.DG", "She.DG", 
               "Karitiana.DG", "Druze.DG", "Palestinian.DG")

# Function to run qpAdm analysis
run_ancient_ancestry <- function(target, sources, outgroups, label) {
  cat("\n=== Running", label, "Analysis ===\n")
  
  # Check if all populations exist
  missing_pops <- setdiff(c(target, sources, outgroups), pops)
  if(length(missing_pops) > 0) {
    cat("Missing populations:", paste(missing_pops, collapse=", "), "\n")
    return(NULL)
  }
  
  # Run qpAdm
  result <- qpadm(f2_data, 
                  target = target,
                  left = sources,
                  right = outgroups,
                  allsnps = TRUE)
  
  # Print results
  cat("P-value:", result$pvalue, "\n")
  cat("Ancestry proportions:\n")
  print(result$weights)
  
  return(result)
}

# Run comprehensive ancestry analyses covering all possible backgrounds
cat("Starting comprehensive ancestry analysis for sample:", your_sample, "\n")

# Pakistani/South Asian specific analyses
pakistani_result <- run_ancient_ancestry(your_sample, south_asian_sources, outgroups, "Pakistani 3-Way")
pakistani_4way_result <- run_ancient_ancestry(your_sample, pakistani_4way_sources, outgroups, "Pakistani 4-Way with BMAC")
iranian_result <- run_ancient_ancestry(your_sample, iranian_sources[1:3], outgroups, "Iranian Plateau")
central_asian_result <- run_ancient_ancestry(your_sample, central_asian_sources[1:3], outgroups, "Central Asian Islamic")

# European analyses
bronze_result <- run_ancient_ancestry(your_sample, bronze_age_sources, outgroups, "European Bronze Age")
meso_result <- run_ancient_ancestry(your_sample, mesolithic_sources, outgroups, "European Mesolithic")
three_way_result <- run_ancient_ancestry(your_sample, c("Yamnaya_RUS_Samara", "Anatolia_N", "WHG"), outgroups, "3-Way European Bronze Age")

# West Asian/Middle Eastern analyses
west_asian_result <- run_ancient_ancestry(your_sample, west_asian_sources[1:3], outgroups, "West Asian")
levantine_result <- run_ancient_ancestry(your_sample, levantine_sources[1:3], outgroups, "Levantine")
mesopotamian_result <- run_ancient_ancestry(your_sample, mesopotamian_sources[1:3], outgroups, "Mesopotamian")
caucasus_result <- run_ancient_ancestry(your_sample, caucasus_sources[1:3], outgroups, "Caucasus")

# Steppe analyses (different variants)
steppe_result <- run_ancient_ancestry(your_sample, steppe_sources[1:3], outgroups, "Steppe Pastoralists")
additional_steppe_result <- run_ancient_ancestry(your_sample, additional_steppe_sources[1:3], outgroups, "Additional Steppe")

# Mediterranean analyses
mediterranean_result <- run_ancient_ancestry(your_sample, mediterranean_sources[1:3], outgroups, "Mediterranean")
balkan_result <- run_ancient_ancestry(your_sample, balkan_sources[1:3], outgroups, "Balkan")

# Broader geographic analyses (in case of unexpected ancestry)
siberian_result <- run_ancient_ancestry(your_sample, siberian_sources[1:3], outgroups, "Siberian/North Asian")
east_asian_result <- run_ancient_ancestry(your_sample, east_asian_sources[1:3], outgroups, "East Asian")
african_result <- run_ancient_ancestry(your_sample, african_sources[1:3], outgroups, "African")

# Function to create ancestry pie chart
create_ancestry_plot <- function(result, title) {
  if(is.null(result)) return(NULL)
  
  weights_df <- data.frame(
    Population = names(result$weights),
    Proportion = as.numeric(result$weights),
    stringsAsFactors = FALSE
  )
  
  ggplot(weights_df, aes(x="", y=Proportion, fill=Population)) +
    geom_bar(stat="identity", width=1) +
    coord_polar("y", start=0) +
    ggtitle(paste(title, "Ancestry Composition")) +
    theme_minimal() +
    theme(axis.text.x = element_blank()) +
    scale_fill_brewer(type="qual", palette="Set3")
}

# Create plots for all successful analyses
plot_results <- list(
  "pakistani_ancestry.png" = list(pakistani_result, "Pakistani 3-Way"),
  "pakistani_4way_ancestry.png" = list(pakistani_4way_result, "Pakistani 4-Way with BMAC"),
  "iranian_ancestry.png" = list(iranian_result, "Iranian Plateau"),
  "central_asian_ancestry.png" = list(central_asian_result, "Central Asian Islamic"),
  "bronze_age_ancestry.png" = list(bronze_result, "European Bronze Age"),
  "mesolithic_ancestry.png" = list(meso_result, "European Mesolithic"),
  "three_way_ancestry.png" = list(three_way_result, "3-Way European Bronze Age"),
  "west_asian_ancestry.png" = list(west_asian_result, "West Asian"),
  "levantine_ancestry.png" = list(levantine_result, "Levantine"),
  "mesopotamian_ancestry.png" = list(mesopotamian_result, "Mesopotamian"),
  "caucasus_ancestry.png" = list(caucasus_result, "Caucasus"),
  "steppe_ancestry.png" = list(steppe_result, "Steppe Pastoralists"),
  "mediterranean_ancestry.png" = list(mediterranean_result, "Mediterranean"),
  "balkan_ancestry.png" = list(balkan_result, "Balkan"),
  "siberian_ancestry.png" = list(siberian_result, "Siberian/North Asian"),
  "east_asian_ancestry.png" = list(east_asian_result, "East Asian"),
  "african_ancestry.png" = list(african_result, "African")
)

# Generate plots for successful results
for(filename in names(plot_results)) {
  result <- plot_results[[filename]][[1]]
  title <- plot_results[[filename]][[2]]
  
  if(!is.null(result)) {
    p <- create_ancestry_plot(result, title)
    ggsave(filename, p, width=8, height=6)
    cat("Created plot:", filename, "\n")
  }
}

# Advanced: Comprehensive time series analysis across all regions and periods
time_periods <- list(
  # South Asian & Pakistani models
  "Pakistani_3Way" = south_asian_sources,
  "Pakistani_4Way_BMAC" = pakistani_4way_sources,
  "Iranian_Plateau" = iranian_sources[1:3],
  "Central_Asian_Islamic" = central_asian_sources[1:3],
  
  # European models
  "European_Mesolithic" = mesolithic_sources,
  "European_Bronze_Age" = bronze_age_sources,
  "European_3Way" = c("Yamnaya_RUS_Samara", "Anatolia_N", "WHG"),
  "European_Neolithic" = european_neolithic_sources[1:3],
  "European_Bronze_Detailed" = european_bronze_sources[1:3],
  
  # West Asian & Middle Eastern models
  "West_Asian" = west_asian_sources[1:3],
  "Levantine" = levantine_sources[1:3],
  "Mesopotamian" = mesopotamian_sources[1:3],
  "Caucasus" = caucasus_sources[1:3],
  
  # Steppe models
  "Steppe_Pastoralists" = steppe_sources[1:3],
  "Additional_Steppe" = additional_steppe_sources[1:3],
  
  # Mediterranean & Balkan models
  "Mediterranean" = mediterranean_sources[1:3],
  "Balkan" = balkan_sources[1:3],
  
  # Broader geographic models (for unexpected ancestry)
  "Siberian_North_Asian" = siberian_sources[1:3],
  "East_Asian" = east_asian_sources[1:3],
  "African" = african_sources[1:3],
  
  # BMAC specific
  "BMAC_Central_Asian" = bmac_sources[1:3],
  
  # Islamic period specific
  "Islamic_Period" = islamic_period_sources[1:3]
)

results_summary <- data.frame()

for(period in names(time_periods)) {
  sources <- time_periods[[period]]
  result <- run_ancient_ancestry(your_sample, sources, outgroups, period)
  
  if(!is.null(result) && result$pvalue > 0.05) {  # Only keep good fits
    summary_row <- data.frame(
      Period = period,
      P_value = result$pvalue,
      Sources = paste(sources, collapse=", "),
      stringsAsFactors = FALSE
    )
    results_summary <- rbind(results_summary, summary_row)
  }
}

cat("\n=== SUMMARY OF SUCCESSFUL MODELS ===\n")
print(results_summary)

# Save comprehensive results including all ancestry analyses
save(pakistani_result, pakistani_4way_result, iranian_result, central_asian_result,
     bronze_result, meso_result, three_way_result, west_asian_result, 
     levantine_result, mesopotamian_result, caucasus_result, steppe_result,
     additional_steppe_result, mediterranean_result, balkan_result,
     siberian_result, east_asian_result, african_result, results_summary, 
     file="comprehensive_ancestry_results.RData")

cat("\nAnalysis complete! Check the PNG files and RData file for results.\n")
cat("Models with p-value > 0.05 are considered good fits.\n")
