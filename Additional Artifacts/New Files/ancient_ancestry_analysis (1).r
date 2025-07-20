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

# Define source populations for Pakistani/Shia Muslim ancestry analysis
# These represent major ancestral components relevant to South Asian populations

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

# Run analyses for different time periods
cat("Starting ancient ancestry analysis for sample:", your_sample, "\n")

# Bronze Age analysis (most common for European ancestry)
bronze_result <- run_ancient_ancestry(your_sample, bronze_age_sources, outgroups, "Bronze Age")

# Mesolithic analysis (deeper time depth)
meso_result <- run_ancient_ancestry(your_sample, mesolithic_sources, outgroups, "Mesolithic")

# Try 3-way model (most common successful model)
three_way_sources <- c("Yamnaya_RUS_Samara", "Anatolia_N", "WHG")
three_way_result <- run_ancient_ancestry(your_sample, three_way_sources, outgroups, "3-Way Bronze Age")

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

# Create plots
if(!is.null(three_way_result)) {
  p1 <- create_ancestry_plot(three_way_result, "3-Way Bronze Age")
  ggsave("bronze_age_ancestry.png", p1, width=8, height=6)
}

if(!is.null(bronze_result)) {
  p2 <- create_ancestry_plot(bronze_result, "Bronze Age")
  ggsave("detailed_bronze_ancestry.png", p2, width=8, height=6)
}

# Advanced: Time series analysis across periods
# Try to model your ancestry across different time periods
time_periods <- list(
  "Mesolithic" = mesolithic_sources,
  "Bronze_Age" = bronze_age_sources,
  "Three_Way" = three_way_sources
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

# Save detailed results
save(bronze_result, meso_result, three_way_result, results_summary, 
     file="ancient_ancestry_results.RData")

cat("\nAnalysis complete! Check the PNG files and RData file for results.\n")
cat("Models with p-value > 0.05 are considered good fits.\n")
