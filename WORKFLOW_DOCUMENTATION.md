# ULTIMATE 2025 ANCESTRY ANALYSIS SYSTEM - PROPER WORKFLOW

## ⚠️ CRITICAL: DO NOT DEVIATE FROM THIS WORKFLOW

### Proper Analysis Pipeline:
1. **Genome Input** → Raw genome file (23andMe, AncestryDNA, etc.)
2. **Convert 23andMe** → `convert_23andme.py` → PLINK format (.ped/.map)
3. **Ultimate Ancestry System** → `ultimate_2025_ancestry_system.r` → JSON results
4. **Ancestry PDF Report Generator** → `ancestry_report_generator.py` → Professional PDF

### ❌ COMMON MISTAKES TO AVOID:
- **DO NOT** create simplified or alternative R scripts
- **DO NOT** skip the ultimate ancestry system due to package issues
- **DO NOT** go directly from genome conversion to PDF generation
- **FIX** R package installation issues instead of creating workarounds

### ✅ WHEN R PACKAGES FAIL:
1. Install system dependencies via conda
2. Use proper GitHub repositories for packages
3. Install admixtools from: `uqrmaie1/admixtools`
4. Only proceed when ALL required packages are installed

### Data Flow:
```
Genome → PLINK → ultimate_2025_ancestry_system.r → ancestry_results.json → ancestry_report_generator.py → PDF
```

The ultimate ancestry system produces the specific JSON structure that the PDF generator expects. Any deviation breaks the integration. 