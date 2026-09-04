# ==========================================
# Circuit LAN IP Monitoring
# ==========================================

$CsvFile = ".\circuits.csv"

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "       CIRCUIT IP MONITORING STARTED        " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Read CSV file
$Circuits = Import-Csv -Path $CsvFile

$Results = foreach ($Circuit in $Circuits) {

    $CircuitID = $Circuit.'Circuit ID'
    $IP        = $Circuit.'LAN IP'

    Write-Host "Checking: $CircuitID | $IP" -ForegroundColor Yellow

    # Ping IP
    $Ping = Test-Connection `
        -ComputerName $IP `
        -Count 2 `
        -ErrorAction SilentlyContinue

    if ($Ping) {

        $Status = "UP"

        $ResponseTime = ($Ping | Measure-Object ResponseTime -Average).Average
        $ResponseTime = [math]::Round($ResponseTime, 2)

        Write-Host "   STATUS : UP" -ForegroundColor Green
        Write-Host "   PING   : $ResponseTime ms" -ForegroundColor Green
    }
    else {

        $Status = "DOWN"
        $ResponseTime = "-"

        Write-Host "   STATUS : DOWN" -ForegroundColor Red
    }

    [PSCustomObject]@{
        'Circuit ID' = $CircuitID
        'LAN IP'     = $IP
        'Status'     = $Status
        'Response'   = $ResponseTime
        'Checked At' = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }

    Write-Host ""
}

# Display final result
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "                 FINAL RESULT               " -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$Results | Format-Table -AutoSize

# Export result
$Results | Export-Csv `
    -Path ".\circuit-status.csv" `
    -NoTypeInformation

Write-Host ""
Write-Host "Result saved to: circuit-status.csv" -ForegroundColor Green