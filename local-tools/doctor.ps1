$ErrorActionPreference = 'Continue'
$Root = Split-Path -Parent $PSScriptRoot
$ComposeDir = Join-Path $Root 'mytelegram-dev\docker\compose'
$StateFile = Join-Path $Root '.mytelegram-local.json'
$Header = Join-Path $Root 'TMessagesProj\jni\tgnet\LocalServerConfig.h'
$EnvFile = Join-Path $ComposeDir '.env'

Write-Host '=== MyTelegram local doctor ===' -ForegroundColor Cyan
if (Test-Path $StateFile) {
    $state = Get-Content $StateFile -Raw | ConvertFrom-Json
    Write-Host "Configured IP: $($state.serverIp)"
} else {
    Write-Host 'Not configured yet. Run SETUP_LOCAL.cmd.' -ForegroundColor Yellow
}

$layer = Select-String -Path (Join-Path $Root 'TMessagesProj\src\main\java\org\telegram\tgnet\TLRPC.java') -Pattern 'public static final int LAYER = ' | Select-Object -First 1
Write-Host ("Client {0}" -f $layer.Line.Trim())
$version = Select-String -Path $EnvFile -Pattern '^MyTelegramVersion=' | Select-Object -First 1
Write-Host "Server $($version.Line)"

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host 'FAIL: docker not found' -ForegroundColor Red
    exit 1
}

docker info *> $null
if ($LASTEXITCODE -ne 0) {
    Write-Host 'FAIL: Docker Engine is not running' -ForegroundColor Red
    exit 1
}

Push-Location $ComposeDir
try {
    docker compose -p mytelegram-local -f docker-compose.yml -f docker-compose.local.yml ps
} finally { Pop-Location }

foreach ($port in @(20443,20543,20643,20644,30443,30444)) {
    $ok = Test-NetConnection -ComputerName 127.0.0.1 -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($ok) { Write-Host "OK   TCP 127.0.0.1:$port" -ForegroundColor Green }
    else { Write-Host "FAIL TCP 127.0.0.1:$port" -ForegroundColor Red }
}

foreach ($port in @(27017,6379,9000,15672)) {
    $ok = Test-NetConnection -ComputerName 127.0.0.1 -Port $port -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($ok) { Write-Host "OK   local service port $port" -ForegroundColor Green }
    else { Write-Host "FAIL local service port $port" -ForegroundColor Red }
}
