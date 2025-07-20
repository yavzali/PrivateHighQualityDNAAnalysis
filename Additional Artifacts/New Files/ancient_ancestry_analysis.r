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

# Define source populations for different time periods
# These represent major ancestral components

# Mesolithic/Early Neolithic sources
mesolithic_sources <- c("Russia_MA1", "WHG", "CHG", "EHG", "Anatolia_N")

# Bronze Age sources (more specific)
bronze_age_sources <- c("Yamnaya_RUS_Samara", "Anatolia_N", "WHG", "CHG")

# Iron Age sources (even more specific)
iron_age_sources <- c("Scythian_MDA", "Germanic_IA", "Slavic_IA", "Celtic_IA")

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
