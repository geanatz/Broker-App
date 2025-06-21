# Deploy Firebase Indexes and Rules
# Run this script to deploy Firestore indexes and security rules

Write-Host "🔥 Deploying Firebase Firestore indexes and rules..." -ForegroundColor Yellow

# Check if Firebase CLI is installed
if (!(Get-Command firebase -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Firebase CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "npm install -g firebase-tools" -ForegroundColor White
    exit 1
}

# Check if we're in the correct directory
if (!(Test-Path "firebase.json")) {
    Write-Host "❌ firebase.json not found. Please run this script from the project root directory." -ForegroundColor Red
    exit 1
}

# Login to Firebase (if not already logged in)
Write-Host "🔐 Checking Firebase authentication..." -ForegroundColor Blue
firebase login --reauth

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Firebase login failed. Please try again." -ForegroundColor Red
    exit 1
}

# Deploy Firestore rules
Write-Host "📋 Deploying Firestore security rules..." -ForegroundColor Blue
firebase deploy --only firestore:rules

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to deploy Firestore rules." -ForegroundColor Red
    exit 1
}

# Deploy Firestore indexes
Write-Host "🔍 Deploying Firestore indexes..." -ForegroundColor Blue
firebase deploy --only firestore:indexes

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to deploy Firestore indexes." -ForegroundColor Red
    exit 1
}

Write-Host "✅ Firebase Firestore indexes and rules deployed successfully!" -ForegroundColor Green
Write-Host "📝 Note: Index creation may take a few minutes to complete in Firebase Console." -ForegroundColor Yellow
Write-Host "🔗 Check status at: https://console.firebase.google.com/project/broker-app-f1n4nc3/firestore/indexes" -ForegroundColor Cyan

# Wait for user input before closing
Write-Host "Press any key to continue..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Optional: Open Firebase Console
$openConsole = Read-Host "Open Firebase Console? (y/n)"
if ($openConsole -eq "y" -or $openConsole -eq "Y") {
    Start-Process "https://console.firebase.google.com/project/broker-app-f1n4nc3/firestore"
} 