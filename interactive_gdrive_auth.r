#!/usr/bin/env Rscript
# 🔐 Interactive Google Drive Authentication
# Run this script directly in terminal for browser authentication

cat("🚀 INTERACTIVE GOOGLE DRIVE AUTHENTICATION\n")
cat("==========================================\n\n")

# Load required packages
suppressMessages({
  library(googledrive)
  library(jsonlite)
})

# Read credentials
cat("📁 Reading Google OAuth credentials...\n")
if (!file.exists("google_credentials.json")) {
  stop("❌ google_credentials.json not found!")
}

creds <- fromJSON("google_credentials.json")
cat("✅ Credentials loaded successfully\n")
cat("🔑 Client ID:", substr(creds$installed$client_id, 1, 20), "...\n\n")

# Configure OAuth client
cat("⚙️  Configuring OAuth client...\n")
options(
  gargle_oauth_client_type = "installed",
  gargle_oauth_client_id = creds$installed$client_id,
  gargle_oauth_client_secret = creds$installed$client_secret
)

# Clear any existing tokens to force fresh authentication
cat("🧹 Clearing existing tokens...\n")
drive_deauth()

cat("\n🌐 STARTING BROWSER AUTHENTICATION\n")
cat("==================================\n")
cat("📝 Your browser will open automatically\n")
cat("🔐 Please log in to your Google account\n")
cat("✅ Grant access to Google Drive\n")
cat("⏳ Waiting for authentication...\n\n")

# Attempt authentication with browser
tryCatch({
  drive_auth(
    scopes = "https://www.googleapis.com/auth/drive",
    cache = TRUE,
    use_oob = FALSE  # This will open browser
  )
  
  # Test the connection
  cat("🧪 Testing connection...\n")
  user_info <- drive_user()
  
  cat("\n🎉 AUTHENTICATION SUCCESSFUL!\n")
  cat("=============================\n")
  cat("👤 User:", user_info$displayName, "\n")
  cat("📧 Email:", user_info$emailAddress, "\n")
  cat("💾 Token cached for future use\n\n")
  
  # Test folder access
  cat("📁 Searching for AncientDNA_Datasets folder...\n")
  folders <- drive_find(q = "name='AncientDNA_Datasets' and mimeType='application/vnd.google-apps.folder'")
  
  if (nrow(folders) > 0) {
    cat("✅ Found AncientDNA_Datasets folder!\n")
    cat("📊 Folder ID:", folders$id[1], "\n")
    
    # Quick file count
    files <- drive_ls(as_id(folders$id[1]))
    cat("📈 Contains", nrow(files), "files\n")
  } else {
    cat("⚠️  AncientDNA_Datasets folder not found\n")
    cat("💡 Please create this folder and upload your ancient DNA datasets\n")
  }
  
  cat("\n🚀 Ready for DNA streaming analysis!\n")
  
}, error = function(e) {
  cat("\n❌ AUTHENTICATION FAILED\n")
  cat("========================\n")
  cat("Error:", e$message, "\n")
  cat("\n💡 Troubleshooting:\n")
  cat("   • Make sure you have internet connection\n")
  cat("   • Try running this script again\n")
  cat("   • Check that your Google credentials are valid\n")
}) 