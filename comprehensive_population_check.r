#!/usr/bin/env Rscript

# ===============================================
# 🔍 COMPREHENSIVE POPULATION AVAILABILITY CHECK
# ===============================================
# Checks Reddit community populations + user's additional high-priority populations

library(googledrive)
library(jsonlite)

# Source required functions
source("gdrive_stream_engine.r")

check_comprehensive_populations <- function() {
  cat("🔍 COMPREHENSIVE POPULATION AVAILABILITY CHECK\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  # Define all population lists
  populations_to_check <- get_all_population_lists()
  
  cat("🎯 POPULATIONS TO CHECK:\n")
  cat("   Reddit Community:", length(populations_to_check$reddit_community), "\n")
  cat("   High Priority Iranian:", length(populations_to_check$high_priority_iranian), "\n")
  cat("   Medium Priority Afghan/Central Asian:", length(populations_to_check$medium_priority_afghan), "\n")
  cat("   Medium Priority North Indian:", length(populations_to_check$medium_priority_north_indian), "\n")
  cat("   Low Priority Bengali:", length(populations_to_check$low_priority_bengali), "\n")
  cat("   Global Coverage:", length(populations_to_check$global_coverage), "\n")
  
  total_populations <- length(unlist(populations_to_check))
  cat("   TOTAL POPULATIONS:", total_populations, "\n\n")
  
  # Get available populations from datasets
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
        
        # Show sample of 1240k populations
        cat("   📋 Sample 1240k populations:\n")
        sample_pops <- head(sort(pops_1240k), 10)
        for(i in 1:length(sample_pops)) {
          cat(sprintf("      %s\n", sample_pops[i]))
        }
        cat("      ... and", length(pops_1240k)-10, "more\n")
      }
    }
    
    # HO populations
    if (nrow(inventory$eigenstrat) > 0) {
      cat("\n📊 Checking HO dataset...\n")
      ind_ho <- inventory$eigenstrat[inventory$eigenstrat$name == "v62.0_HO_public.ind", ]
      if (nrow(ind_ho) > 0) {
        temp_ind <- tempfile()
        drive_download(as_id(ind_ho$id[1]), path = temp_ind, overwrite = TRUE)
        ind_data_ho <- read.table(temp_ind, stringsAsFactors = FALSE)
        pops_ho <- unique(ind_data_ho$V3)
        all_available_populations <- c(all_available_populations, pops_ho)
        unlink(temp_ind)
        cat("   ✅ HO populations found:", length(pops_ho), "\n")
        
        # Show sample of HO populations
        cat("   📋 Sample HO populations:\n")
        sample_pops <- head(sort(pops_ho), 10)
        for(i in 1:length(sample_pops)) {
          cat(sprintf("      %s\n", sample_pops[i]))
        }
        cat("      ... and", length(pops_ho)-10, "more\n")
      }
    }
    
    all_available_populations <- unique(all_available_populations)
    cat("\n📊 TOTAL UNIQUE POPULATIONS AVAILABLE:", length(all_available_populations), "\n\n")
    
    # Check each category
    cat("🔍 DETAILED POPULATION AVAILABILITY CHECK\n")
    cat(paste(rep("=", 50), collapse = ""), "\n")
    
    results <- list()
    
    # Check Reddit community populations
    results$reddit_community <- check_population_category(
      populations_to_check$reddit_community, 
      all_available_populations, 
      "REDDIT COMMUNITY POPULATIONS"
    )
    
    # Check high priority Iranian populations
    results$high_priority_iranian <- check_population_category(
      populations_to_check$high_priority_iranian, 
      all_available_populations, 
      "HIGH PRIORITY IRANIAN (Sadaat-e-Bara)"
    )
    
    # Check medium priority Afghan/Central Asian
    results$medium_priority_afghan <- check_population_category(
      populations_to_check$medium_priority_afghan, 
      all_available_populations, 
      "MEDIUM PRIORITY AFGHAN/CENTRAL ASIAN"
    )
    
    # Check medium priority North Indian
    results$medium_priority_north_indian <- check_population_category(
      populations_to_check$medium_priority_north_indian, 
      all_available_populations, 
      "MEDIUM PRIORITY NORTH INDIAN (UP Heritage)"
    )
    
    # Check low priority Bengali
    results$low_priority_bengali <- check_population_category(
      populations_to_check$low_priority_bengali, 
      all_available_populations, 
      "LOW PRIORITY BENGALI"
    )
    
    # Check global coverage
    results$global_coverage <- check_population_category(
      populations_to_check$global_coverage, 
      all_available_populations, 
      "GLOBAL COVERAGE (Unexpected Ancestry)"
    )
    
    # Overall summary
    cat("\n📊 COMPREHENSIVE SUMMARY\n")
    cat(paste(rep("=", 40), collapse = ""), "\n")
    
    total_requested <- 0
    total_found <- 0
    
    for(category in names(results)) {
      cat(sprintf("%-30s: %2d/%2d (%3.0f%%)\n", 
                  toupper(gsub("_", " ", category)),
                  results[[category]]$found,
                  results[[category]]$total,
                  results[[category]]$percentage))
      total_requested <- total_requested + results[[category]]$total
      total_found <- total_found + results[[category]]$found
    }
    
    cat(sprintf("\n%-30s: %2d/%2d (%3.0f%%)\n", 
                "OVERALL", total_found, total_requested, 
                round(total_found/total_requested*100, 1)))
    
    if (total_found/total_requested < 0.3) {
      cat("\n❌ CRITICAL: Less than 30% of populations found\n")
      cat("📋 Major population naming differences likely\n")
      cat("🔍 Need alternative population names or fuzzy matching\n")
    } else if (total_found/total_requested < 0.6) {
      cat("\n⚠️  WARNING: Less than 60% of populations found\n")
      cat("📋 Significant population naming differences\n")
      cat("🔍 Fuzzy matching strongly recommended\n")
    } else if (total_found/total_requested < 0.8) {
      cat("\n⚠️  CAUTION: Less than 80% of populations found\n")
      cat("📋 Some population naming differences\n")
      cat("🔍 Fuzzy matching recommended\n")
    } else {
      cat("\n✅ EXCELLENT: Most populations are available\n")
      cat("📋 Good compatibility with requested populations\n")
    }
    
    # Save comprehensive results
    comprehensive_results <- list(
      requested_populations = populations_to_check,
      available_populations = all_available_populations,
      category_results = results,
      summary = list(
        total_requested = total_requested,
        total_found = total_found,
        overall_percentage = round(total_found/total_requested*100, 1)
      )
    )
    
    # Save to JSON
    write_json(comprehensive_results, "comprehensive_population_check.json", pretty = TRUE)
    cat("\n📄 Comprehensive results saved to: comprehensive_population_check.json\n")
    
    return(comprehensive_results)
    
  }, error = function(e) {
    cat("❌ ERROR checking populations:", e$message, "\n")
    return(NULL)
  })
}

get_all_population_lists <- function() {
  # Reddit community populations (from previous implementation)
  reddit_community <- c(
    "SIS_BA2", "Turkmenistan_Gonur_BA_2", "Turkmenistan_Gonur_BA_1",
    "Russia_Srubnaya", "Russia_Andronovo.SG", "Alakul",
    "Kurumba.DG", "Irula", "Paniya", "Pullayar",
    "Iran_C_SehGabi", "I10409", "I2123", "I11041",
    "Mbuti.DG", "Russia_Tyumen", "Russia_Karelia", "Russia_Sidelkino",
    "Russia_MA1", "Russia_AG3", "Turkey_Marmara_Barcin", "Jordan_PPNB",
    "Onge.DG", "ONG.SG", "Papuan.DG", "Georgia_Kotias", "Georgia_Satsurblia",
    "Xingyi_EN", "Iran_TepeAbdulHosein_N", "Morocco_Iberomaurusian", 
    "Mongolia_North_N", "Serbia_Irongates_Mesolithic"
  )
  
  # High priority Iranian (Persian/Iranian for Sadaat-e-Bara)
  high_priority_iranian <- c(
    "Iran_Hasanlu_IA",
    "Iran_Shahr_i_Sokhta_BA2", 
    "Iran_Shahr_i_Sokhta_BA3",
    "Iran_Tepe_Hissar_C",
    "Tajikistan_C_Sarazm"
  )
  
  # Medium priority Afghan/Central Asian
  medium_priority_afghan <- c(
    "Afghanistan_BA",
    "Uzbekistan_Bustan_BA", 
    "Tajikistan_Ksirov_Kushan"
  )
  
  # Medium priority North Indian UP Heritage
  medium_priority_north_indian <- c(
    "India_Harappa_4600BP",
    "Pakistan_Loebanr_IA",
    "India_Rakhigarhi_BA", 
    "India_Roopkund_A"
  )
  
  # Low priority Bengali
  low_priority_bengali <- c(
    "Bangladesh_IA"
  )
  
  # Global coverage for unexpected ancestry
  global_coverage <- c(
    "Morocco_Taforalt",
    "Ethiopia_4500BP",
    "Germany_LBK.EN", 
    "China_Tianyuan",
    "Romania_Oase"
  )
  
  return(list(
    reddit_community = reddit_community,
    high_priority_iranian = high_priority_iranian,
    medium_priority_afghan = medium_priority_afghan,
    medium_priority_north_indian = medium_priority_north_indian,
    low_priority_bengali = low_priority_bengali,
    global_coverage = global_coverage
  ))
}

check_population_category <- function(requested_pops, available_pops, category_name) {
  cat("\n🔍", category_name, "\n")
  cat(paste(rep("-", nchar(category_name) + 4), collapse = ""), "\n")
  
  exact_matches <- sum(requested_pops %in% available_pops)
  total_pops <- length(requested_pops)
  percentage <- round(exact_matches/total_pops*100, 1)
  
  cat("   Requested:", total_pops, "\n")
  cat("   Found:", exact_matches, "\n")
  cat("   Match rate:", percentage, "%\n")
  
  # Show missing populations
  missing_pops <- requested_pops[!requested_pops %in% available_pops]
  if (length(missing_pops) > 0) {
    cat("   ❌ MISSING:\n")
    for(pop in missing_pops) {
      cat(sprintf("      - %s\n", pop))
    }
  }
  
  # Show found populations
  found_pops <- requested_pops[requested_pops %in% available_pops]
  if (length(found_pops) > 0) {
    cat("   ✅ FOUND:\n")
    for(pop in found_pops) {
      cat(sprintf("      + %s\n", pop))
    }
  }
  
  return(list(
    total = total_pops,
    found = exact_matches,
    missing = missing_pops,
    available = found_pops,
    percentage = percentage
  ))
}

# Run the comprehensive check
if (!interactive()) {
  results <- check_comprehensive_populations()
} 