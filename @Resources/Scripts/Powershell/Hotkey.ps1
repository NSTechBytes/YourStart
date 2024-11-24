Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Form Setup
$form = New-Object System.Windows.Forms.Form
$form.Text = "Rainmeter Hotkey Configuration"
$form.Size = New-Object System.Drawing.Size(380, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false

# Create Gradient Background as an Image
$gradientImage = New-Object System.Drawing.Bitmap(380, 300)
$graphics = [System.Drawing.Graphics]::FromImage($gradientImage)
$gradientBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    [System.Drawing.Rectangle]::FromLTRB(0, 0, $form.Width, $form.Height),
    [System.Drawing.Color]::LightSteelBlue, [System.Drawing.Color]::WhiteSmoke,
    [System.Drawing.Drawing2D.LinearGradientMode]::Vertical
)
$graphics.FillRectangle($gradientBrush, 0, 0, 380, 300)
$gradientBrush.Dispose()
$graphics.Dispose()
$form.BackgroundImage = $gradientImage
$form.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch

# Title Label
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Configure Your Hotkey"
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForeColor = [System.Drawing.Color]::Navy
$titleLabel.AutoSize = $true
$titleLabel.Location = New-Object System.Drawing.Point(95, 20)
$form.Controls.Add($titleLabel)

# Subtitle Label
$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Text = "Choose modifiers and main key"
$subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Italic)
$subtitleLabel.ForeColor = [System.Drawing.Color]::Gray
$subtitleLabel.AutoSize = $true
$subtitleLabel.Location = New-Object System.Drawing.Point(120, 50)
$form.Controls.Add($subtitleLabel)

# Tooltip
$tooltip = New-Object System.Windows.Forms.ToolTip
$tooltip.InitialDelay = 500
$tooltip.SetToolTip($subtitleLabel, "Selecting a modifier key is recommended.")

# Label for Modifier Keys
$modifierLabel = New-Object System.Windows.Forms.Label
$modifierLabel.Text = "Modifier Keys:"
$modifierLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$modifierLabel.Size = New-Object System.Drawing.Size(250, 20)
$modifierLabel.Location = New-Object System.Drawing.Point(20, 90)
$form.Controls.Add($modifierLabel)

# Dropdowns for Modifier Keys
$dropdownFont = New-Object System.Drawing.Font("Segoe UI", 9)

$modifierDropdown1 = New-Object System.Windows.Forms.ComboBox
$modifierDropdown1.Location = New-Object System.Drawing.Point(20, 120)
$modifierDropdown1.Size = New-Object System.Drawing.Size(120, 25)
$modifierDropdown1.Font = $dropdownFont
$modifierDropdown1.Items.AddRange(@("None", "Ctrl", "Alt", "Shift", "LWin"))
$modifierDropdown1.SelectedIndex = 0
$form.Controls.Add($modifierDropdown1)

$modifierDropdown2 = New-Object System.Windows.Forms.ComboBox
$modifierDropdown2.Location = New-Object System.Drawing.Point(160, 120)
$modifierDropdown2.Size = New-Object System.Drawing.Size(120, 25)
$modifierDropdown2.Font = $dropdownFont
$modifierDropdown2.Items.AddRange(@("None", "Ctrl", "Alt", "Shift", "LWin"))
$modifierDropdown2.SelectedIndex = 0
$form.Controls.Add($modifierDropdown2)

# Main Key Label
$mainKeyLabel = New-Object System.Windows.Forms.Label
$mainKeyLabel.Text = "Main Key:"
$mainKeyLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$mainKeyLabel.Size = New-Object System.Drawing.Size(250, 20)
$mainKeyLabel.Location = New-Object System.Drawing.Point(20, 160)
$form.Controls.Add($mainKeyLabel)

# Textbox for Main Key
$mainKeyTextbox = New-Object System.Windows.Forms.TextBox
$mainKeyTextbox.Size = New-Object System.Drawing.Size(120, 25)
$mainKeyTextbox.Location = New-Object System.Drawing.Point(20, 190)
$mainKeyTextbox.Font = $dropdownFont
$tooltip.SetToolTip($mainKeyTextbox, "Enter a single character key (e.g., T).")
$form.Controls.Add($mainKeyTextbox)

# Save Button
$saveButton = New-Object System.Windows.Forms.Button
$saveButton.Text = "Save Hotkey"
$saveButton.Location = New-Object System.Drawing.Point(20, 230)
$saveButton.Size = New-Object System.Drawing.Size(300, 35)
$saveButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$saveButton.BackColor = [System.Drawing.Color]::Navy
$saveButton.ForeColor = [System.Drawing.Color]::White
$saveButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$saveButton.FlatAppearance.BorderSize = 0

# Save Button Click Event
$saveButton.Add_Click({
    # Get selected modifiers and main key
    $modifiers = @($modifierDropdown1.Text, $modifierDropdown2.Text) | Where-Object { $_ -ne "None" }
    $mainKey = $mainKeyTextbox.Text.Trim()

    # Check for at least one modifier
    if ($modifiers.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("It is recommended to select at least one modifier key (e.g., Ctrl, Alt, Shift, or Win).", "Recommendation", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    # Validate Main Key
    if (-not $mainKey) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a main key.", "Input Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    # Construct Hotkey
    $hotkey = ($modifiers + $mainKey) -join " "

    # Rainmeter Skin Path
    $skinPath = "C:\Users\Nasir Shahbaz\Documents\Rainmeter\Skins\YourStart\@Resources\HotKey.nek"

    # Write to the Rainmeter variable
    if (Test-Path $skinPath) {
        $content = Get-Content -Path $skinPath
        if ($content -match "Hotkey=.*") {
            $content = $content -replace "Hotkey=.*", "Hotkey=$hotkey"
        } else {
            $content += "`nHotkey=$hotkey"
        }
        $content | Set-Content -Path $skinPath

        [System.Windows.Forms.MessageBox]::Show("Hotkey saved successfully!", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } else {
        [System.Windows.Forms.MessageBox]::Show("Rainmeter skin file not found.", "File Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})

$form.Controls.Add($saveButton)

# Show the form
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
