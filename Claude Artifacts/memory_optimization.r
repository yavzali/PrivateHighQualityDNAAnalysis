# 💾 MEMORY-OPTIMIZED ANALYSIS PIPELINE
# Handles large datasets on consumer hardware (8-16GB RAM)

# ===============================================
# 🧠 INTELLIGENT MEMORY MANAGEMENT
# ===============================================

monitor_memory_usage <- function(threshold_gb = 12) {
  # Get current memory usage
  gc_info <- gc()
  used_mb <- sum(gc_info[, "used"] * c(8, 8)) / 1024 / 1024  # Convert to MB
  used_gb <- used_mb / 1024
  
  cat(sprintf("💾 Current memory usage: %.2f GB\n", used_gb))
  
  if (used_gb > threshold_gb) {
    cat("⚠️  Memory usage approaching limit - triggering cleanup\n")
    # Force garbage collection
    for(i in 1:3) gc()
    
    # Get updated usage
    gc_info <- gc()
    new_used_gb <- sum(gc_info[, "used"] * c(8, 8)) / 1024 / 1024 / 1024
    cat(sprintf("✅ After cleanup: %.2f GB (freed %.2f GB)\n", 
                new_used_gb, used_gb - new_used_gb))
  }
  
  return(used_gb)
}

# ===============================================
# 📊 CHUNKED F2 STATISTICS COMPUTATION
# ===============================================

compute_f2_in_chunks <- function(input_prefix, population_subset, chunk_size = 50) {
  cat("📊 Computing f2 statistics in memory-efficient chunks...\n")
  cat("🎯 Target populations:", length(population_subset), "\n")
  cat("📦 Chunk size:", chunk_size, "populations\n")
  
  # Split populations into chunks
  population_chunks <- split(population_subset, ceiling(seq_along(population_subset) / chunk_size))
  cat("🔢 Total chunks:", length(population_chunks), "\n")
  
  all_f2_results <- list()
  
  for (i in seq_along(population_chunks)) {
    cat(sprintf("\n📦 Processing chunk %d/%d (%d populations)...\n", 
                i, length(population_chunks), length(population_chunks[[i]])))
    
    # Monitor memory before chunk
    monitor_memory_usage()
    
    tryCatch({
      # Create temporary dataset with just this chunk + your sample
      chunk_pops <- c(basename(input_prefix), population_chunks[[i]])
      
      # Extract f2 for this chunk only
      chunk_f2 <- extract_f2_subset(input_prefix, chunk_pops)
      
      # Store results
      all_f2_results[[paste0("chunk_", i)]] <- chunk_f2
      
      cat("✅ Chunk", i, "completed successfully\n")
      
      # Cleanup after each chunk
      rm(chunk_f2)
      gc()
      
    }, error = function(e) {
      cat("❌ Chunk", i, "failed:", e$message, "\n")
      cat("🔄 Attempting with smaller subset...\n")
      
      # Try with smaller subset
      smaller_chunk <- head(population_chunks[[i]], chunk_size %/% 2)
      if (length(smaller_chunk) > 0) {
        tryCatch({
          chunk_pops <- c(basename(input_prefix), smaller_chunk)
          chunk_f2 <- extract_f2_subset(input_prefix, chunk_pops)
          all_f2_results[[paste0("chunk_", i, "_reduced")]] <- chunk_f2
          cat("✅ Reduced chunk", i, "completed\n")
        }, error = function(e2) {
          cat("❌ Even reduced chunk failed - skipping\n")
        })
      }
    })
  }
  
  # Combine all chunks
  cat("\n🔗 Combining all chunks...\n")
  combined_f2 <- combine_f2_chunks(all_f2_results)
  
  return(combined_f2)
}

# ===============================================
# 🎯 SMART POPULATION PRE-FILTERING
# ===============================================

prefilter_populations_by_relevance <- function(target_sample, available_populations, target_ancestry = "South_Central_Asian") {
  cat("🎯 Pre-filtering populations by relevance...\n")
  cat("🎪 Target ancestry focus:", target_ancestry, "\n")
  
  # Relevance scoring system
  relevance_scores <- list()
  
  for (pop in available_populations) {
    score <- 0
    pop_lower <- tolower(pop)
    
    # High relevance for target ancestry
    if (target_ancestry == "South_Central_Asian") {
      if (grepl("iran|pakistan|baloch|sindhi|pathan|afghan|tajik|uzbek|turkmen", pop_lower)) {
        score <- score + 100
      }
      if (grepl("onge|jarawa|aasi|harappa|rakhigarhi", pop_lower)) {
        score <- score + 90
      }
      if (grepl("yamnaya|steppe|andronovo|sintashta|bmac|gonur", pop_lower)) {
        score <- score + 80
      }
      if (grepl("anatolia|levant|chg|whg|ehg", pop_lower)) {
        score <- score + 70
      }
    }
    
    # Essential outgroups (always high priority)
    if (grepl("mbuti|yoruba|mende|papuan|karitiana|onge", pop_lower)) {
      score <- score + 95
    }
    
    # Modern reference populations
    if (grepl("\\.dg$", pop_lower) && grepl("ceu|han|iranian", pop_lower)) {
      score <- score + 60
    }
    
    # Penalize very ancient/irrelevant populations
    if (grepl("magdalen|aurignac|gravett|solutre", pop_lower)) {
      score <- score - 50
    }
    
    relevance_scores[[pop]] <- score
  }
  
  # Sort by relevance
  sorted_pops <- names(sort(unlist(relevance_scores), decreasing = TRUE))
  
  cat("📊 Population relevance analysis:\n")
  cat("   🏆 Top 10 most relevant:\n")
  for (i in 1:min(10, length(sorted_pops))) {
    pop <- sorted_pops[i]
    score <- relevance_scores[[pop]]
    cat(sprintf("      %2d. %-25s (score: %d)\n", i, pop, score))
  }
  
  # Return top populations (adjust threshold based on memory)
  high_relevance <- sorted_pops[unlist(relevance_scores[sorted_pops]) > 30]
  
  cat("✅ Selected", length(high_relevance), "high-relevance populations\n")
  return(high_relevance)
}

# ===============================================
# ⚡ PROGRESSIVE ANALYSIS STRATEGY  
# ===============================================

run_progressive_analysis <- function(target, input_prefix, max_memory_gb = 8) {
  cat("⚡ PROGRESSIVE ANALYSIS STRATEGY\n")
  cat("🎯 Target:", target, "\n")
  cat("💾 Memory limit:", max_memory_gb, "GB\n\n")
  
  # Step 1: Quick population inventory
  cat("📋 Step 1: Population inventory...\n")
  available_pops <- get_available_populations(input_prefix)
  cat("📊 Total available populations:", length(available_pops), "\n")
  
  # Step 2: Relevance filtering
  cat("\n🎯 Step 2: Relevance filtering...\n")
  relevant_pops <- prefilter_populations_by_relevance(target, available_pops)
  
  # Step 3: Memory-based population selection
  cat("\n💾 Step 3: Memory-based selection...\n")
  max_pops <- calculate_max_populations(max_memory_gb)
  selected_pops <- head(relevant_pops, max_pops)
  
  cat("🎯 Final population set:", length(selected_pops), "populations\n")
  
  # Step 4: Progressive f2 computation
  cat("\n📊 Step 4: Progressive f2 computation...\n")
  f2_data <- compute_f2_in_chunks(input_prefix, selected_pops, chunk_size = 25)
  
  # Step 5: Hierarchical qpAdm analysis
  cat("\n🧬 Step 5: Hierarchical qpAdm analysis...\n")
  
  # 5a: Continental screening (fast)
  continental_results <- run_continental_screening(target, f2_data)
  
  # 5b: Regional focused analysis (medium)
  regional_results <- run_regional_analysis(target, f2_data, continental_results)
  
  # 5c: High-resolution final analysis (slower but precise)
  final_results <- run_high_resolution_analysis(target, f2_data, regional_results)
  
  return(list(
    continental = continental_results,
    regional = regional_results,
    final = final_results,
    populations_analyzed = selected_pops,
    memory_used = monitor_memory_usage()
  ))
}

# ===============================================
# 🔧 UTILITY FUNCTIONS
# ===============================================

calculate_max_populations <- function(max_memory_gb) {
  # Conservative estimate: 1MB per population for f2 statistics
  # Use 70% of available memory to leave room for R overhead
  usable_memory_mb <- max_memory_gb * 1024 * 0.7
  max_populations <- floor(usable_memory_mb / 1.0)
  
  # Cap at reasonable limits
  max_populations <- min(max_populations, 200)  # Diminishing returns beyond 200
  max_populations <- max(max_populations, 30)   # Need minimum for valid analysis
  
  cat("💾 Memory calculation: Max", max_populations, "populations for", max_memory_gb, "GB RAM\n")
  return(max_populations)
}

get_available_populations <- function(input_prefix) {
  # This would read the .fam file or dataset index to get available populations
  # Placeholder implementation
  cat("📋 Reading available populations from dataset...\n")
  
  # In real implementation, this would read from your actual dataset
  # For now, return a representative set
  return(c("Iran_N", "Yamnaya_Samara", "Onge.DG", "Mbuti.DG", "CEU.DG", 
           "Pakistani.DG", "Balochi.DG", "Anatolia_N", "CHG", "WHG"))
}

cat("💾 Memory-optimized analysis pipeline loaded!\n")
cat("🎯 This system can analyze 50-200 populations on consumer hardware\n")
cat("⚡ Progressive strategy: Continental → Regional → High-resolution\n")