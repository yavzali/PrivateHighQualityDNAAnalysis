# ULTIMATE 2025 ANCESTRY SYSTEM - DEPENDENCY INSTALLATION GUIDE

## ⚠️ CRITICAL: Complete Dependency Installation Required

The Ultimate 2025 Ancestry System requires numerous R packages that must be installed in the correct order. This guide documents the exact process that works.

## 📋 Prerequisites
- Conda environment: `ultra_dna` with R 4.3.3
- Active conda environment: `conda activate ultra_dna`

## 🔧 Step-by-Step Installation Process

### 1. Essential R Packages via Conda (Recommended)
```bash
# Install core R ecosystem packages
conda install -c conda-forge r-essentials r-devtools r-matrix r-mass r-nlme

# Install tidyverse and visualization packages
conda install -c conda-forge r-ggplot2 r-dplyr r-tidyr r-readr r-jsonlite

# Install specialized packages
conda install -c conda-forge r-igraph r-quadprog r-plotly r-viridis r-patchwork r-gridextra
```

### 2. ADMIXTOOLS 2 Installation (GitHub Required)
⚠️ **CRITICAL**: ADMIXTOOLS 2 is NOT available on CRAN and must be installed from GitHub.

**Official Repository**: https://github.com/uqrmaie1/admixtools

```R
# Install remotes package first
R -e "install.packages('remotes', repos='https://cran.rstudio.com/')"

# Install ADMIXTOOLS 2 from official GitHub repository
R -e "remotes::install_github('uqrmaie1/admixtools')"
```

### 3. Verification Commands
```R
# Verify all packages are installed
R -e "library(admixtools); packageVersion('admixtools')"
R -e "library(tidyverse); library(plotly); library(viridis); library(patchwork)"
```

## 🚨 Common Installation Issues & Solutions

### Issue 1: Package Compilation Errors
**Symptoms**: `clang: error: no input files` or compilation failures
**Solution**: Install pre-compiled versions via conda first, then GitHub packages

### Issue 2: Missing System Dependencies  
**Symptoms**: `quadprog` or `igraph` compilation failures
**Solution**: Use conda versions instead of CRAN compilation:
```bash
conda install -c conda-forge r-igraph r-quadprog
```

### Issue 3: ADMIXTOOLS 2 Not Found
**Symptoms**: `there is no package called 'admixtools'`
**Solution**: Must use GitHub installation - NOT available on CRAN
```R
remotes::install_github('uqrmaie1/admixtools')
```

## 📦 Complete Package List Required

### Core Analysis:
- `admixtools` (v2.0.10) - **GitHub only**: uqrmaie1/admixtools
- `tidyverse` (includes ggplot2, dplyr, tidyr, readr)
- `data.table`
- `jsonlite`

### Visualization:
- `plotly`
- `viridis` + `viridisLite` 
- `patchwork`
- `gridextra`

### Statistical:
- `Matrix`, `MASS`, `nlme` (base R dependencies)
- `igraph`, `quadprog` (admixtools dependencies)

### Development:
- `remotes` (for GitHub installations)
- `devtools` (optional, for development)

## 🎯 Installation Order (Critical)
1. **System dependencies** via conda first
2. **Core R packages** via conda  
3. **ADMIXTOOLS 2** via GitHub (requires remotes)
4. **Verification** of all packages

## ⏱️ Expected Installation Time
- Conda packages: ~5-10 minutes
- ADMIXTOOLS 2: ~3-5 minutes (compilation required)
- Total: ~15 minutes on macOS with good internet

## 🔍 Troubleshooting Commands
```bash
# Check conda environment
conda list | grep "r-"

# Check R package status
R -e "installed.packages()[,1]" | grep -E "(admixtools|tidyverse|plotly)"

# Verify ADMIXTOOLS 2 specifically
R -e "library(admixtools); cat('ADMIXTOOLS version:', as.character(packageVersion('admixtools')), '\n')"
```

This installation process was tested and verified on macOS with conda/miniforge3. 