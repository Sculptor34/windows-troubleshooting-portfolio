#Requires -RunAsAdministrator
# Remove printers by selected port name

Write-Host "`n=== Installed Printers ===" -ForegroundColor Cyan
$printers = Get-Printer | Select-Object Name, PortName | Sort-Object PortName
$printers | Format-Table -AutoSize

# Show unique ports
$ports = $printers | Select-Object -ExpandProperty PortName -Unique | Sort-Object
Write-Host "=== Available Ports ===" -ForegroundColor Cyan
for ($i = 0; $i -lt $ports.Count; $i++) {
    Write-Host "[$i] $($ports[$i])"
}

$selection = Read-Host "`nEnter the number of the port you want to remove printers from"
if ($selection -match '^\d+$' -and [int]$selection -lt $ports.Count) {
    $targetPort = $ports[[int]$selection]

    $toRemove = $printers | Where-Object { $_.PortName -eq $targetPort }
    Write-Host "`nThe following printers will be REMOVED (port: $targetPort):" -ForegroundColor Yellow
    $toRemove | Format-Table -AutoSize

    $confirm = Read-Host "Type YES to confirm"
    if ($confirm -eq 'YES') {
        foreach ($p in $toRemove) {
            Write-Host "Removing printer: $($p.Name) ..." -ForegroundColor Red
            Remove-Printer -Name $p.Name -ErrorAction Stop
        }
        Write-Host "`nDone. Printers on port '$targetPort' have been removed." -ForegroundColor Green

        # Optional: also delete the port itself (uncomment if wanted)
        # Remove-PrinterPort -Name $targetPort -ErrorAction SilentlyContinue
    } else {
        Write-Host "Cancelled." -ForegroundColor Yellow
    }
} else {
    Write-Host "Invalid selection." -ForegroundColor Red
}