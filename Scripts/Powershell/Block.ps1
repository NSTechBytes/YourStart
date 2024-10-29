function rmbang ($bang) {
    $RmAPI.Bang($bang)
}
function Get-StartMenuApps {
    $apps = @()
    $startMenuPaths = @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
    )

    foreach ($path in $startMenuPaths) {
        if (Test-Path $path) {
            $shortcuts = Get-ChildItem -Path $path -Recurse -Filter *.lnk
            foreach ($shortcut in $shortcuts) {
                $shell = New-Object -ComObject WScript.Shell
                $shortcutObject = $shell.CreateShortcut($shortcut.FullName)
                $shortcutPath = $shortcutObject.TargetPath
                
                # Only include .exe files, excluding uninstallers or msiexec-related entries
                if ($shortcutPath -match "\.exe$" -and 
                    $shortcutPath -notmatch "uninstall" -and 
                    $shortcutPath -notmatch "msiexec\.exe") {

                    if (Test-Path $shortcutPath) {
                        $apps += [PSCustomObject]@{
                            AppName = $shortcut.BaseName
                            ExecutablePath = $shortcutPath
                        }
                    }
                }
            }
        }
    }
    return $apps | Sort-Object AppName | Select-Object -Unique AppName, ExecutablePath
}

$skinspath = $RmAPI.VariableStr('Skinspath')
# Path to the existing JSON file with app information
$jsonFilePath = "$skinspath\YourStart\@Resources\AllApps\apps.json" 

# Load the existing apps from the JSON file
if (Test-Path $jsonFilePath) {
    $existingApps = Get-Content -Path $jsonFilePath | ConvertFrom-Json
} else {
    Write-Host "JSON file not found: $jsonFilePath"
    return
}

# Get the list of currently installed programs from the Start Menu
$startMenuApps = Get-StartMenuApps

# Create a list to store names of existing apps for easy comparison
$existingAppNames = $existingApps.AppName

# Check for new installed programs not in the JSON file
$newApps = @()
foreach ($app in $startMenuApps) {
    if (-not ($existingAppNames -contains $app.AppName)) {
        $newApps += $app.AppName
    }
}

# Check for programs in JSON but not in the Start Menu
$missingApps = @()
foreach ($app in $existingApps) {
    if (-not ($startMenuApps.AppName -contains $app.AppName)) {
        $missingApps += $app.AppName
    }
}

# Output the results
if ($newApps.Count -gt 0) {
    Write-Host "Newly installed programs not listed in JSON:"
    $newApps | ForEach-Object { Write-Host "- $_" }
    rmbang "[!DeactivateConfig YourStart\Main][!ActivateConfig YourStart\ChangeAction]"
} else {
    Write-Host "No new programs found that are not in the JSON file."
}

if ($missingApps.Count -gt 0) {
    Write-Host "Programs listed in JSON but not found in the Start Menu:"
    $missingApps | ForEach-Object { Write-Host "- $_" }
    rmbang "[!DeactivateConfig YourStart\Main][!ActivateConfig YourStart\ChangeAction]"
} else {
    Write-Host "All programs in the JSON file are present in the Start Menu."
}







