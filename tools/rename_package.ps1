$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location (Join-Path $root '..')

$files = Get-ChildItem -Path 'lib' -Recurse -Filter '*.dart'
foreach ($f in $files) {
  $c = Get-Content -Raw -Encoding UTF8 -Path $f.FullName
  $c = $c -replace 'package:broker_app','package:mat_finance'
  Set-Content -Path $f.FullName -Value $c -Encoding UTF8
}
Write-Host "Replaced imports in" $files.Count "files"

