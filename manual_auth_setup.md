# 🔐 Manual Google Drive Authentication Setup

Since automated authentication isn't working in the non-interactive session, please follow these steps **directly in your terminal**:

## Step 1: Open Terminal and Navigate to Project

```bash
cd "/Users/yav/DNA Analysis Project"
source /Users/yav/miniforge3/bin/activate gdrive_streaming
```

## Step 2: Start Interactive R Session

```bash
R
```

## Step 3: Run Authentication Commands in R

Copy and paste these commands **one by one** in the R console:

```r
# Load required packages
library(googledrive)
library(jsonlite)

# Read your credentials
creds <- fromJSON("google_credentials.json")

# Configure OAuth client
options(
  gargle_oauth_client_type = "installed",
  gargle_oauth_client_id = creds$installed$client_id,
  gargle_oauth_client_secret = creds$installed$client_secret
)

# Clear any existing tokens
drive_deauth()

# Start authentication (this will open your browser)
drive_auth(cache = TRUE, use_oob = FALSE)
```

## Step 4: Complete Browser Authentication

1. **Your browser will open automatically**
2. **Log in to your Google account** 
3. **Grant access to Google Drive**
4. **Copy the authorization code** if prompted
5. **Paste it back in the R console** if needed

## Step 5: Test the Connection

```r
# Test authentication
user_info <- drive_user()
print(paste("Connected as:", user_info$displayName))

# Look for your AncientDNA_Datasets folder
folders <- drive_find(q = "name='AncientDNA_Datasets' and mimeType='application/vnd.google-apps.folder'")
print(paste("Found", nrow(folders), "AncientDNA_Datasets folder(s)"))

# Exit R when done
quit()
```

## Step 6: Test the System

After successful authentication, come back here and I'll help you test the streaming system and analyze your cousin's genome!

## What This Accomplishes

- ✅ Sets up Google Drive authentication
- ✅ Caches credentials for future use
- ✅ Verifies access to your AncientDNA_Datasets folder
- ✅ Enables streaming analysis without local ancient DNA storage

## Next Steps

Once you've completed the authentication, let me know and I'll help you:

1. **Convert your cousin's genome** to the right format
2. **Test the streaming connection** 
3. **Run the ancestry analysis** using Google Drive datasets
4. **Generate the professional PDF report** 