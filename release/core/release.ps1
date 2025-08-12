# ===============================
#  Release Script - Broker App
# ===============================

$ErrorActionPreference = "Stop"

# Detect root-ul proiectului
$projectRoot  = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$coreDir      = "$projectRoot\release\core"
$installerDir = "$projectRoot\installer"
$outputDir    = "$installerDir\Output"
$issFile      = "$coreDir\BrokerAppInstaller.iss"

# Citește versiunea din .iss
$version = Select-String -Path $issFile -Pattern "^AppVersion=(.+)$" |
           ForEach-Object { $_.Matches.Groups[1].Value.Trim() }

if (-not $version) {
    Write-Error "Nu am putut citi AppVersion din $issFile"
}

$versionFolder  = "$projectRoot\release\v$version"
$exeName        = "BrokerAppInstaller.exe"
$exeReleasePath = "$versionFolder\$exeName"
$checksumPath   = "$versionFolder\$exeName.sha256"
$zipPath        = "$versionFolder\BrokerAppInstaller-v$version.zip"

# Creează folderul versiunii dacă nu există
if (!(Test-Path $versionFolder)) {
    New-Item -ItemType Directory -Path $versionFolder | Out-Null
}

Write-Host "[1/7] Building Flutter Windows..."
pushd $projectRoot
flutter build windows --release
popd

Write-Host "[2/7] Căutare ISCC.exe..."
$cmd = Get-Command ISCC.exe -ErrorAction SilentlyContinue
if ($cmd) {
    $innoExe = $cmd.Source
} else {
    Write-Error "Nu am găsit ISCC.exe (Inno Setup Compiler) în PATH."
}

Write-Host "[3/7] Compiling installer..."
& $innoExe $issFile 1> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Compilarea installer-ului a eșuat!"
}

if (!(Test-Path "$outputDir\$exeName")) {
    Write-Error "Installer nu a fost găsit în $outputDir"
}

Write-Host "[4/7] Mutare installer în folder versiune..."
Move-Item -Path "$outputDir\$exeName" -Destination $exeReleasePath -Force
if (Test-Path $outputDir) { Remove-Item -Path $outputDir -Recurse -Force }

Write-Host "[5/7] Generating SHA256..."
Get-FileHash -Algorithm SHA256 $exeReleasePath |
    Select-Object -ExpandProperty Hash |
    Out-File -Encoding ascii -NoNewline $checksumPath

Write-Host "[6/7] Creare arhivă ZIP..."
Compress-Archive -Path $exeReleasePath -DestinationPath $zipPath -Force

# --- UPLOAD PE GITHUB ---
Write-Host "[7/7] Creare/actualizare release și upload fișiere pe GitHub..."

$repo = "geanatz/Broker-App"
$tag  = "v$version"
$releaseName = "BrokerApp $version"
$token = $env:GITHUB_TOKEN

if (-not $token) {
    Write-Error "Nu există GITHUB_TOKEN în variabilele de mediu!"
}

# Verifică dacă există deja release-ul cu acest tag
$existingRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/tags/$tag" `
    -Headers @{ Authorization = "token $token" } -ErrorAction SilentlyContinue

if ($existingRelease) {
    Write-Host "ℹ Release $tag există deja – îl actualizez..."
    $release = $existingRelease

    # Șterge asset-urile existente cu același nume
    foreach ($asset in $release.assets) {
        $deleteUrl = "https://api.github.com/repos/$repo/releases/assets/$($asset.id)"
        Invoke-RestMethod -Uri $deleteUrl -Method Delete `
            -Headers @{ Authorization = "token $token" }
        Write-Host "   🗑 Șters asset: $($asset.name)"
    }

    # Update metadata (opțional)
    $updateData = @{
        name       = $releaseName
        draft      = $false
        prerelease = $false
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "https://api.github.com/repos/$repo/releases/$($release.id)" `
        -Method Patch -Headers @{ Authorization = "token $token" } `
        -Body $updateData

} else {
    Write-Host "ℹ Creare release nou..."
    $releaseUrl = "https://api.github.com/repos/$repo/releases"
    $releaseData = @{
        tag_name   = $tag
        name       = $releaseName
        draft      = $false
        prerelease = $false
    } | ConvertTo-Json
    $release = Invoke-RestMethod -Uri $releaseUrl -Method Post `
        -Headers @{ Authorization = "token $token" } `
        -Body $releaseData
}

# Încarcă fiecare fișier din folderul versiunii
foreach ($file in Get-ChildItem $versionFolder) {
    $uploadUrl = $release.upload_url.Split('{')[0] + "?name=$($file.Name)"
    Invoke-RestMethod -Uri $uploadUrl -Method Post `
        -Headers @{
            Authorization  = "token $token"
            "Content-Type" = "application/octet-stream"
        } -InFile $file.FullName
    Write-Host "   ✅ Upload: $($file.Name)"
}

Write-Host ""
Write-Host "🏁 Release v$version creat/actualizat pe GitHub!"