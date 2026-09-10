#Requires -RunAsAdministrator
# Select a port, then select which printer on that port to remove

Write-Host "`n=== Installed Printers ===" -ForegroundColor Cyan
$printers = Get-Printer | Select-Object Name, PortName | Sort-Object PortName
$printers | Format-Table -AutoSize

# Step 1: select a port
$ports = $printers | Select-Object -ExpandProperty PortName -Unique | Sort-Object
Write-Host "=== Available Ports ===" -ForegroundColor Cyan
for ($i = 0; $i -lt $ports.Count; $i++) {
    Write-Host "[$i] $($ports[$i])"
}

$portSel = Read-Host "`nEnter the number of the port"
if ($portSel -notmatch '^\d+$' -or [int]$portSel -ge $ports.Count) {
    Write-Host "Invalid selection." -ForegroundColor Red
    exit
}
$targetPort = $ports[[int]$portSel]

# Step 2: select printer(s) on that port
$onPort = $printers | Where-Object { $_.PortName -eq $targetPort }
Write-Host "`nPrinters on port '$targetPort':" -ForegroundColor Cyan
for ($i = 0; $i -lt $onPort.Count; $i++) {
    Write-Host "[$i] $($onPort[$i].Name)"
}
Write-Host "[A] Remove ALL printers on this port"

$printerSel = Read-Host "`nEnter printer number (or A for all)"
if ($printerSel -ieq 'A') {
    $toRemove = $onPort
} elseif ($printerSel -match '^\d+$' -and [int]$printerSel -lt $onPort.Count) {
    $toRemove = @($onPort[[int]$printerSel])
} else {
    Write-Host "Invalid selection." -ForegroundColor Red
    exit
}

Write-Host "`nThe following printer(s) will be REMOVED:" -ForegroundColor Yellow
$toRemove | Format-Table -AutoSize

$confirm = Read-Host "Type YES to confirm"
if ($confirm -eq 'YES') {
    foreach ($p in $toRemove) {
        Write-Host "Removing printer: $($p.Name) ..." -ForegroundColor Red
        Remove-Printer -Name $p.Name -ErrorAction Stop
    }
    Write-Host "`nDone." -ForegroundColor Green
} else {
    Write-Host "Cancelled." -ForegroundColor Yellow
}