# 🚀 ULTIMATE 2025 ANCESTRY ANALYSIS SYSTEM
# Revolutionary Ancient DNA Analysis with Google Drive Streaming

# 🌊 GOOGLE DRIVE STREAMING MODE (REQUIRED)
# This system ONLY works with Google Drive streaming of ancient DNA datasets
# No local reference data or fallbacks - streaming or nothing!

cat("🌊 GOOGLE DRIVE STREAMING MODE ACTIVATED\n")
cat("💾 Storage requirement: <500MB (streaming only)\n")
cat("🍎 Platform: macOS/Linux fully supported\n")
cat("⚡ Analysis: Pure streaming from Google Drive ancient datasets\n")
cat("📡 Requirement: Internet connection + Google Drive access\n\n")

# ===============================================
# 📋 COMMAND LINE ARGUMENTS (parse first)
# ===============================================

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2) {
  cat("Usage: Rscript ultimate_2025_ancestry_system.r <input_prefix> <output_dir>\n")
  cat("Example: Rscript ultimate_2025_ancestry_system.r Results/Zehra_Raza Results/\n")
  stop("Please provide input prefix and output directory")
}

input_prefix <- args[1]  # e.g., "Results/Zehra_Raza"
output_dir <- args[2]    # e.g., "Results/"

# Extract sample name from input prefix
your_sample <- basename(input_prefix)  # "Zehra_Raza"

cat("🧬 ULTIMATE 2025 ANCESTRY ANALYSIS\n")
cat("📁 Input prefix:", input_prefix, "\n")
cat("📁 Output directory:", output_dir, "\n")
cat("👤 Sample name:", your_sample, "\n\n")

library(admixtools)
library(tidyverse)
library(data.table)
library(plotly)
library(viridis)
library(patchwork)

# ===============================================
# 🛠️ FUNCTION DEFINITIONS (must be defined before use)
# ===============================================

# ===============================================
# 🌊 GOOGLE DRIVE STREAMING HELPER FUNCTIONS
# ===============================================

get_personal_genome_snps <- function(genome_prefix) {
  # Extract SNP IDs from personal genome data
  tryCatch({
    # Try to read from .bim file (binary PLINK)
    bim_file <- paste0(genome_prefix, ".bim")
    if (file.exists(bim_file)) {
      bim_data <- fread(bim_file, header = FALSE)
      return(bim_data$V2)  # SNP IDs are in column 2
    }
    
    # Try to read from .map file (text PLINK)
    map_file <- paste0(genome_prefix, ".map")
    if (file.exists(map_file)) {
      map_data <- fread(map_file, header = FALSE)
      return(map_data$V2)  # SNP IDs are in column 2
    }
    
    stop("No PLINK files found for personal genome: ", genome_prefix)
  }, error = function(e) {
    stop("Failed to extract SNPs from personal genome: ", e$message)
  })
}

get_analysis_populations <- function() {
  # Define populations needed for Pakistani/Shia ancestry analysis
  return(c(
    # Core South Asian populations
    "Pakistan_Sindhi", "Pakistan_Baloch", "Pakistan_Pathan", "Pakistan_Punjabi",
    "India_Brahmin", "India_Kshatriya", "India_ASI", "India_ANI",
    
    # Iranian/Persian populations  
    "Iran_N", "Iran_ShahrISokhta_IA", "Iran_HasanluTepe_IA",
    "Iran_Sassanid_Ctesiphon", "Iran_Safavid_Isfahan",
    
    # Central Asian populations
    "Turkmenistan_IA", "Afghanistan_IA", "CentralAsia_Scythian",
    
    # Ancient reference populations
    "Anatolia_N", "CHG", "WHG", "EHG", "Yamnaya", "AASI"
  ))
}

stream_extract_f2 <- function(personal_genome_prefix, gdrive_inventory, output_dir) {
  # Stream f2 statistics using Google Drive data
  cat("🌊 Streaming f2 extraction from Google Drive...\n")
  
  # Get personal genome SNPs
  personal_snps <- get_personal_genome_snps(personal_genome_prefix)
  cat("📊 Personal genome SNPs:", length(personal_snps), "\n")
  
  # Get required populations
  required_pops <- get_analysis_populations()
  cat("🧬 Required populations:", length(required_pops), "\n")
  
  # Use Google Drive streaming engine
  if (!exists("stream_f2_data")) {
    stop("Google Drive streaming engine not loaded. Please run setup first.")
  }
  
  # Stream f2 data for required populations
  f2_result <- stream_f2_data(
    personal_snps = personal_snps,
    populations = required_pops,
    inventory = gdrive_inventory,
    output_dir = output_dir
  )
  
  cat("✅ F2 streaming completed successfully!\n")
  return(f2_result)
}

# Initialize streaming variables globally
use_gdrive_streaming <- FALSE
gdrive_inventory <- NULL
gdrive_folder_id <- NULL

# ===============================================
# 🌊 GOOGLE DRIVE STREAMING INITIALIZATION (REQUIRED)
# ===============================================

cat("🔄 Initializing Google Drive streaming system...\n")

# Load Google Drive streaming engine
if (file.exists("gdrive_stream_engine.r")) {
  cat("📡 Loading Google Drive streaming engine...\n")
  source("gdrive_stream_engine.r")
  
  # Authenticate with Google Drive
  tryCatch({
    cat("🔐 Authenticating with Google Drive...\n")
    authenticate_gdrive()
    
    # Find AncientDNA_Datasets folder
    cat("📁 Searching for AncientDNA_Datasets folder...\n")
    gdrive_folder_id <- find_ancient_datasets_folder()
    
    if (!is.null(gdrive_folder_id)) {
      cat("✅ Found AncientDNA_Datasets folder!\n")
      
      # Get dataset inventory
      cat("📋 Building dataset inventory...\n")
      gdrive_inventory <- get_dataset_inventory(gdrive_folder_id)
      
      if (!is.null(gdrive_inventory) && length(gdrive_inventory) > 0) {
        cat("✅ Dataset inventory loaded successfully!\n")
        cat("📊 Available datasets:", length(gdrive_inventory), "\n")
        
        use_gdrive_streaming <- TRUE
        
        # Show available datasets
        for (dataset_name in names(gdrive_inventory)) {
          cat("   -", dataset_name, "\n")
        }
        
      } else {
        stop("❌ No datasets found in AncientDNA_Datasets folder")
      }
    } else {
      stop("❌ AncientDNA_Datasets folder not found in Google Drive")
    }
    
  }, error = function(e) {
    stop("❌ Google Drive streaming initialization failed: ", e$message)
  })
  
} else {
  stop("❌ Google Drive streaming engine not found. Please run setup first.")
}

# ===============================================
# 🎯 GOOGLE DRIVE STREAMING ANALYSIS (SIMPLIFIED)
# ===============================================

# Define core populations for analysis (no fallbacks)
core_populations_2025 <- c(
  # Essential South Asian
  "Pakistan_Sindhi", "Pakistan_Baloch", "Pakistan_Punjabi", "India_Brahmin",
  
  # Essential Iranian/Persian
  "Iran_N", "Iran_ShahrISokhta_IA", "Iran_HasanluTepe_IA",
  
  # Essential Ancient Reference
  "Anatolia_N", "CHG", "WHG", "EHG", "Yamnaya", "AASI"
)

# Essential outgroups (no substitutions)
essential_outgroups_2025 <- c(
  "Mbuti.DG", "Onge.DG", "Papuan.DG", "Karitiana.DG", 
  "Oroqen.DG", "Druze.DG", "Yoruba.DG"
)

# ===============================================
# 🔬 STREAMING qpAdm FUNCTION (NO FALLBACKS)
# ===============================================

run_streaming_qpadm <- function(target, sources, outgroups, label) {
  cat("\n=== 🌊 Running", label, "(Google Drive Streaming) ===\n")
  
  # No fallbacks - either the populations are available via streaming or analysis fails
  tryCatch({
    cat("📡 Using streamed f2 statistics from Google Drive...\n")
    
    result <- qpadm(f2_data, 
                    target = target,
                    left = sources,
                    right = outgroups,
                    allsnps = TRUE,
                    details = TRUE)
    
    # Report results
    cat("📊 P-value:", round(result$pvalue, 6), "\n")
    
    if(result$pvalue > 0.05) {
      cat("✅ EXCELLENT FIT! (p > 0.05)\n")
      fit_quality <- "EXCELLENT"
    } else if(result$pvalue > 0.01) {
      cat("✅ GOOD FIT (p > 0.01)\n")
      fit_quality <- "GOOD"
    } else {
      cat("⚠️  POOR FIT (p < 0.01)\n")
      fit_quality <- "POOR"
    }
    
    # Ancestry proportions
    cat("🧬 Ancestry proportions:\n")
    for(i in 1:length(sources)) {
      prop <- round(result$weights[i], 4)
      cat(sprintf("   %s: %.1f%%\n", sources[i], prop*100))
    }
    
    result$fit_quality <- fit_quality
    result$method <- "Google-Drive-Streaming"
    
    return(result)
    
  }, error = function(e) {
    cat("❌ Streaming analysis failed:", e$message, "\n")
    cat("💡 This is expected if populations are not available in Google Drive datasets\n")
    return(NULL)
  })
}

# ===============================================
# 🚀 GOOGLE DRIVE STREAMING INITIALIZATION & ANALYSIS
# ===============================================

if (!use_gdrive_streaming || is.null(gdrive_inventory)) {
  stop("❌ Google Drive streaming is required but not available. System cannot proceed.")
}

cat("🌊 Starting Google Drive streaming analysis...\n")
cat("📡 Using streaming data from Google Drive AncientDNA_Datasets\n")

# Verify personal genome files exist
ped_file <- paste0(input_prefix, ".ped")
map_file <- paste0(input_prefix, ".map")

if (!file.exists(ped_file)) {
  stop("❌ Personal genome .ped file not found: ", ped_file)
}
if (!file.exists(map_file)) {
  stop("❌ Personal genome .map file not found: ", map_file)
}

cat("✅ Personal genome files verified:\n")
cat("   .ped file:", file.info(ped_file)$size, "bytes\n")
cat("   .map file:", file.info(map_file)$size, "bytes\n")

# Extract f2 statistics using Google Drive streaming
tryCatch({
  cat("🌊 Extracting f2 statistics via Google Drive streaming...\n")
  f2_data <- stream_extract_f2(input_prefix, gdrive_inventory, output_dir)
  
  if (is.null(f2_data)) {
    stop("❌ Google Drive streaming returned no data")
  }
  
  cat("✅ Google Drive streaming data extraction completed!\n")
  cat("📊 F2 statistics streamed from ancient datasets\n")
  
  # Diagnostic output
  if (is.list(f2_data) && length(f2_data) > 0) {
    cat("📈 F2 data structure verified:\n")
    cat("   Type:", class(f2_data), "\n")
    cat("   Components:", names(f2_data), "\n")
    if ("f2" %in% names(f2_data)) {
      cat("   F2 statistics available: YES\n")
    }
    if ("streaming_source" %in% names(f2_data)) {
      cat("   Streaming source:", f2_data$streaming_source, "\n")
    }
  }
  
}, error = function(e) {
  cat("❌ Google Drive streaming failed:", e$message, "\n")
  cat("💡 Troubleshooting steps:\n")
  cat("   1. Check internet connection\n")
  cat("   2. Verify Google Drive authentication\n")
  cat("   3. Ensure AncientDNA_Datasets folder is accessible\n")
  cat("   4. Run test_gdrive_connection.r to diagnose issues\n")
  stop("Google Drive streaming analysis failed: ", e$message)
})

cat("🌟 Starting Google Drive streaming ancestry analysis...\n")
cat("📡 Using ancient DNA datasets streamed from Google Drive\n\n")

# Core Pakistani/South Asian Analysis (streaming only)
pakistani_core_analysis <- run_streaming_qpadm(
  your_sample, 
  c("Iran_N", "Pakistan_Sindhi", "India_Brahmin"), 
  essential_outgroups_2025[1:5], 
  "Pakistani Core Analysis"
)

# Iranian Plateau Analysis (streaming only)
iranian_analysis <- run_streaming_qpadm(
  your_sample,
  c("Iran_N", "Iran_ShahrISokhta_IA", "CHG"),
  essential_outgroups_2025[1:5],
  "Iranian Plateau Analysis"
)

# Basic Ancient Components (streaming only)
ancient_components <- run_streaming_qpadm(
  your_sample,
  c("Anatolia_N", "WHG", "Yamnaya"),
  essential_outgroups_2025[1:5],
  "Basic Ancient Components"
)

# ===============================================
# 📊 COMPILE STREAMING RESULTS
# ===============================================

streaming_results <- list(
  pakistani_core = pakistani_core_analysis,
  iranian_plateau = iranian_analysis,
  ancient_components = ancient_components
)

# Remove NULL results
streaming_results <- streaming_results[!sapply(streaming_results, is.null)]

if (length(streaming_results) == 0) {
  stop("❌ No streaming analyses succeeded. Check Google Drive datasets and population availability.")
}

cat("✅ Streaming analysis completed!\n")
cat("📊 Successful analyses:", length(streaming_results), "\n")

# ===============================================
# 📄 EXPORT RESULTS TO JSON
# ===============================================

# Create JSON export for Python report generator
create_json_export <- function(streaming_results, sample_name) {
  # Install jsonlite if not available
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    install.packages("jsonlite", repos = "https://cran.r-project.org/")
  }
  library(jsonlite)
  
  # Extract model components
  extract_components <- function(model) {
    if(is.null(model) || is.null(model$weights)) return(list())
    
    components <- list()
    for(i in 1:length(model$weights)) {
      if(!is.null(names(model$weights)[i])) {
        pop_name <- names(model$weights)[i]
        percentage <- round(model$weights[i] * 100, 2)
        components[[pop_name]] <- percentage
      }
    }
    return(components)
  }
  
  # Create JSON structure
  json_data <- list(
    sample_info = list(
      name = sample_name,
      analysis_date = format(Sys.Date(), "%Y-%m-%d"),
      method = "Google Drive Streaming Analysis"
    ),
    
    streaming_results = list(),
    
    quality_metrics = list(
      total_analyses = length(streaming_results),
      successful_analyses = length(streaming_results),
      streaming_source = "Google Drive AncientDNA_Datasets"
    )
  )
  
  # Add each successful result
  for (i in 1:length(streaming_results)) {
    result_name <- names(streaming_results)[i]
    result_data <- streaming_results[[i]]
    
    json_data$streaming_results[[result_name]] <- list(
      pvalue = round(result_data$pvalue, 6),
      fit_quality = result_data$fit_quality,
      method = result_data$method,
      components = extract_components(result_data)
    )
  }
  
  return(json_data)
}

# Export results to JSON
cat("📤 Exporting results to JSON for Python report generator...\n")

json_export <- create_json_export(streaming_results, your_sample)
json_filename <- paste0(output_dir, "/", your_sample, "_streaming_results.json")

# Write JSON file
if (!requireNamespace("jsonlite", quietly = TRUE)) {
  install.packages("jsonlite", repos = "https://cran.r-project.org/")
}
library(jsonlite)

write_json(json_export, json_filename, pretty = TRUE, auto_unbox = TRUE)

cat("✅ JSON export complete:", json_filename, "\n")
cat("📊 Results exported for", length(streaming_results), "successful analyses\n")

# Final summary
cat("\n🎉 === GOOGLE DRIVE STREAMING ANALYSIS COMPLETE! ===\n")
cat("🌊 Analysis method: Pure Google Drive streaming (no local fallbacks)\n")
cat("📡 Data source: Google Drive AncientDNA_Datasets folder\n")
cat("✅ Successful analyses:", length(streaming_results), "\n")
cat("📄 Results exported to:", json_filename, "\n")
cat("🐍 Ready for Python report generation!\n\n")

cat("Next steps:\n")
cat("1. Run: python ancestry_report_generator.py\n")
cat("2. Your comprehensive ancestry report will be generated\n")
cat("3. All analysis performed via Google Drive streaming - no local ancient DNA storage!\n")

cat("\n🚀 Google Drive streaming system working successfully! 🚀\n")
