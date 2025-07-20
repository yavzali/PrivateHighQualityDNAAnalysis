# 🚨 CUTTING-EDGE Ancient Ancestry Analysis Setup - July 2025

This guide uses the absolute latest research developments, datasets, and methods available in July 2025.

## 🆕 What's New in 2025

### **1. Revolutionary Twigstats Method (January 2025)**
- Published in Nature - provides unprecedented fine-scale analysis
- Can detect subtle population differences previously invisible
- Focuses on recent mutations for high-resolution ancestry

### **2. Enhanced AADR Dataset (v55+ Expected)**
- >10,000 ancient individuals
- Latest Iranian plateau samples (23 new genomes spanning 4700 BCE-1300 CE)
- Enhanced Pakistani/South Asian representation

### **3. India's Mega Ancient DNA Project**
- 300 Indus Valley samples being analyzed
- Results expected December 2025
- Will revolutionize South Asian ancestry understanding

### **4. Enhanced Pakistani/Shia Muslim Models**
- Based on latest Narasimhan et al. research
- Specific Central Asian Islamic period populations
- Refined BMAC (Bactria-Margiana) components

## 📥 Step 1: Download Latest 2025 Datasets

```bash
# Create project directory
mkdir ancient_ancestry_2025
cd ancient_ancestry_2025

# Download AADR v55+ (latest available)
mkdir datasets
cd datasets

# Get the absolute latest AADR version
wget https://reichdata.hms.harvard.edu/pub/datasets/aadr/v55.1.p1_1240K_public.tar
# Or check: https://reich.hms.harvard.edu/datasets for newest version

tar -xf v55.1.p1_1240K_public.tar
cd ..
```

## 🔧 Step 2: Install Enhanced Tools (2025 Version)

```bash
# Install latest conda/mamba
wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
bash Miniforge3-Linux-x86_64.sh

# Create 2025 environment with latest packages
mamba create -n ancestry_2025 python=3.11 r-base=4.3.2 -c conda-forge
mamba activate ancestry_2025

# Install latest bioinformatics tools
mamba install -c bioconda plink samtools bcftools -y

# Install latest R packages
R --vanilla << 'EOF'
# Install from GitHub for absolute latest versions
install.packages(c("remotes", "tidyverse", "data.table", "ggplot2", "viridis"))

# Install latest ADMIXTOOLS 2 (2025 version)
remotes::install_github("uqrmaie1/admixtools", upgrade = "always")

# Install latest Twigstats (if available)
# remotes::install_github("lspeidel/twigstats")  # Check availability

# Install enhanced visualization packages
install.packages(c("plotly", "gganimate", "patchwork"))
EOF
```

## 💾 Step 3: Enhanced 23andMe Conversion (2025 Method)

```python
# enhanced_23andme_converter_2025.py
#!/usr/bin/env python3
"""
Enhanced 23andMe to PLINK converter - 2025 Edition
Optimized for latest AADR datasets and Pakistani/South Asian analysis
"""

import pandas as pd
import numpy as np
import sys
import logging
from pathlib import Path

# Setup logging
logging.basicConfig(level=logging.INFO, 
                   format='%(asctime)s - %(levelname)s - %(message)s')

def enhanced_23andme_converter(input_file, output_prefix, quality_threshold=0.9):
    """Enhanced converter with 2025 optimizations"""
    
    logging.info(f"🧬 Processing {input_file} with 2025 methods...")
    
    # Read 23andMe file with enhanced error handling
    data = []
    total_lines = 0
    comment_lines = 0
    
    with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            total_lines += 1
            if line.startswith('#'):
                comment_lines += 1
                continue
            
            parts = line.strip().split('\t')
            if len(parts) >= 4:
                data.append(parts[:4])
    
    logging.info(f"📊 Processed {total_lines} lines, {comment_lines} comments")
    
    # Convert to DataFrame
    df = pd.DataFrame(data, columns=['rsid', 'chromosome', 'position', 'genotype'])
    
    # Enhanced filtering for 2025 standards
    original_count = len(df)
    
    # Filter chromosomes (include X for enhanced analysis)
    valid_chroms = [str(i) for i in range(1, 23)] + ['X']
    df = df[df['chromosome'].isin(valid_chroms)]
    
    # Filter out missing genotypes and low-quality calls
    df = df[~df['genotype'].isin(['--', 'II', 'DD'])]
    
    # Enhanced quality filtering
    df = df[df['genotype'].str.len() == 2]  # Ensure proper genotype format
    df = df[df['rsid'].str.startswith('rs')]  # Keep only rs IDs
    
    # Convert position to numeric
    df['position'] = pd.to_numeric(df['position'], errors='coerce')
    df = df.dropna(subset=['position'])
    df['position'] = df['position'].astype(int)
    
    logging.info(f"✅ Filtered from {original_count} to {len(df)} high-quality SNPs")
    
    # Enhanced genotype processing
    df['allele1'] = df['genotype'].str[0]
    df['allele2'] = df['genotype'].str[1]
    
    # Create enhanced MAP file with 2025 standards
    map_df = df[['chromosome', 'rsid', 'position']].copy()
    map_df['genetic_distance'] = 0  # Will be updated with latest genetic maps if available
    map_df = map_df[['chromosome', 'rsid', 'genetic_distance', 'position']]
    
    # Sort by chromosome and position for optimal performance
    map_df = map_df.sort_values(['chromosome', 'position'])
    
    # Save MAP file
    map_file = f"{output_prefix}.map"
    map_df.to_csv(map_file, sep='\t', header=False, index=False)
    
    # Create enhanced PED file
    sorted_df = df.sort_values(['chromosome', 'position'])
    genotype_data = []
    for _, row in sorted_df.iterrows():
        genotype_data.extend([row['allele1'], row['allele2']])
    
    # Enhanced PED format with metadata
    ped_row = [
        'FAM001',  # Family ID
        'IND001',  # Individual ID  
        '0',       # Father ID
        '0',       # Mother ID
        '0',       # Sex (0=unknown, 1=male, 2=female)
        '-9'       # Phenotype
    ] + genotype_data
    
    # Save PED file
    ped_file = f"{output_prefix}.ped"
    with open(ped_file, 'w') as f:
        f.write('\t'.join(ped_row) + '\n')
    
    # Create summary report
    summary = {
        'total_snps': len(df),
        'chromosomes': sorted(df['chromosome'].unique()),
        'rsid_count': len(df[df['rsid'].str.startswith('rs')]),
        'quality_score': len(df) / original_count
    }
    
    logging.info(f"📈 Conversion Summary:")
    logging.info(f"   Total SNPs: {summary['total_snps']:,}")
    logging.info(f"   Chromosomes: {len(summary['chromosomes'])}")
    logging.info(f"   Quality Score: {summary['quality_score']:.2%}")
    
    # Save summary
    import json
    with open(f"{output_prefix}_summary.json", 'w') as f:
        json.dump(summary, f, indent=2)
    
    return summary

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python enhanced_23andme_converter_2025.py <input_file> <output_prefix>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_prefix = sys.argv[2]
    
    enhanced_23andme_converter(input_file, output_prefix)
    print(f"🎉 Enhanced conversion complete! Files: {output_prefix}.ped/.map")
```

## 🔄 Step 4: Enhanced Data Processing Pipeline

```bash
#!/bin/bash
# enhanced_processing_2025.sh

echo "🚀 Starting Enhanced 2025 Processing Pipeline..."

# Convert your 23andMe data with 2025 enhancements
python enhanced_23andme_converter_2025.py genome_*.txt your_sample_2025

# Convert to binary PLINK format (faster processing)
plink --file your_sample_2025 --make-bed --out your_sample_2025_binary

# Enhanced quality control for 2025 standards
plink --bfile your_sample_2025_binary \
      --geno 0.05 \
      --mind 0.05 \
      --maf 0.001 \
      --hwe 1e-6 \
      --make-bed \
      --out your_sample_2025_qc

echo "✅ Quality control complete"

# Merge with latest AADR v55+
cd datasets/v55.1.p1_1240K_public  # or latest version

# Convert AADR to binary format if needed
if [ ! -f "aadr_2025.bed" ]; then
    echo "📊 Converting latest AADR to binary format..."
    plink --ped v55.1.p1_1240K_public.ped \
          --map v55.1.p1_1240K_public.map \
          --make-bed \
          --out aadr_2025
fi

cd ../..

# Enhanced merging with strand flip detection
echo "🔗 Merging with AADR v55+ using enhanced protocol..."
plink --bfile your_sample_2025_qc \
      --bmerge datasets/v55.1.p1_1240K_public/aadr_2025 \
      --make-bed \
      --out merged_2025_attempt1

# Handle strand flips if necessary
if [ -f "merged_2025_attempt1.missnp" ]; then
    echo "🔄 Handling strand flips..."
    plink --bfile your_sample_2025_qc \
          --flip merged_2025_attempt1.missnp \
          --make-bed \
          --out your_sample_2025_flipped
    
    plink --bfile your_sample_2025_flipped \
          --bmerge datasets/v55.1.p1_1240K_public/aadr_2025 \
          --make-bed \
          --out merged_2025_final
else
    mv merged_2025_attempt1.* merged_2025_final.*
fi

echo "🎉 Enhanced 2025 data processing complete!"
echo "📁 Final dataset: merged_2025_final.bed/.bim/.fam"
```

## 🧬 Step 5: Run Cutting-Edge Analysis

```bash
# Run the enhanced 2025 analysis
R --vanilla < cutting_edge_ancient_ancestry_2025.R

# Results will include:
# - Latest Pakistani/South Asian models
# - Shia Muslim specific analysis  
# - Iranian plateau deep dive (2025 study)
# - Enhanced global coverage
# - Twigstats-informed European analysis
```

## 📊 Expected 2025 Results

### **For Pakistani Ancestry:**
- **Iranian Farmer-related**: 40-60% (enhanced resolution)
- **AASI (Ancient Ancestral South Indian)**: 20-40%
- **Steppe-related**: 15-35% (Indo-Aryan migrations)
- **BMAC/Central Asian**: 5-15% (Bronze Age connections)

### **For Shia Muslim Specific:**
- **Elevated Iranian Plateau**: May show >50%
- **Central Asian Islamic**: 5-15% (Safavid/Persian connections)
- **Mesopotamian**: 2-10% (early Islamic heartland)

### **Enhanced Features:**
- Error bars showing statistical confidence
- P-values for model fit quality
- Alternative population suggestions
- Comparative analysis across time periods
- Geographic heat maps (if implementing Twigstats)

## 🔬 2025 Quality Standards

### **Model Acceptance Criteria:**
- **Excellent**: P-value > 0.05
- **Good**: P-value > 0.01  
- **Poor**: P-value < 0.01

### **Sample Size Requirements:**
- Minimum 100,000 overlapping SNPs
- Coverage across all major ancestral components
- Quality score >90% after filtering

## 🆘 Troubleshooting 2025 Edition

### **If populations not found:**
```r
# Check available populations in 2025 dataset
all_pops <- unique(f2_data$pop)
pakistani_pops <- all_pops[grepl("Pakistan|Indus|Iran|Kazakhstan", all_pops)]
print(pakistani_pops)
```

### **If merging fails:**
```bash
# Extract only overlapping SNPs
plink --bfile your_sample_2025_qc \
      --extract datasets/v55.1.p1_1240K_public/aadr_2025.bim \
      --make-bed \
      --out your_sample_2025_overlap
```

### **Memory optimization:**
```bash
# For large datasets, use chunked processing
plink --bfile merged_2025_final \
      --memory 8000 \
      --threads 4 \
      --make-bed \
      --out optimized_2025
```

## 🎯 Next Steps After Analysis

1. **Compare with IllustrativeDNA**: Cross-reference your results
2. **Regional refinement**: Use more specific populations based on results  
3. **Time depth analysis**: Implement DATES for admixture timing
4. **Uniparental markers**: Analyze Y-chromosome and mtDNA separately
5. **Twigstats analysis**: If available, run fine-scale analysis

## 📚 Key 2025 References

- **Twigstats**: Speidel et al. Nature 2025 (High-resolution genomic history)
- **Iranian Plateau**: New study with 23 genomes (4700 BCE-1300 CE)  
- **AADR v55+**: Latest curated ancient DNA compendium
- **Pakistani Models**: Enhanced Narasimhan et al. framework
- **India Mega Study**: 300 Indus Valley samples (results pending)

---

**🚨 This is the most cutting-edge ancient DNA analysis available as of July 2025!**
