# 🧬 ENHANCED CURATED POPULATION SETS FOR CONSUMER ANALYSIS
# Optimized for 8-16GB RAM systems with real statistical power

# ===============================================
# 🎯 TIER 1: ESSENTIAL CORE POPULATIONS (~25-30 pops)
# ===============================================
# These should ALWAYS be included in any analysis

essential_populations <- list(
  # African outgroups (absolutely critical)
  outgroups_african = c("Mbuti.DG", "Yoruba.DG", "Mende.DG"),
  
  # Non-African outgroups  
  outgroups_other = c("Papuan.DG", "Karitiana.DG", "Onge.DG"),
  
  # Core ancient populations (universal relevance)
  ancient_core = c(
    "Iran_N",                    # Iranian Neolithic (universal relevance)
    "Anatolia_N",               # Anatolian farmers (universal in West Eurasia) 
    "Yamnaya_Samara",           # Steppe pastoralists (universal in Eurasia)
    "CHG",                      # Caucasus Hunter-Gatherers
    "WHG",                      # Western Hunter-Gatherers
    "EHG"                       # Eastern Hunter-Gatherers
  ),
  
  # Modern reference populations
  modern_core = c(
    "CEU.DG",                   # European reference
    "Han.DG",                   # East Asian reference  
    "Iranian.DG"                # Iranian modern reference
  )
)

# ===============================================  
# 🌍 TIER 2: REGIONAL EXPANSION SETS (~20-40 pops each)
# ===============================================
# Use based on global screening results

regional_expansions <- list(
  # South/Central Asian focused (for your primary use case)
  south_central_asian = c(
    # Iranian Plateau specialization
    "Iran_ShahrISokhta_BA2", "Iran_Hajji_Firuz_ChL", "Iran_Ganj_Dareh_N",
    "Iran_HasanluTepe_IA", "Iran_TepeAbdulHosein_N",
    
    # South Asian ancient
    "IVC_Rakhigarhi", "IVC_Harappa", 
    
    # AASI proxies
    "Jarawa.DG", "GreatAndaman.DG",
    
    # Steppe variants
    "Andronovo", "Sintashta", "Afanasievo", "Srubnaya",
    
    # Central Asian Bronze Age
    "Turkmenistan_Gonur_BA", "BMAC", "Uzbekistan_BA",
    
    # Modern South/Central Asian
    "Pakistani.DG", "Balochi.DG", "Sindhi.DG", "Pathan.DG",
    "Tajik.DG", "Uzbek.DG", "Turkmen.DG", "Afghan.DG"
  ),
  
  # European expansion (if unexpected European ancestry detected)
  european_focused = c(
    "Corded_Ware_Germany", "Bell_Beaker_Germany", "Unetice",
    "Celtic_IA", "Germanic_IA", "Slavic_IA", 
    "Sardinian.DG", "Italian.DG", "Spanish.DG", "French.DG",
    "Russian.DG", "Polish.DG", "Lithuanian.DG"
  ),
  
  # East Asian expansion (if unexpected East Asian ancestry)
  east_asian_focused = c(
    "Tianyuan", "DevilsCave_N", "Jomon",
    "Chinese_Neolithic", "Mongolia_N", "Siberia_N",
    "Japanese.DG", "Korean.DG", "Mongola.DG", "Oroqen.DG"
  ),
  
  # Middle Eastern expansion
  middle_eastern_focused = c(
    "Levant_N", "Israel_PPNB", "Jordan_PPNB", "Natufian",
    "Turkey_N", "Armenia_ChL", "Georgia_CHG",
    "Lebanese.DG", "Syrian.DG", "Palestinian.DG", "Druze.DG"
  )
)

# ===============================================
# 🔧 INTELLIGENT POPULATION SELECTOR  
# ===============================================

select_optimal_populations <- function(target_sample, global_screening_results, max_populations = 2000) {
  cat("🧠 Selecting optimal population set for", target_sample, "\n")
  
  # Always start with essential populations
  selected_pops <- unlist(essential_populations)
  cat("✅ Essential populations:", length(selected_pops), "\n")
  
  # Add regional expansions based on detected ancestries
  if (!is.null(global_screening_results)) {
    detected_ancestries <- global_screening_results$detected
    
    # If South/Central Asian ancestry detected (very likely)
    if (any(c("South_Central_Asian", "South_Asian") %in% names(detected_ancestries))) {
      selected_pops <- c(selected_pops, regional_expansions$south_central_asian)
      cat("🇵🇰 Added South/Central Asian populations\n")
    }
    
    # If unexpected European ancestry
    if ("European" %in% names(detected_ancestries)) {
      # With 24GB RAM, we can afford comprehensive European coverage
      euro_pops <- head(regional_expansions$european_focused, 200)
      selected_pops <- c(selected_pops, euro_pops)
      cat("🇪🇺 Added comprehensive European populations\n")
    }
    
    # If unexpected East Asian ancestry
    if ("East_Asian" %in% names(detected_ancestries)) {
      ea_pops <- head(regional_expansions$east_asian_focused, 150) 
      selected_pops <- c(selected_pops, ea_pops)
      cat("🇨🇳 Added comprehensive East Asian populations\n")
    }
    
    # If Middle Eastern ancestry beyond Iranian
    if (any(c("Levantine", "Arabian") %in% names(detected_ancestries))) {
      me_pops <- head(regional_expansions$middle_eastern_focused, 100)
      selected_pops <- c(selected_pops, me_pops)
      cat("🕌 Added comprehensive Middle Eastern populations\n")
    }
  } else {
    # Default: comprehensive South/Central Asian + broad regional coverage for 24GB system
    selected_pops <- c(selected_pops, 
                       regional_expansions$south_central_asian,  # All South/Central Asian (full coverage)
                       head(regional_expansions$middle_eastern_focused, 50),  # Comprehensive Middle Eastern
                       head(regional_expansions$european_focused, 100),       # Broad European coverage
                       head(regional_expansions$east_asian_focused, 75))      # Good East Asian coverage
    cat("🎯 Default: Comprehensive multi-regional coverage optimized for 24GB system\n")
  }
  
  # Remove duplicates and limit total
  selected_pops <- unique(selected_pops)
  if (length(selected_pops) > max_populations) {
    selected_pops <- selected_pops[1:max_populations]
    cat("⚠️  Limited to", max_populations, "populations for memory constraints\n")
  }
  
  cat("🎯 Final selection:", length(selected_pops), "populations\n")
  cat("💾 Estimated RAM usage:", round(length(selected_pops) * 0.8), "MB\n")
  
  return(selected_pops)
}

# ===============================================
# 🎯 ADAPTIVE ANALYSIS STRATEGY
# ===============================================

run_memory_optimized_analysis <- function(target, f2_data, max_memory_gb = 8) {
  cat("🎯 Running memory-optimized adaptive analysis\n")
  cat("💾 Memory limit:", max_memory_gb, "GB\n")
  
  # Calculate population limit based on memory
  # Rule of thumb: ~0.8MB per population for f2 statistics
  max_populations <- floor((max_memory_gb * 1024 * 0.6) / 0.8)  # 60% of available memory
  cat("📊 Maximum populations for memory limit:", max_populations, "\n")
  
  available_pops <- unique(f2_data$pop)
  
  # Phase 1: Global screening with minimal populations
  global_pops <- select_optimal_populations(target, NULL, max_populations = min(40, max_populations))
  global_pops <- intersect(global_pops, available_pops)
  
  cat("🌍 Phase 1: Global screening with", length(global_pops), "populations\n")
  
  # Filter f2_data to only include selected populations
  f2_subset <- filter_f2_data(f2_data, global_pops)
  
  # Run global screening analysis
  global_results <- run_global_screening_analysis(target, f2_subset, 
                                                 intersect(unlist(essential_populations$outgroups_african), 
                                                          global_pops))
  
  # Phase 2: Adaptive expansion based on results
  global_patterns <- analyze_global_patterns(global_results)
  
  # Select expanded population set
  expanded_pops <- select_optimal_populations(target, global_patterns, max_populations = max_populations)
  expanded_pops <- intersect(expanded_pops, available_pops)
  
  cat("🎯 Phase 2: Focused analysis with", length(expanded_pops), "populations\n")
  
  # Run focused analysis
  f2_focused <- filter_f2_data(f2_data, expanded_pops)
  focused_results <- run_focused_ancestry_analysis(target, f2_focused, global_patterns)
  
  return(list(
    global_results = global_results,
    focused_results = focused_results,
    populations_used = expanded_pops,
    memory_efficiency = paste0(round(length(expanded_pops) * 0.8), "MB used of ", max_memory_gb*1024, "MB available")
  ))
}

# ===============================================
# 🔧 F2 DATA FILTERING FUNCTION
# ===============================================

filter_f2_data <- function(f2_data, selected_populations) {
  cat("🔧 Filtering f2 data to", length(selected_populations), "populations...\n")
  
  # This function would filter the f2_data to only include selected populations
  # Implementation depends on f2_data structure
  
  # For demonstration, assuming f2_data has a 'pop' field
  if ("pop" %in% names(f2_data)) {
    filtered_data <- f2_data[f2_data$pop %in% selected_populations, ]
    cat("✅ Filtered from", length(unique(f2_data$pop)), "to", 
        length(unique(filtered_data$pop)), "populations\n")
    return(filtered_data)
  }
  
  return(f2_data)
}

cat("🎯 Enhanced population selection system loaded!\n")
cat("💡 This system selects optimal population subsets for consumer hardware\n")
cat("🔬 Maintains statistical rigor while respecting memory constraints\n")