<#
.SYNOPSIS
    Sends automated network incident notifications to Microsoft Teams or Slack channels.
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$WebhookUrl,

    [Parameter(Mandatory=$true)]
    [string]$Title,

    [Parameter(Mandatory=$true)]
    [string]$Message,

    [ValidateSet("Info", "Warning", "Critical")]
    [string]$Severity = "Warning"
)

$colorMap = @{
    "Info"     = "0078D4"
    "Warning"  = "FFA500"
    "Critical" = "FF0000"
}

$themeColor = $colorMap[$Severity]

$body = @{
    "@type"      = "MessageCard"
    "@context"   = "http://schema.org/extensions"
    "themeColor" = $themeColor
    "title"      = "[$Severity] Network Monitoring Alert: $Title"
    "text"       = $Message
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $body -ContentType 'application/json'
    Write-Host "[✓] Alert notification dispatched to Webhook successfully." -ForegroundColor Green
} catch {
    Write-Host "[!] Failed to dispatch notification: $($_.Exception.Message)" -ForegroundColor Red
}
