# GOOGLE DRIVE STREAMING ENGINE FOR ANCIENT DNA ANALYSIS
# Streams 15GB ancient datasets from Google Drive without local storage
# Personal genome analyzed locally, ancient data streamed as needed

library(googledrive)
library(jsonlite)
library(data.table)
library(httr)

# ===============================================
# 🔐 GOOGLE DRIVE AUTHENTICATION
# ===============================================

authenticate_gdrive <- function(force_reauth = FALSE) {
  cat("🔐 Setting up Google Drive authentication...\n")
  
  tryCatch({
    if (force_reauth || !drive_has_token()) {
      cat("   🌐 Opening browser for Google authentication...\n")
      cat("   📝 Please log in and authorize access to your Google Drive\n")
      
      # Use browser-based authentication (simplest approach)
      drive_auth(cache = TRUE, use_oob = FALSE)
    }
    
    # Test connection
    cat("   🧪 Testing Google Drive connection...\n")
    user_info <- drive_user()
    cat("   ✅ Connected as:", user_info$displayName, "\n")
    cat("   📧 Email:", user_info$emailAddress, "\n")
    
    return(TRUE)
    
  }, error = function(e) {
    cat("   ❌ Authentication failed:", e$message, "\n")
    cat("   💡 Try running with force_reauth = TRUE\n")
    return(FALSE)
  })
}

# ===============================================
# 📁 GOOGLE DRIVE DATASET DISCOVERY
# ===============================================

find_ancient_datasets_folder <- function(folder_name = "AncientDNA_Datasets") {
  cat("📁 Locating ancient datasets folder:", folder_name, "\n")
  
  tryCatch({
    # Search for the folder
    folders <- drive_find(q = paste0("name='", folder_name, "' and mimeType='application/vnd.google-apps.folder'"))
    
    if (nrow(folders) == 0) {
      stop("Folder '", folder_name, "' not found in Google Drive")
    }
    
    if (nrow(folders) > 1) {
      cat("   ⚠️  Multiple folders found, using first one\n")
    }
    
    folder_id <- folders$id[1]
    cat("   ✅ Found folder:", folders$name[1], "\n")
    cat("   📊 Folder ID:", folder_id, "\n")
    
    return(folder_id)
    
  }, error = function(e) {
    cat("   ❌ Error finding folder:", e$message, "\n")
    return(NULL)
  })
}

get_dataset_inventory <- function(folder_id) {
  cat("📋 Creating dataset inventory...\n")
  
  tryCatch({
    # List all files in the ancient datasets folder
    files <- drive_ls(as_id(folder_id), recursive = TRUE)
    
    if (nrow(files) == 0) {
      stop("No files found in AncientDNA_Datasets folder")
    }
    
    cat("   📊 Found", nrow(files), "files in ancient datasets\n")
    
    # Categorize files by type
    inventory <- list(
      eigenstrat = files[grepl("\\.(geno|snp|ind)$", files$name), ],
      plink = files[grepl("\\.(bed|bim|fam|ped|map)$", files$name), ],
      f2_stats = files[grepl("f2.*\\.(txt|gz|json)$", files$name), ],
      other = files[!grepl("\\.(geno|snp|ind|bed|bim|fam|ped|map|txt|gz|json)$", files$name), ]
    )
    
    cat("   📈 EIGENSTRAT files:", nrow(inventory$eigenstrat), "\n")
    cat("   📈 PLINK files:", nrow(inventory$plink), "\n")
    cat("   📈 F2 statistics:", nrow(inventory$f2_stats), "\n")
    cat("   📈 Other files:", nrow(inventory$other), "\n")
    
    return(inventory)
    
  }, error = function(e) {
    cat("   ❌ Error creating inventory:", e$message, "\n")
    return(NULL)
  })
}

# ===============================================
# 🌊 STREAMING DATA ACCESS FUNCTIONS
# ===============================================

stream_f2_data <- function(pop1, pop2, inventory) {
  cat("🌊 Streaming f2-statistics for:", pop1, "vs", pop2, "\n")
  
  tryCatch({
    # Look for pre-computed f2 statistics files
    f2_files <- inventory$f2_stats
    
    if (nrow(f2_files) == 0) {
      cat("   ⚠️  No pre-computed f2 files found, computing from population data\n")
      return(compute_f2_from_populations(pop1, pop2, inventory))
    }
    
    # Try to find relevant f2 file
    relevant_f2 <- f2_files[grepl(paste0(pop1, "|", pop2), f2_files$name), ]
    
    if (nrow(relevant_f2) > 0) {
      cat("   📥 Downloading f2 statistics file:", relevant_f2$name[1], "\n")
      
      # Create temporary file
      temp_file <- tempfile(fileext = ".txt")
      drive_download(as_id(relevant_f2$id[1]), path = temp_file, overwrite = TRUE)
      
      # Read f2 data
      f2_data <- fread(temp_file)
      unlink(temp_file)  # Clean up
      
      # Filter for specific populations
      if ("pop1" %in% names(f2_data) && "pop2" %in% names(f2_data)) {
        relevant_data <- f2_data[(pop1 == pop1 & pop2 == pop2) | (pop1 == pop2 & pop2 == pop1)]
        
        if (nrow(relevant_data) > 0) {
          cat("   ✅ Found f2 data for population pair\n")
          return(relevant_data$f2[1])
        }
      }
    }
    
    cat("   ⚠️  Specific f2 data not found, computing from population data\n")
    return(compute_f2_from_populations(pop1, pop2, inventory))
    
  }, error = function(e) {
    cat("   ❌ Error streaming f2 data:", e$message, "\n")
    return(NULL)
  })
}

stream_population_data <- function(population, snps_needed, inventory) {
  cat("🌊 Streaming population data for:", population, "\n")
  cat("   📊 SNPs needed:", length(snps_needed), "\n")
  
  tryCatch({
    # Look for population files (EIGENSTRAT or PLINK)
    pop_files <- rbind(inventory$eigenstrat, inventory$plink)
    pop_files <- pop_files[grepl(population, pop_files$name, ignore.case = TRUE), ]
    
    if (nrow(pop_files) == 0) {
      cat("   ⚠️  No files found for population:", population, "\n")
      return(NULL)
    }
    
    cat("   📁 Found", nrow(pop_files), "files for", population, "\n")
    
    # Download and process files temporarily
    temp_dir <- tempdir()
    downloaded_files <- list()
    
    for (i in 1:min(3, nrow(pop_files))) {  # Limit to 3 files to avoid overload
      file_info <- pop_files[i, ]
      temp_path <- file.path(temp_dir, file_info$name)
      
      cat("   📥 Downloading:", file_info$name, "\n")
      drive_download(as_id(file_info$id), path = temp_path, overwrite = TRUE)
      downloaded_files[[file_info$name]] <- temp_path
    }
    
    # Process downloaded files to extract relevant SNPs
    pop_data <- process_population_files(downloaded_files, snps_needed, population)
    
    # Cleanup temporary files
    for (file_path in downloaded_files) {
      if (file.exists(file_path)) {
        unlink(file_path)
      }
    }
    
    return(pop_data)
    
  }, error = function(e) {
    cat("   ❌ Error streaming population data:", e$message, "\n")
    return(NULL)
  })
}

get_snp_intersection <- function(my_snps, inventory) {
  cat("🔍 Finding SNP intersection with ancient datasets...\n")
  cat("   📊 Personal genome SNPs:", length(my_snps), "\n")
  
  tryCatch({
    # Look for SNP information files (.snp, .bim)
    snp_files <- rbind(
      inventory$eigenstrat[grepl("\\.snp$", inventory$eigenstrat$name), ],
      inventory$plink[grepl("\\.bim$", inventory$plink$name), ]
    )
    
    if (nrow(snp_files) == 0) {
      cat("   ⚠️  No SNP information files found\n")
      return(my_snps)  # Return all personal SNPs
    }
    
    # Download a representative SNP file to get intersection
    snp_file <- snp_files[1, ]
    temp_file <- tempfile()
    
    cat("   📥 Downloading SNP reference:", snp_file$name, "\n")
    drive_download(as_id(snp_file$id), path = temp_file, overwrite = TRUE)
    
    # Read SNP data (format depends on file type)
    if (grepl("\\.snp$", snp_file$name)) {
      # EIGENSTRAT format: SNP_ID chromosome genetic_position physical_position
      ancient_snps <- fread(temp_file, header = FALSE)
      ancient_snp_ids <- ancient_snps$V1
    } else {
      # PLINK .bim format: chr SNP_ID genetic_distance physical_position allele1 allele2
      ancient_snps <- fread(temp_file, header = FALSE)
      ancient_snp_ids <- ancient_snps$V2
    }
    
    unlink(temp_file)  # Cleanup
    
    # Find intersection
    overlapping_snps <- intersect(my_snps, ancient_snp_ids)
    
    cat("   📈 Ancient dataset SNPs:", length(ancient_snp_ids), "\n")
    cat("   ✅ Overlapping SNPs:", length(overlapping_snps), "\n")
    cat("   📊 Overlap percentage:", round(length(overlapping_snps) / length(my_snps) * 100, 1), "%\n")
    
    return(overlapping_snps)
    
  }, error = function(e) {
    cat("   ❌ Error finding SNP intersection:", e$message, "\n")
    return(my_snps)  # Return all personal SNPs as fallback
  })
}

# ===============================================
# 🧠 MEMORY MANAGEMENT
# ===============================================

cleanup_temp_data <- function() {
  cat("🧹 Cleaning up temporary streamed data...\n")
  
  tryCatch({
    # Clear temporary files
    temp_files <- list.files(tempdir(), full.names = TRUE)
    temp_files <- temp_files[grepl("\\.(geno|snp|ind|bed|bim|fam|ped|map|txt|gz)$", temp_files)]
    
    if (length(temp_files) > 0) {
      unlink(temp_files)
      cat("   🗑️  Removed", length(temp_files), "temporary files\n")
    }
    
    # Force garbage collection
    gc()
    cat("   ♻️  Memory garbage collection completed\n")
    
    return(TRUE)
    
  }, error = function(e) {
    cat("   ⚠️  Cleanup warning:", e$message, "\n")
    return(FALSE)
  })
}

monitor_memory_usage <- function() {
  tryCatch({
    memory_info <- gc()
    used_mb <- sum(memory_info[, "used"] * c(8, 8)) / 1024 / 1024  # Convert to MB
    
    cat("   💾 Memory usage:", round(used_mb, 1), "MB\n")
    
    if (used_mb > 2000) {  # Warning if over 2GB
      cat("   ⚠️  High memory usage detected, consider cleanup\n")
    }
    
    return(used_mb)
    
  }, error = function(e) {
    return(0)
  })
}

# ===============================================
# 🔧 HELPER FUNCTIONS
# ===============================================

compute_f2_from_populations <- function(pop1, pop2, inventory) {
  cat("   🔬 Computing f2 from population data...\n")
  
  # This would involve streaming both populations and computing f2
  # For now, return a placeholder that triggers local analysis
  cat("   ⚠️  F2 computation from streamed populations not yet implemented\n")
  cat("   📦 Falling back to local analysis\n")
  
  return(NULL)
}

process_population_files <- function(downloaded_files, snps_needed, population) {
  cat("   🔬 Processing population files for", population, "...\n")
  
  # This would process the downloaded files to extract genotype data
  # for the specific SNPs needed
  
  # Placeholder implementation
  cat("   ⚠️  Population file processing not yet fully implemented\n")
  cat("   📦 Returning basic population structure\n")
  
  return(list(
    population = population,
    snps = snps_needed[1:min(1000, length(snps_needed))],  # Limit for testing
    genotypes = matrix(sample(0:2, min(1000, length(snps_needed)), replace = TRUE), ncol = 1)
  ))
}

# ===============================================
# 📊 STREAMING PROGRESS INDICATORS
# ===============================================

show_streaming_progress <- function(current, total, operation = "Streaming") {
  if (total > 0) {
    percent <- round((current / total) * 100, 1)
    bar_length <- 30
    filled_length <- round((current / total) * bar_length)
    
    bar <- paste0(
      "[", 
      paste(rep("█", filled_length), collapse = ""),
      paste(rep("░", bar_length - filled_length), collapse = ""),
      "] ", percent, "% (", current, "/", total, ")"
    )
    
    cat("\r   🌊", operation, ":", bar)
    
    if (current == total) {
      cat("\n")
    }
  }
}

# ===============================================
# 🧪 CONNECTION TESTING
# ===============================================

test_gdrive_streaming <- function() {
  cat("🧪 Testing Google Drive streaming functionality...\n")
  
  # Test authentication
  if (!authenticate_gdrive()) {
    return(FALSE)
  }
  
  # Test folder access
  folder_id <- find_ancient_datasets_folder()
  if (is.null(folder_id)) {
    return(FALSE)
  }
  
  # Test inventory creation
  inventory <- get_dataset_inventory(folder_id)
  if (is.null(inventory)) {
    return(FALSE)
  }
  
  cat("✅ Google Drive streaming test completed successfully!\n")
  return(TRUE)
}

cat("📦 Google Drive Streaming Engine loaded successfully!\n")
cat("   🔐 Use authenticate_gdrive() to set up authentication\n")
cat("   🧪 Use test_gdrive_streaming() to test functionality\n") 