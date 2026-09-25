param(
    [Parameter(Mandatory=$false)]
    [string]$ServerIp
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$ComposeDir = Join-Path $Root 'mytelegram-dev\docker\compose'
$ComposeFile = Join-Path $ComposeDir 'docker-compose.yml'
$LocalComposeFile = Join-Path $ComposeDir 'docker-compose.local.yml'
$MinioTag = 'RELEASE.2025-10-15T17-29-55Z'
$MinioCommit = '9e49d5e7a648f00e26f2246f4dc28e6b07f8c84a'
$MinioImage = "telegramlocal/minio:$MinioTag"
$MinioSource = Join-Path $ComposeDir 'data\minio-source'
$MinioDockerfile = Join-Path $PSScriptRoot 'minio.Dockerfile'

& (Join-Path $PSScriptRoot 'configure-local.ps1') -ServerIp $ServerIp

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker CLI not found. Install Docker Desktop and enable the WSL2 backend.'
}
try { docker info *> $null } catch { throw 'Docker Desktop is installed but Docker Engine is not running.' }
if ($LASTEXITCODE -ne 0) { throw 'Docker Desktop is installed but Docker Engine is not running.' }

docker image inspect $MinioImage *> $null
if ($LASTEXITCODE -ne 0) {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw 'Git is required for the first MinIO build. Install Git for Windows and rerun START_SERVER.cmd.'
    }
    if (-not (Test-Path $MinioSource)) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $MinioSource) -Force | Out-Null
        Write-Host 'Downloading pinned MinIO source from GitHub...' -ForegroundColor Cyan
        git clone --depth 1 --branch $MinioTag https://github.com/minio/minio.git $MinioSource
        if ($LASTEXITCODE -ne 0) { throw 'MinIO source download failed.' }
    }
    if (-not (Test-Path (Join-Path $MinioSource '.git'))) {
        throw "Incomplete MinIO source at $MinioSource. Remove only that folder and rerun START_SERVER.cmd."
    }
    $sourceCommit = (git -C $MinioSource rev-parse HEAD).Trim()
    if ($LASTEXITCODE -ne 0 -or $sourceCommit -ne $MinioCommit) {
        throw "MinIO source commit did not match pinned release. Found: $sourceCommit"
    }
    Write-Host 'Building MinIO locally from its verified upstream source (first run only)...' -ForegroundColor Cyan
    docker build -f $MinioDockerfile -t $MinioImage $MinioSource
    if ($LASTEXITCODE -ne 0) { throw 'Local MinIO image build failed.' }
}

Push-Location $ComposeDir
try {
    Write-Host 'Pulling pinned server/database images...' -ForegroundColor Cyan
    $services = @(docker compose -p mytelegram-local -f $ComposeFile -f $LocalComposeFile config --services |
        Where-Object { $_ -and $_.Trim() -ne 'minio' })
    if ($LASTEXITCODE -ne 0 -or $services.Count -eq 0) { throw 'docker compose config failed.' }
    docker compose -p mytelegram-local -f $ComposeFile -f $LocalComposeFile pull $services
    if ($LASTEXITCODE -ne 0) { throw 'docker compose pull failed.' }

    Write-Host 'Starting MongoDB, Redis, RabbitMQ, MinIO and MyTelegram...' -ForegroundColor Cyan
    docker compose -p mytelegram-local -f $ComposeFile -f $LocalComposeFile up -d --pull never --remove-orphans
    if ($LASTEXITCODE -ne 0) { throw 'docker compose up failed.' }

    # Open only MTProto gateway ports to other machines. DB/admin ports stay bound to localhost.
    $ports = @(20443,20543,20643,20644,30443,30444)
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isAdmin) {
        $ruleName = 'MyTelegram Local MTProto'
        Get-NetFirewallRule -DisplayName $ruleName -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
        New-NetFirewallRule -DisplayName $ruleName -Direction Inbound -Action Allow -Protocol TCP -LocalPort ($ports -join ',') | Out-Null
        Write-Host 'Windows Firewall rule added for MTProto ports.' -ForegroundColor Green
    } else {
        Write-Host 'Firewall rule was not added because this terminal is not elevated.' -ForegroundColor Yellow
        Write-Host 'For phones/friends on the network, rerun START_SERVER.cmd as Administrator.' -ForegroundColor Yellow
    }

    docker compose -p mytelegram-local -f $ComposeFile -f $LocalComposeFile ps
} finally {
    Pop-Location
}

$state = Get-Content (Join-Path $Root '.mytelegram-local.json') -Raw | ConvertFrom-Json
Write-Host ''
Write-Host 'Server started.' -ForegroundColor Green
Write-Host ("Client server IP: {0}:20443" -f $state.serverIp)
Write-Host 'Login verification code: 22222'
Write-Host 'MongoDB UI/CLI endpoint: mongodb://127.0.0.1:27017'
Write-Host 'RabbitMQ admin: http://127.0.0.1:15672'
Write-Host 'MinIO console: http://127.0.0.1:9001'
