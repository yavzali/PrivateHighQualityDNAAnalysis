#!/usr/bin/env Rscript

# ===============================================
# 🔍 CHECK REDDIT COMMUNITY POPULATIONS AVAILABILITY
# ===============================================
# This script checks if the Reddit community's curated populations 
# actually exist in our Google Drive ancient DNA datasets

library(googledrive)
library(jsonlite)

# Source the main system functions
source("production_ancestry_system.r")

check_reddit_populations_availability <- function() {
  cat("🔍 CHECKING REDDIT COMMUNITY POPULATIONS AVAILABILITY\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  # Get Reddit community populations
  reddit_pops <- get_reddit_validated_populations()
  
  cat("🎯 Reddit Community Populations to Check:\n")
  cat("   Primary Sources:", length(reddit_pops$primary_sources), "\n")
  cat("   BMAC Samples:", length(reddit_pops$bmac_samples), "\n")
  cat("   Outgroups:", length(reddit_pops$outgroups), "\n")
  cat("   Total:", length(reddit_pops$all_populations), "\n\n")
  
  # Get available populations from Google Drive datasets
  cat("📊 Accessing Google Drive datasets...\n")
  
  tryCatch({
    # Authenticate and get dataset access
    authenticate_gdrive()
    folder_id <- find_ancient_datasets_folder()
    inventory <- get_dataset_inventory(folder_id)
    
    # Get populations from both datasets
    all_available_populations <- c()
    
    # 1240k populations
    if (nrow(inventory$eigenstrat) > 0) {
      cat("📊 Checking 1240k dataset...\n")
      ind_1240k <- inventory$eigenstrat[inventory$eigenstrat$name == "v62.0_1240k_public.ind", ]
      if (nrow(ind_1240k) > 0) {
        temp_ind <- tempfile()
        drive_download(as_id(ind_1240k$id[1]), path = temp_ind, overwrite = TRUE)
        ind_data_1240k <- read.table(temp_ind, stringsAsFactors = FALSE)
        pops_1240k <- unique(ind_data_1240k$V3)
        all_available_populations <- c(all_available_populations, pops_1240k)
        unlink(temp_ind)
        cat("   ✅ 1240k populations found:", length(pops_1240k), "\n")
      }
    }
    
    # HO populations
    if (nrow(inventory$eigenstrat) > 0) {
      cat("📊 Checking HO dataset...\n")
      ind_ho <- inventory$eigenstrat[inventory$eigenstrat$name == "v62.0_HO_public.ind", ]
      if (nrow(ind_ho) > 0) {
        temp_ind <- tempfile()
        drive_download(as_id(ind_ho$id[1]), path = temp_ind, overwrite = TRUE)
        ind_data_ho <- read.table(temp_ind, stringsAsFactors = FALSE)
        pops_ho <- unique(ind_data_ho$V3)
        all_available_populations <- c(all_available_populations, pops_ho)
        unlink(temp_ind)
        cat("   ✅ HO populations found:", length(pops_ho), "\n")
      }
    }
    
    all_available_populations <- unique(all_available_populations)
    cat("📊 Total unique populations available:", length(all_available_populations), "\n\n")
    
    # Check Reddit populations against available populations
    cat("🔍 POPULATION AVAILABILITY CHECK\n")
    cat(paste(rep("=", 50), collapse = ""), "\n")
    
    # Check each category
    check_population_category(reddit_pops$primary_sources, all_available_populations, "PRIMARY SOURCES")
    check_population_category(reddit_pops$bmac_samples, all_available_populations, "BMAC SAMPLES")  
    check_population_category(reddit_pops$outgroups, all_available_populations, "OUTGROUPS")
    
    # Overall summary
    all_reddit_pops <- reddit_pops$all_populations
    exact_matches <- sum(all_reddit_pops %in% all_available_populations)
    total_reddit_pops <- length(all_reddit_pops)
    
    cat("\n📊 OVERALL SUMMARY\n")
    cat(paste(rep("=", 30), collapse = ""), "\n")
    cat("Reddit populations requested:", total_reddit_pops, "\n")
    cat("Exact matches found:", exact_matches, "\n")
    cat("Match percentage:", round(exact_matches/total_reddit_pops*100, 1), "%\n")
    
    if (exact_matches < total_reddit_pops * 0.5) {
      cat("⚠️  WARNING: Less than 50% of Reddit populations found\n")
      cat("📋 This may indicate population naming differences\n")
      cat("🔍 Fuzzy matching recommended\n")
    } else if (exact_matches < total_reddit_pops * 0.8) {
      cat("⚠️  CAUTION: Less than 80% of Reddit populations found\n") 
      cat("📋 Some populations may have different names\n")
    } else {
      cat("✅ GOOD: Most Reddit populations are available\n")
    }
    
    # Save results for further analysis
    results <- list(
      reddit_populations = reddit_pops,
      available_populations = all_available_populations,
      exact_matches = all_reddit_pops[all_reddit_pops %in% all_available_populations],
      missing_populations = all_reddit_pops[!all_reddit_pops %in% all_available_populations],
      match_percentage = exact_matches/total_reddit_pops*100
    )
    
    # Save to JSON for analysis
    write_json(results, "reddit_population_check_results.json", pretty = TRUE)
    cat("\n📄 Results saved to: reddit_population_check_results.json\n")
    
    return(results)
    
  }, error = function(e) {
    cat("❌ ERROR checking populations:", e$message, "\n")
    return(NULL)
  })
}

check_population_category <- function(reddit_pops, available_pops, category_name) {
  cat("\n🔍", category_name, "\n")
  
  exact_matches <- sum(reddit_pops %in% available_pops)
  total_pops <- length(reddit_pops)
  
  cat("   Requested:", total_pops, "\n")
  cat("   Found:", exact_matches, "\n")
  cat("   Match rate:", round(exact_matches/total_pops*100, 1), "%\n")
  
  # Show missing populations
  missing_pops <- reddit_pops[!reddit_pops %in% available_pops]
  if (length(missing_pops) > 0) {
    cat("   ❌ Missing:", paste(missing_pops, collapse = ", "), "\n")
  }
  
  # Show found populations
  found_pops <- reddit_pops[reddit_pops %in% available_pops]
  if (length(found_pops) > 0) {
    cat("   ✅ Found:", paste(found_pops, collapse = ", "), "\n")
  }
}

# Run the check
if (!interactive()) {
  results <- check_reddit_populations_availability()
} 