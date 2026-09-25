param(
    [Parameter(Mandatory=$false)]
    [string]$ServerIp
)

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$EnvFile = Join-Path $Root 'mytelegram-dev\docker\compose\.env'
$HeaderFile = Join-Path $Root 'TMessagesProj\jni\tgnet\LocalServerConfig.h'
$StateFile = Join-Path $Root '.mytelegram-local.json'
$EnvTemplate = Join-Path $Root 'mytelegram-dev\docker\compose\.env.example'

if (-not (Test-Path $EnvFile)) {
    if (-not (Test-Path $EnvTemplate)) {
        throw 'Missing .env.example. Restore the complete project before starting.'
    }
    Copy-Item $EnvTemplate $EnvFile
}

function Get-DefaultIPv4 {
    $configs = Get-NetIPConfiguration -ErrorAction SilentlyContinue | Where-Object {
        $_.IPv4DefaultGateway -and $_.IPv4Address -and $_.NetAdapter.Status -eq 'Up'
    }
    foreach ($cfg in $configs) {
        foreach ($addr in $cfg.IPv4Address) {
            if ($addr.IPAddress -and $addr.IPAddress -notmatch '^(127\.|169\.254\.)') {
                return $addr.IPAddress
            }
        }
    }

    $fallback = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object {
        $_.IPAddress -notmatch '^(127\.|169\.254\.)' -and $_.PrefixOrigin -ne 'WellKnown'
    } | Select-Object -First 1
    if ($fallback) { return $fallback.IPAddress }
    throw 'Could not auto-detect an IPv4 address. Run: SETUP_LOCAL.cmd 192.168.x.x'
}

if ([string]::IsNullOrWhiteSpace($ServerIp)) {
    if (Test-Path $StateFile) {
        try {
            $previous = Get-Content $StateFile -Raw | ConvertFrom-Json
            $candidate = [string]$previous.serverIp
            $stillAssigned = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -eq $candidate } | Select-Object -First 1
            if ($stillAssigned) { $ServerIp = $candidate }
        } catch {}
    }
    if ([string]::IsNullOrWhiteSpace($ServerIp)) {
        $ServerIp = Get-DefaultIPv4
    }
}

$parsed = $null
if (-not [System.Net.IPAddress]::TryParse($ServerIp, [ref]$parsed) -or $parsed.AddressFamily -ne [System.Net.Sockets.AddressFamily]::InterNetwork) {
    throw "Invalid IPv4 address: $ServerIp"
}

Write-Host "Configuring local server IP: $ServerIp" -ForegroundColor Cyan

# Patch the single client-side endpoint source of truth.
$header = Get-Content $HeaderFile -Raw
$header = [regex]::Replace($header, 'kServerIpv4\s*=\s*"[^"]+";', "kServerIpv4 = `"$ServerIp`";")
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($HeaderFile, $header, $Utf8NoBom)

# Patch all DC addresses the server advertises back to clients.
$env = Get-Content $EnvFile -Raw
for ($i = 0; $i -le 3; $i++) {
    $pattern = "(?m)^App__DcOptions__${i}__IpAddress=.*$"
    $replacement = "App__DcOptions__${i}__IpAddress=$ServerIp"
    $env = [regex]::Replace($env, $pattern, $replacement)
}

# Keep the server and the bundled OSS source on the exact same layer/version.
$env = [regex]::Replace($env, '(?m)^MyTelegramVersion=.*$', 'MyTelegramVersion=0.40.224.502')

# Generate local secrets once if the archive still contains its stock defaults.
function New-HexSecret([int]$Bytes = 24) {
    $buf = New-Object byte[] $Bytes
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($buf) } finally { $rng.Dispose() }
    return ([BitConverter]::ToString($buf)).Replace('-', '').ToLowerInvariant()
}
function New-Base64Secret([int]$Bytes = 32) {
    $buf = New-Object byte[] $Bytes
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($buf) } finally { $rng.Dispose() }
    return [Convert]::ToBase64String($buf)
}

if ($env -match '(?m)^RabbitMQ__Connections__Default__Password=GENERATE_ON_FIRST_RUN$') {
    $env = [regex]::Replace($env, '(?m)^RabbitMQ__Connections__Default__Password=.*$', 'RabbitMQ__Connections__Default__Password=' + (New-HexSecret 24))
}
if ($env -match '(?m)^Minio__SecretKey=GENERATE_ON_FIRST_RUN$') {
    $env = [regex]::Replace($env, '(?m)^Minio__SecretKey=.*$', 'Minio__SecretKey=' + (New-HexSecret 24))
}
if ($env -match '(?m)^App__AccessHashSecretKey=GENERATE_ON_FIRST_RUN$') {
    $env = [regex]::Replace($env, '(?m)^App__AccessHashSecretKey=.*$', 'App__AccessHashSecretKey=' + (New-HexSecret 32))
}
if ($env -match '(?m)^App__EncryptionConfig__MessageKeys__0__Key=GENERATE_ON_FIRST_RUN$') {
    $env = [regex]::Replace($env, '(?m)^App__EncryptionConfig__MessageKeys__0__Key=.*$', 'App__EncryptionConfig__MessageKeys__0__Key=' + (New-Base64Secret 32))
}
if ($env -match '(?m)^App__EncryptionConfig__IndexKeys__0__Key=GENERATE_ON_FIRST_RUN$') {
    $env = [regex]::Replace($env, '(?m)^App__EncryptionConfig__IndexKeys__0__Key=.*$', 'App__EncryptionConfig__IndexKeys__0__Key=' + (New-Base64Secret 32))
}
if ($env -match '(?m)^RabbitMQ__ErlangCookie=GENERATE_ON_FIRST_RUN$') {
    $env = [regex]::Replace($env, '(?m)^RabbitMQ__ErlangCookie=.*$', 'RabbitMQ__ErlangCookie=' + (New-HexSecret 24))
}

[System.IO.File]::WriteAllText($EnvFile, $env, $Utf8NoBom)

$state = [ordered]@{
    serverIp = $ServerIp
    configuredAt = (Get-Date).ToString('o')
    serverVersion = '0.40.224.502'
    apiLayer = 224
    fixedVerificationCode = '22222'
}
[System.IO.File]::WriteAllText($StateFile, ($state | ConvertTo-Json), $Utf8NoBom)

Write-Host 'Client and server configuration updated.' -ForegroundColor Green
Write-Host "Server IP: $ServerIp"
Write-Host 'MTProto bootstrap port: 20443'
Write-Host 'API layer: 224'
