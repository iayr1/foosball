# Creates the Play Store upload key for Sling Arena and writes android/key.properties.
# Run from the project root:  powershell -ExecutionPolicy Bypass -File tool\create_upload_key.ps1
# You type the password yourself; it is never printed. Both output files are git-ignored.
# BACK UP android\app\upload-keystore.jks AND THE PASSWORD. Losing them means you cannot update the app.

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$keystore = Join-Path $root 'android\app\upload-keystore.jks'
$props = Join-Path $root 'android\key.properties'

if (Test-Path $keystore) {
    Write-Host "A keystore already exists at $keystore - not overwriting it." -ForegroundColor Yellow
    exit 1
}

$org = Read-Host 'Organisation / developer name for the certificate (e.g. Athlorun)'
if ([string]::IsNullOrWhiteSpace($org)) { $org = 'Athlorun' }

function Read-Plain([string]$prompt) {
    $s = Read-Host -AsSecureString $prompt
    $b = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
    try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($b) }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }
}

do {
    $p1 = Read-Plain 'Choose a keystore password (min 6 characters)'
    $p2 = Read-Plain 'Type it again'
    if ($p1 -ne $p2) { Write-Host 'Passwords do not match, try again.' -ForegroundColor Red }
    elseif ($p1.Length -lt 6) { Write-Host 'Too short, try again.' -ForegroundColor Red }
} while ($p1 -ne $p2 -or $p1.Length -lt 6)

$env:SLING_KS_PASS = $p1
try {
    & keytool -genkeypair -v `
        -keystore $keystore `
        -storetype JKS `
        -alias upload `
        -keyalg RSA -keysize 2048 -validity 10000 `
        -dname "CN=Sling Arena, OU=Mobile, O=$org" `
        -storepass:env SLING_KS_PASS `
        -keypass:env SLING_KS_PASS
    if ($LASTEXITCODE -ne 0) { throw 'keytool failed' }
}
finally {
    Remove-Item Env:\SLING_KS_PASS -ErrorAction SilentlyContinue
}

@"
storePassword=$p1
keyPassword=$p1
keyAlias=upload
storeFile=upload-keystore.jks
"@ | Set-Content -Path $props -Encoding ascii

Write-Host ''
Write-Host 'Done.' -ForegroundColor Green
Write-Host "  Keystore:   $keystore"
Write-Host "  Properties: $props"
Write-Host 'Back up the keystore file and password somewhere safe (not in git).' -ForegroundColor Yellow
