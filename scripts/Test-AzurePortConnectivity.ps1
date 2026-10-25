<#
.SYNOPSIS
    Tests TCP Port reachability and NSG / Firewall boundary rules.
.DESCRIPTION
    Validates network security and connectivity to critical enterprise ports
    such as SSH (22), HTTP (80), HTTPS (443), RDP (3389), PostgreSQL (5432),
    MSSQL (1433), Kubernetes API (6443).
.PARAMETER TargetHost
    Hostname or IP address to test.
.PARAMETER Ports
    Array of port numbers to check. Defaults to standard enterprise ports.
.EXAMPLE
    .\Test-AzurePortConnectivity.ps1 -TargetHost "10.10.1.4" -Ports 22, 443, 5432
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$TargetHost,

    [int[]]$Ports = @(22, 80, 443, 1433, 3389, 5432, 6443),
    [int]$TimeoutMs = 2000
)

$serviceMap = @{
    22   = "SSH (Linux)"
    80   = "HTTP (Web)"
    443  = "HTTPS (Secure Web / TLS)"
    1433 = "MSSQL Server"
    3389 = "RDP (Windows Remote Desktop)"
    5432 = "PostgreSQL Flexible Server"
    6443 = "Kubernetes API Server"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "     Enterprise TCP Port Reachability & NSG Auditor       " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Target Endpoint : $TargetHost" -ForegroundColor White
Write-Host "Timestamp       : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host "----------------------------------------------------------" -ForegroundColor Gray

$results = @()

foreach ($port in $Ports) {
    $serviceName = if ($serviceMap.ContainsKey($port)) { $serviceMap[$port] } else { "Custom Port" }
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $tcpClient = New-Object System.Net.Sockets.TcpClient

    try {
        $asyncResult = $tcpClient.BeginConnect($TargetHost, $port, $null, $null)
        $waitHandle = $asyncResult.AsyncWaitHandle.WaitOne($TimeoutMs, $false)

        if ($waitHandle -and $tcpClient.Connected) {
            $tcpClient.EndConnect($asyncResult)
            $stopwatch.Stop()
            $latency = $stopwatch.ElapsedMilliseconds

            Write-Host "[✓] OPEN    : Port $port ($serviceName) | Latency: ${latency}ms" -ForegroundColor Green
            $results += [PSCustomObject]@{
                Host        = $TargetHost
                Port        = $port
                ServiceName = $serviceName
                Status      = "Open / Reachable"
                Latency     = "${latency}ms"
            }
        } else {
            $stopwatch.Stop()
            Write-Host "[-] CLOSED  : Port $port ($serviceName) - Connection timed out / blocked by NSG" -ForegroundColor Red
            $results += [PSCustomObject]@{
                Host        = $TargetHost
                Port        = $port
                ServiceName = $serviceName
                Status      = "Closed / Filtered"
                Latency     = "Timeout"
            }
        }
    } catch {
        Write-Host "[!] ERROR   : Port $port ($serviceName) - $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        $tcpClient.Close()
    }
}

Write-Host "==========================================================" -ForegroundColor Cyan
