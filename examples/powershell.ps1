# IP geolocation from PowerShell — no dependencies.
#
#   pwsh powershell.ps1 [ip-or-domain]

param([string]$Target = "")

$Base = "https://bgp.cx"

# Look up an IP or domain; an empty target queries the caller's own address.
function Get-IpInfo {
    param([string]$Host_, [string]$Lang = "en")

    $url = if ([string]::IsNullOrEmpty($Host_)) {
        "$Base/api/ip?lang=$Lang"
    } else {
        "$Base/api/ip/$([uri]::EscapeDataString($Host_))?lang=$Lang"
    }

    $headers = @{}
    if ($env:IPLOOKUP_KEY) { $headers["Authorization"] = "Bearer $($env:IPLOOKUP_KEY)" }

    Invoke-RestMethod -Uri $url -Headers $headers -TimeoutSec 10
}

# A single field as plain text.
function Get-IpField {
    param([string]$Host_, [string]$Name)
    (Invoke-WebRequest -Uri "$Base/ip/$([uri]::EscapeDataString($Host_))/$Name" -TimeoutSec 10).Content.Trim()
}

Write-Host "=== Your own IP ==="
(Invoke-WebRequest -Uri $Base -TimeoutSec 10).Content.Trim()

Write-Host ""
Write-Host "=== Lookup: $(if ($Target) { $Target } else { 'your IP' }) ==="
$info = Get-IpInfo $Target
$info | ConvertTo-Json -Depth 5

if ($info.ip) {
    Write-Host ""
    Write-Host "country : $(Get-IpField $info.ip 'country')"
    Write-Host "location: $(Get-IpField $info.ip 'location')"
    Write-Host "coords  : $(Get-IpField $info.ip 'loc')"
}

if ($info.asn) {
    Write-Host ""
    $asnInfo = Invoke-RestMethod -Uri "$Base/api/asn/$($info.asn)?family=4&limit=5" -TimeoutSec 10
    Write-Host "AS$($asnInfo.asn) $($asnInfo.name) — $($asnInfo.ipv4_prefixes) IPv4 prefixes"
    $asnInfo.prefixes | Select-Object -First 5 | ForEach-Object { Write-Host "  $_" }
}
