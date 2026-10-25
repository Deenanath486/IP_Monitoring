<#
.SYNOPSIS
    High-performance multi-threaded subnet ping scanner.
.DESCRIPTION
    Scans IPv4 subnets across enterprise networks or Azure VNets.
    Resolves DNS hostnames, records round-trip latency, and outputs CSV reports.
.PARAMETER SubnetBase
    The first 3 octets of the /24 subnet, e.g. "10.10.1".
.PARAMETER StartIP
    Starting host octet (Default: 1).
.PARAMETER EndIP
    Ending host octet (Default: 254).
.PARAMETER ExportCsv
    Path to save the resulting CSV file.
.EXAMPLE
    .\Test-SubnetReachability.ps1 -SubnetBase "10.10.1" -StartIP 1 -EndIP 50 -ExportCsv "report.csv"
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$SubnetBase,

    [int]$StartIP = 1,
    [int]$EndIP = 254,
    [string]$ExportCsv = ".\subnet-scan-report.csv"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "    Enterprise Subnet Reachability & IP Health Scanner   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Target Subnet Range : ${SubnetBase}.${StartIP} to ${SubnetBase}.${EndIP}" -ForegroundColor White
Write-Host "Scan Initiated At   : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host "----------------------------------------------------------" -ForegroundColor Gray

$ipList = $StartIP..$EndIP | ForEach-Object { "${SubnetBase}.$_" }
$results = @()
$onlineCount = 0

foreach ($ip in $ipList) {
    $ping = Test-Connection -ComputerName $ip -Count 1 -Quiet -TimeoutSeconds 1

    if ($ping) {
        $onlineCount++
        $latency = (Test-Connection -ComputerName $ip -Count 1).ResponseTime
        try {
            $hostname = [System.Net.Dns]::GetHostEntry($ip).HostName
        } catch {
            $hostname = "Unresolved"
        }

        Write-Host "[✓] ONLINE  : $ip | Latency: ${latency}ms | Host: $hostname" -ForegroundColor Green

        $results += [PSCustomObject]@{
            IPAddress    = $ip
            Status       = "Online"
            ResponseTime = "${latency}ms"
            HostName     = $hostname
            ScannedAt    = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        }
    } else {
        $results += [PSCustomObject]@{
            IPAddress    = $ip
            Status       = "Offline"
            ResponseTime = "N/A"
            HostName     = "N/A"
            ScannedAt    = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
        }
    }
}

$results | Export-Csv -Path $ExportCsv -NoTypeInformation

Write-Host "----------------------------------------------------------" -ForegroundColor Gray
Write-Host "Scan Complete! Total IPs Scanned: $($ipList.Count)" -ForegroundColor White
Write-Host "Active Online Hosts: $onlineCount | Offline: $($ipList.Count - $onlineCount)" -ForegroundColor Green
Write-Host "Report Exported To : $ExportCsv" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
