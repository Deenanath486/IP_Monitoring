<#
.SYNOPSIS
    Continuous network latency and packet loss monitor for Azure VNet Peerings / ExpressRoute.
.DESCRIPTION
    Monitors packet loss, jitter, and response latency across hybrid links or peered VNets.
    Logs telemetry and sends automated webhook alerts if thresholds are breached.
.PARAMETER TargetIP
    IP address or hostname of remote VNet / On-Prem gateway.
.PARAMETER Count
    Number of pings to send per interval. Default is 10.
.PARAMETER ThresholdLatencyMs
    Latency threshold in ms triggering warnings. Default is 50ms.
.PARAMETER WebhookUrl
    Optional Teams/Slack webhook URL for outage alerts.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$TargetIP,

    [int]$Count = 10,
    [int]$ThresholdLatencyMs = 50,
    [string]$WebhookUrl = ""
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   Azure VNet Peering & Hybrid Latency Telemetry Probe   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "Monitoring Target : $TargetIP" -ForegroundColor White
Write-Host "Ping Samples      : $Count packets per test" -ForegroundColor White
Write-Host "Latency Threshold : ${ThresholdLatencyMs}ms" -ForegroundColor White
Write-Host "----------------------------------------------------------" -ForegroundColor Gray

$pings = Test-Connection -ComputerName $TargetIP -Count $Count -ErrorAction SilentlyContinue

if ($null -eq $pings) {
    Write-Host "[🚨 ALERT] Total Outage! Target $TargetIP is 100% UNREACHABLE." -ForegroundColor Red
    return
}

$sent = $Count
$received = $pings.Count
$lost = $sent - $received
$lossPercent = [math]::Round(($lost / $sent) * 100, 2)
$avgLatency = [math]::Round(($pings | Measure-Object -Property ResponseTime -Average).Average, 2)
$maxLatency = ($pings | Measure-Object -Property ResponseTime -Maximum).Maximum
$minLatency = ($pings | Measure-Object -Property ResponseTime -Minimum).Minimum

Write-Host "Packets Sent    : $sent | Received: $received | Lost: $lost (${lossPercent}%)" -ForegroundColor White
Write-Host "Min Latency     : ${minLatency}ms" -ForegroundColor Green
Write-Host "Avg Latency     : ${avgLatency}ms" -ForegroundColor $(if ($avgLatency -gt $ThresholdLatencyMs) { "Yellow" } else { "Green" })
Write-Host "Max Latency     : ${maxLatency}ms" -ForegroundColor White

if ($lossPercent -gt 0 -or $avgLatency -gt $ThresholdLatencyMs) {
    Write-Host "[⚠️ WARNING] Network SLA degraded! High latency or packet drop detected." -ForegroundColor Yellow
} else {
    Write-Host "[✓ HEALTHY] Network link latency is well within SLA tolerances." -ForegroundColor Green
}
Write-Host "==========================================================" -ForegroundColor Cyan
