# Load the System.Drawing assembly
Add-Type -AssemblyName System.Drawing
$skinspath = $RmAPI.VariableStr('Skinspath')
# Set the folder path to save the extracted icons and the Rainmeter main file
$iconFolderPath = "$skinspath\YourStart\@Resources\AllApps\Icons"  # Change this path to your desired folder
$mainFilePath = "$skinspath\YourStart\@Resources\AllApps\All Apps.nek"  # Change this path to your desired Rainmeter .ini file location
$jsonFilePath = "$skinspath\YourStart\@Resources\AllApps\apps.json"   # Path for the JSON file

# Create the icon folder if it doesn't exist
if (-not (Test-Path $iconFolderPath)) {
    New-Item -ItemType Directory -Path $iconFolderPath | Out-Null
}

# Create the Rainmeter skin directory if it doesn't exist
$skinDirectory = [System.IO.Path]::GetDirectoryName($mainFilePath)
if (-not (Test-Path $skinDirectory)) {
    New-Item -ItemType Directory -Path $skinDirectory | Out-Null
}

# Paths to the Start Menu folders
$startMenuPaths = @(
    "$env:ProgramData\Microsoft\Windows\Start Menu\Programs",
    "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
)

# Function to extract icons from executable files
function Extract-IconFromExe {
    param (
        [string]$exePath,
        [string]$savePath
    )

    try {
        # Load the icon from the executable file
        $icon = [System.Drawing.Icon]::ExtractAssociatedIcon($exePath)

        if ($icon -ne $null) {
            $icon.ToBitmap().Save($savePath)
            return $true  # Successfully saved the icon
        } else {
            return $false  # No icon found
        }
    } catch {
        return $false  # Error during extraction
    }
}

# Function to list unique executable shortcuts in the Start Menu folders and extract icons
function Get-StartMenuApps {
    $apps = @()

    foreach ($path in $startMenuPaths) {
        if (Test-Path $path) {
            $shortcuts = Get-ChildItem -Path $path -Recurse -Filter *.lnk
            foreach ($shortcut in $shortcuts) {
                $shell = New-Object -ComObject WScript.Shell
                $shortcutObject = $shell.CreateShortcut($shortcut.FullName)
                $shortcutPath = $shortcutObject.TargetPath
                
                # Only include .exe files, and exclude uninstallers or msiexec-related entries
                if ($shortcutPath -match "\.exe$" -and 
                    $shortcutPath -notmatch "uninstall" -and 
                    $shortcutPath -notmatch "msiexec\.exe") {

                    # Check if the executable path exists before attempting to extract the icon
                    if (Test-Path $shortcutPath) {
                        $iconFileName = "$($shortcut.BaseName).ico"
                        $iconPath = Join-Path -Path $iconFolderPath -ChildPath $iconFileName

                        # Extract the icon using the executable path
                        if (Extract-IconFromExe -exePath $shortcutPath -savePath $iconPath) {
                            $apps += [PSCustomObject]@{
                                AppName = $shortcut.BaseName
                                IconPath = $iconPath
                                ExecutablePath = $shortcutPath
                            }
                        } else {
                            Write-Host "No icon found for: $shortcutPath"
                        }
                    } else {
                        Write-Host "Executable not found: $shortcutPath"
                    }
                }
            }
        }
    }

    # Return unique entries by AppName
    return $apps | Sort-Object AppName | Select-Object -Unique AppName, IconPath, ExecutablePath
}

# Get and display the Start Menu apps (with unique executable entries, excluding uninstallers)
$startMenuApps = Get-StartMenuApps

# Check if any applications were found
if ($startMenuApps.Count -eq 0) {
    Write-Host "No applications found in the Start Menu."
    return
}

# Create the Rainmeter skin .ini file
$iniContent = ""

# Create the mainJson variable to store app information for the JSON file
$mainJson = @()

# Create meters for each application
foreach ($app in $startMenuApps) {
    $meterName = "App" + ($startMenuApps.IndexOf($app) + 1)  # Unique meter name

    # Add Rainmeter content
    $iniContent += @"
[AppName_BackGround_$meterName]
Meter=Shape
MeterStyle=All_Apps_BackGround
LeftMouseDownAction=[""$($app.ExecutablePath)""]

[AppName_Icon_$meterName]
Meter=Image
ImageName=$($app.IconPath)
MeterStyle=All_Apps_Icons

[AppName_String_$meterName]
Meter=String
Text=$($app.AppName)
MeterStyle=All_Apps_Text

"@  # This ensures there's a blank line after each meter section

    # Add app details to the mainJson object
    $mainJson += [PSCustomObject]@{
        AppName = $app.AppName
        IconPath = $app.IconPath
        ExecutablePath = $app.ExecutablePath
    }
}

# Write the .ini file
Set-Content -Path $mainFilePath -Value $iniContent -Force

# Convert the app data to JSON format and write to a file
$mainJsonContent = $mainJson | ConvertTo-Json -Depth 2
Set-Content -Path $jsonFilePath -Value $mainJsonContent -Force

Write-Host "Icons have been extracted to: $iconFolderPath"
Write-Host "Rainmeter configuration file created at: $mainFilePath"
Write-Host "JSON file created at: $jsonFilePath"

function rmbang ($bang) {
    $RmAPI.Bang($bang)
}

Start-Sleep -Seconds 2
rmbang "[!ShowMeter Done_Text][!UpdateMeter *][!Redraw]"

Start-Sleep -Seconds 2
rmbang "[!ActivateConfig  YourStart\Main][!DeactivateConfig]"