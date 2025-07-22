# 🛠️ Complete Setup Guide

## 🚀 **Quick Setup (Recommended)**

### **Option A: Simplified Analysis**
```bash
# 1. Install dependencies
chmod +x quick_setup.sh
./quick_setup.sh

# 2. Convert genome data (if needed)
python convert_23andme_binary.py your_genome_file.txt

# 3. Run analysis
Rscript working_ancestry_analysis.r Results/YourName Results/

# 4. Generate PDF
python ancestry_report_generator.py --sample-name YourName --results-dir Results/ --output-dir Results/
```

---

## 🔐 **Google Drive Authentication (Advanced)**

### **Prerequisites:**
- Google Cloud project with Drive API enabled
- OAuth 2.0 credentials downloaded as `google_credentials.json`
- Ancient DNA datasets uploaded to Google Drive folder named "AncientDNA_Datasets"

### **Step 1: Place Credentials**
```bash
# Place your credentials file in project root
cp ~/Downloads/google_credentials.json .
```

### **Step 2: Interactive Authentication**
```bash
# Run interactive authentication
Rscript interactive_gdrive_auth.r
```

This will:
- Open your browser for Google authentication
- Cache authentication tokens locally
- Test the connection automatically

### **Step 3: Test Connection**
```bash
# Verify everything works
Rscript test_gdrive_connection.r
```

Expected output:
```
✅ Connected as: Your Name
📧 Email: your.email@gmail.com
✅ Found folder: AncientDNA_Datasets
📊 Found X files in ancient datasets
```

### **Step 4: Run Advanced Analysis**
```bash
# Now you can use the full streaming system
Rscript production_ancestry_system.r Results/YourName Results/
```

---

## 📋 **Manual Authentication (If Interactive Fails)**

### **Open Terminal and Navigate**
```bash
cd "/Users/yav/DNA Analysis Project"
source /Users/yav/miniforge3/bin/activate gdrive_streaming
```

### **Start R Session**
```bash
R
```

### **Run Authentication Commands in R**
```r
# Load required packages
library(googledrive)
library(jsonlite)

# Read your credentials
creds <- fromJSON("google_credentials.json")

# Configure OAuth client
drive_auth_configure(
  client_id = creds$web$client_id,
  client_secret = creds$web$client_secret
)

# Authenticate (opens browser)
drive_auth(
  scopes = "https://www.googleapis.com/auth/drive.readonly",
  cache = TRUE
)

# Test connection
drive_user()
```

### **Verify Setup**
```r
# Find your ancient datasets folder
folders <- drive_find(pattern = "AncientDNA_Datasets", type = "folder")
print(folders)

# Exit R
quit(save = "no")
```

---

## 🔧 **Troubleshooting**

### **Common Issues:**

#### **1. Package Installation Fails**
```bash
# Re-run setup with verbose output
./quick_setup.sh 2>&1 | tee setup_log.txt
```

#### **2. Google Drive Authentication Fails**
- ✅ Check `google_credentials.json` is valid OAuth 2.0 credentials
- ✅ Ensure Google Drive API is enabled in Google Cloud Console
- ✅ Try clearing browser cache and cookies
- ✅ Disable popup blockers for authentication

#### **3. Memory Errors**
```bash
# Use simplified analysis instead
Rscript working_ancestry_analysis.r Results/YourName Results/
```

#### **4. Permission Errors**
```bash
# Fix script permissions
chmod +x quick_setup.sh
chmod +x *.sh
```

#### **5. Python Dependencies Missing**
```bash
# Install Python packages
pip install pandas numpy matplotlib seaborn scikit-learn reportlab pillow
```

### **System Requirements:**
- **RAM**: 16GB minimum, 24GB recommended
- **Storage**: <1GB for simplified, <2GB for full system
- **OS**: macOS (tested), Linux (compatible)
- **Internet**: Required for Google Drive streaming

---

## 📊 **Verification Steps**

### **Test Your Setup:**
```bash
# 1. Check R packages
Rscript -e "library(admixtools); library(dplyr); cat('✅ R packages OK\n')"

# 2. Check Python packages  
python -c "import pandas, numpy, matplotlib; print('✅ Python packages OK')"

# 3. Test file permissions
ls -la *.sh

# 4. Test Google Drive (if configured)
Rscript test_gdrive_connection.r
```

### **Expected File Structure:**
```
DNA Analysis Project/
├── ✅ working_ancestry_analysis.r
├── ✅ production_ancestry_system.r  
├── ✅ ancestry_report_generator.py
├── ✅ convert_23andme_binary.py
├── ✅ quick_setup.sh (executable)
├── ✅ google_credentials.json (if using Drive)
└── ✅ Results/ (empty, ready for analysis)
```

---

## 🎯 **Ready to Analyze!**

Once setup is complete, you can:

1. **Convert your genome data** (if needed)
2. **Run ancestry analysis** 
3. **Generate professional PDF report**
4. **Enjoy your detailed ancestry breakdown!**

For questions or issues, check the terminal output for specific error messages. 