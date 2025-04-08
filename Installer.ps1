$installerPath = "C:\Users\WDAGUtilityAccount\Desktop\Sandbox"
$exeInstallers = Get-ChildItem -Path $installerPath -Filter *.exe -File -Recurse
$msiInstallers = Get-ChildItem -Path $installerPath -Filter *.msi -File -Recurse

# Combine two installer lists
$installers = @()
$installers += $exeInstallers
$installers += $msiInstallers

if ($installers.Count -eq 0) {
    Write-Host "❌ No installers found in $installerPath" -ForegroundColor Red
    exit
}

Write-Host "🔍 Found $($installers.Count) installer(s):" -ForegroundColor Cyan
$installers | ForEach-Object { Write-Host "• $($_.Name)" }

Write-Host "`n▶ Installation is starting..." -ForegroundColor Yellow

foreach ($installer in $installers) {
    $ext = $installer.Extension.ToLower()
    $name = $installer.Name
    $fullPath = $installer.FullName

    Write-Host "`n➡ Installing $name..." -ForegroundColor White

    try {
        if ($ext -eq ".msi") {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$fullPath`" /passive /norestart" -Wait -NoNewWindow
        } elseif ($ext -eq ".exe") {
            # Trying the most common silent parameter /S
            Start-Process -FilePath $fullPath -ArgumentList "/S" -Wait -NoNewWindow
        } else {
            Write-Host "⚠ Unknown format: $ext" -ForegroundColor DarkYellow
            continue
        }

        Write-Host "✅ Successfully installed: $name" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Installation failed: $name" -ForegroundColor Red
        Write-Host $_.Exception.Message
    }
}

Write-Host "`n🏁 Installation completed." -ForegroundColor Cyan
