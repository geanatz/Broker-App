# ===============================
#  Release Script - MAT Finance
# ===============================

$ErrorActionPreference = "Stop"

# Detect root-ul proiectului
$projectRoot  = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$coreDir      = "$projectRoot\release\core"
$installerDir = "$projectRoot\installer"
$outputDir    = "$installerDir\Output"
$issFile      = "$coreDir\MATFinanceInstaller.iss"

# Citește versiunea din .iss
$version = Select-String -Path $issFile -Pattern "^AppVersion=(.+)$" |
           ForEach-Object { $_.Matches.Groups[1].Value.Trim() }

if (-not $version) {
    Write-Error "Nu am putut citi AppVersion din $issFile"
}

$versionFolder  = "$projectRoot\release\v$version"
$exeName        = "MATFinanceInstaller.exe"
$exeReleasePath = "$versionFolder\$exeName"
$checksumPath   = "$versionFolder\$exeName.sha256"

# Creează folderul versiunii dacă nu există
if (!(Test-Path $versionFolder)) {
    New-Item -ItemType Directory -Path $versionFolder | Out-Null
}

Write-Host "[1/6] Building Flutter Windows..."
pushd $projectRoot
flutter build windows --release
popd

Write-Host "[2/6] Căutare ISCC.exe..."
$cmd = Get-Command ISCC.exe -ErrorAction SilentlyContinue
if ($cmd) {
    $innoExe = $cmd.Source
} else {
    Write-Error "Nu am găsit ISCC.exe (Inno Setup Compiler) în PATH."
}

Write-Host "[3/6] Compiling installer..."
& $innoExe $issFile 1> $null
if ($LASTEXITCODE -ne 0) {
    Write-Error "Compilarea installer-ului a eșuat!"
}

if (!(Test-Path "$outputDir\$exeName")) {
    Write-Error "Installer nu a fost găsit în $outputDir"
}

Write-Host "[4/6] Mutare installer în folder versiune..."
Move-Item -Path "$outputDir\$exeName" -Destination $exeReleasePath -Force
if (Test-Path $outputDir) { Remove-Item -Path $outputDir -Recurse -Force }

Write-Host "[5/6] Generating SHA256..."
Get-FileHash -Algorithm SHA256 $exeReleasePath |
    Select-Object -ExpandProperty Hash |
    Out-File -Encoding ascii -NoNewline $checksumPath

# --- UPLOAD PE GITHUB ---
Write-Host "[6/6] Creare/actualizare release și upload fișiere pe GitHub..."

$repo = "geanatz/MAT-Finance"
$tag  = "v$version"
$releaseName = "MAT Finance $version"
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
    if ($release.assets.Count -gt 0) {
        Write-Host "   🗑 Ștergere asset-uri existente..."
        foreach ($asset in $release.assets) {
            try {
                $deleteUrl = "https://api.github.com/repos/$repo/releases/assets/$($asset.id)"
                Invoke-RestMethod -Uri $deleteUrl -Method Delete `
                    -Headers @{ Authorization = "token $token" } -ErrorAction Stop
                Write-Host "      ✅ Șters: $($asset.name)"
            } catch {
                Write-Host "      ⚠️ Nu s-a putut șterge $($asset.name): $($_.Exception.Message)"
            }
        }
    } else {
        Write-Host "   ℹ Nu există asset-uri de șters"
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
Write-Host "   📤 Upload fișiere..."
foreach ($file in Get-ChildItem $versionFolder) {
    try {
        $uploadUrl = $release.upload_url.Split('{')[0] + "?name=$($file.Name)"
        Invoke-RestMethod -Uri $uploadUrl -Method Post `
            -Headers @{
                Authorization  = "token $token"
                "Content-Type" = "application/octet-stream"
            } -InFile $file.FullName -ErrorAction Stop
        Write-Host "      ✅ Upload: $($file.Name)"
    } catch {
        Write-Host "      ❌ Eroare upload $($file.Name): $($_.Exception.Message)"
        # Continuă cu următorul fișier în loc să se oprească
    }
}

Write-Host ""
Write-Host "🏁 Release v$version creat/actualizat pe GitHub!"