# Script pentru crearea aplicației release Broker App
# Autor: Development Team
# Versiunea: 1.0

Write-Host "=== Broker App Release Builder ===" -ForegroundColor Green
Write-Host ""

# Verifică dacă Flutter este instalat
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "EROARE: Flutter nu este instalat sau nu este în PATH." -ForegroundColor Red
    exit 1
}

Write-Host "1. Construire aplicația Flutter pentru Windows..." -ForegroundColor Yellow
flutter build windows --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "EROARE: Build-ul a eșuat!" -ForegroundColor Red
    exit 1
}

Write-Host "2. Creare folder release..." -ForegroundColor Yellow
$releaseFolder = "./BrokerApp_Release"
if (Test-Path $releaseFolder) {
    Remove-Item $releaseFolder -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $releaseFolder | Out-Null

Write-Host "3. Copiere fișiere aplicație..." -ForegroundColor Yellow
Copy-Item -Path "./build/windows/x64/runner/Release/*" -Destination $releaseFolder -Recurse -Force

Write-Host "4. Creare README..." -ForegroundColor Yellow
# README-ul este deja creat

Write-Host "" 
Write-Host "=== BUILD COMPLET ===" -ForegroundColor Green
Write-Host "Aplicația a fost creată în folderul: $releaseFolder" -ForegroundColor Cyan
Write-Host "Pentru a rula aplicația, deschideți: $releaseFolder/broker_app.exe" -ForegroundColor Cyan
Write-Host "" 