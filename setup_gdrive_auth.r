#!/usr/bin/env Rscript
# 🔐 Google Drive Authentication Setup
# Uses OAuth 2.0 client ID for desktop application

cat("🔐 Setting up Google Drive authentication...\n")

# Load required packages
if (!requireNamespace("googledrive", quietly = TRUE)) {
  stop("googledrive package not installed. Run: install.packages('googledrive')")
}

library(googledrive)

# Read the credentials file
credentials_file <- "google_credentials.json"
if (!file.exists(credentials_file)) {
  stop("Google credentials file 'google_credentials.json' not found")
}

cat("📁 Found credentials file:", credentials_file, "\n")

# Read and parse the credentials
credentials <- jsonlite::fromJSON(credentials_file)
client_id <- credentials$installed$client_id
client_secret <- credentials$installed$client_secret

cat("🔑 Client ID:", client_id, "\n")
cat("🔐 Client Secret: [HIDDEN]\n")

# Set up OAuth client
options(
  gargle_oauth_client_type = "installed",
  gargle_oauth_client_id = client_id,
  gargle_oauth_client_secret = client_secret
)

cat("✅ OAuth client configured successfully!\n")
cat("🌐 Ready for browser authentication...\n")

# Test authentication
tryCatch({
  cat("🧪 Testing Google Drive connection...\n")
  drive_auth(cache = TRUE, use_oob = FALSE)
  
  user_info <- drive_user()
  cat("✅ Connected as:", user_info$displayName, "\n")
  cat("📧 Email:", user_info$emailAddress, "\n")
  cat("🎉 Authentication successful!\n")
  
}, error = function(e) {
  cat("❌ Authentication failed:", e$message, "\n")
  cat("💡 Make sure you have internet connection and can access Google Drive\n")
}) 