param(
    [Parameter(Mandatory=$false)]
    [string]$ServerIp
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
& (Join-Path $PSScriptRoot 'configure-local.ps1') -ServerIp $ServerIp

if (-not (Get-Command java -ErrorAction SilentlyContinue)) {
    throw 'Java not found. Open the project once in Android Studio 2025.1.4 or set JAVA_HOME to Android Studio JBR.'
}
if (-not $env:ANDROID_HOME -and -not $env:ANDROID_SDK_ROOT) {
    $defaultSdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
    if (Test-Path $defaultSdk) {
        $env:ANDROID_HOME = $defaultSdk
        $env:ANDROID_SDK_ROOT = $defaultSdk
    } else {
        throw 'Android SDK not found. Install SDK 36, NDK 27.2.12479018 and CMake 3.22.1 in Android Studio.'
    }
}

Push-Location $Root
try {
    Write-Host 'Building local Android client...' -ForegroundColor Cyan
    & .\gradlew.bat :TMessagesProj_AppStandalone:assembleAfatDebug --no-daemon --stacktrace
    if ($LASTEXITCODE -ne 0) { throw 'Gradle build failed.' }

    $apk = Get-ChildItem -Path (Join-Path $Root 'TMessagesProj_AppStandalone\build\outputs\apk') -Recurse -Filter '*.apk' |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $apk) { throw 'Build finished but APK was not found.' }

    $dist = Join-Path $Root 'dist'
    New-Item -ItemType Directory -Path $dist -Force | Out-Null
    $out = Join-Path $dist 'MyTelegram-local.apk'
    Copy-Item $apk.FullName $out -Force
    Write-Host "APK: $out" -ForegroundColor Green
} finally { Pop-Location }
