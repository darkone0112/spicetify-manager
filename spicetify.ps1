[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Menu {
    Clear-Host
    Write-Host "=======================================" -ForegroundColor Blue
    Write-Host "         Spicetify Manager             " -ForegroundColor Blue
    Write-Host "=======================================" -ForegroundColor Blue
    Write-Host " 1. Install Spicetify"
    Write-Host " 2. Update Spicetify"
    Write-Host " 3. Enable Daily Auto-Update"
    Write-Host " 0. Exit"
    Write-Host "=======================================" -ForegroundColor Blue
}

function Install-Spicetify {
    Write-Host "`n[*] Installing Spicetify..." -ForegroundColor Yellow
    Invoke-Expression (Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/spicetify/cli/main/install.ps1").Content
}

function Update-Spicetify {
    Write-Host "`n[*] Updating Spicetify..." -ForegroundColor Green
    Start-Process powershell.exe -WindowStyle Normal -ArgumentList '-NoExit','-Command','spicetify update'
}

function Enable-AutoUpdate {
    Write-Host "`n[*] Setting up auto-update task..." -ForegroundColor Cyan
    $TaskName = 'SpicetifyAutoUpdate'

    # Remove any existing task so we can recreate cleanly
    Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue |
        Unregister-ScheduledTask -Confirm:$false -ErrorAction SilentlyContinue

    $arg      = '-WindowStyle Hidden -c "spicetify update"'
    $action   = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arg
    $trigger  = New-ScheduledTaskTrigger -Daily -At 9:30
    $principal= New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive

    Register-ScheduledTask -TaskName $TaskName -Action $action `
        -Trigger $trigger -Principal $principal -Force | Out-Null

    Write-Host '[✓] Auto-update enabled daily at 10 AM.' -ForegroundColor Green
}

# If the user scope is still Restricted, open it up enough to run
if ((Get-ExecutionPolicy -Scope CurrentUser) -eq 'Restricted') {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
}

do {
    Show-Menu
    $choice = Read-Host "`nSelect an option"

    switch ($choice) {
        '1' { Install-Spicetify }
        '2' { Update-Spicetify }
        '3' { Enable-AutoUpdate }
        '0' { Write-Host "`nExiting..." -ForegroundColor Gray }
        default { Write-Host '[!] Invalid option. Try again.' -ForegroundColor Red }
    }

    if ($choice -ne '0') {
        Write-Host "`nPress Enter to return to the menu..."
        [void][Console]::ReadLine()
    }
} while ($choice -ne '0')
