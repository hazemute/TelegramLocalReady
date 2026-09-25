$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$ComposeDir = Join-Path $Root 'mytelegram-dev\docker\compose'
Push-Location $ComposeDir
try {
    docker compose -p mytelegram-local -f docker-compose.yml -f docker-compose.local.yml logs -f --tail 200
} finally { Pop-Location }
