$skinspath = $RmAPI.VariableStr('Skinspath')
$file = "$skinspath\YourStart\@Resources\Shortcuts\Shortcuts.nek" 
$imageDirectory = "$skinspath\YourStart\@Resources\Shortcuts\IconCache\"
$mainConfig = "YourStart\Main"
$EditConfig = "YourStart\ShortcutEditor"

function debug {
    param(
        [Parameter()]
        [string]
        $message
    )

    $RmAPI.Bang("[!Log `"`"`"YourStart: " + $message + "`"`"`" Debug]")
}



# ---------------------------------------------------------------------------- #
#                                   Functions                                  #
# ---------------------------------------------------------------------------- #

function Get-IniContent ($filePath) {
    $ini = [ordered]@{}
    if (![System.IO.File]::Exists($filePath)) {
        throw "$filePath invalid"
    }
    # $section = ';ItIsNotAFuckingSection;'
    # $ini.Add($section, [ordered]@{})

    foreach ($line in [System.IO.File]::ReadLines($filePath)) {
        if ($line -match "^\s*\[(.+?)\]\s*$") {
            $section = $matches[1]
            $secDup = 1
            while ($ini.Keys -contains $section) {
                $section = $section + '||ps' + $secDup
            }
            $ini.Add($section, [ordered]@{})
        }
        elseif ($line -match "^\s*;.*$") {
            $notSectionCount = 0
            while ($ini[$section].Keys -contains ';NotSection' + $notSectionCount) {
                $notSectionCount++
            }
            $ini[$section][';NotSection' + $notSectionCount] = $matches[1]
        }
        elseif ($line -match "^\s*(.+?)\s*=\s*(.+?)$") {
            $key, $value = $matches[1..2]
            $ini[$section][$key] = $value
        }
        else {
            $notSectionCount = 0
            while ($ini[$section].Keys -contains ';NotSection' + $notSectionCount) {
                $notSectionCount++
            }
            $ini[$section][';NotSection' + $notSectionCount] = $line
        }
    }

    return $ini
}

function Set-IniContent($ini, $filePath) {
    $str = @()

    foreach ($section in $ini.GetEnumerator()) {
        if ($section -ne ';ItIsNotAFuckingSection;') {
            $str += "[" + ($section.Key -replace '\|\|ps\d+$', '') + "]"
        }
        foreach ($keyvaluepair in $section.Value.GetEnumerator()) {
            if ($keyvaluepair.Key -match "^;NotSection\d+$") {
                $str += $keyvaluepair.Value
            }
            else {
                $str += $keyvaluepair.Key + "=" + $keyvaluepair.Value
            }
        }
    }

    $finalStr = $str -join [System.Environment]::NewLine

    $finalStr | Out-File -filePath $filePath -Force -Encoding unicode
}

# ---------------------------------------------------------------------------- #
#                                    Actions                                   #
# ---------------------------------------------------------------------------- #


function ShortcutChangeTo {
    param (
    [int]$index,
    $selectedFile,
    $selectedFileName,
    $returnedImageName
    )
    debug "Changing $index shortcut to $selectedFile which is $selectedFileName with image $returnedImageName"

    $Ini = Get-IniContent $file
    # ---------------------------- change cache values --------------------------- #
    $RmAPI.Bang("[!SetOption Shortcut$index.Image ImageName `"`"`"$imageDirectory$returnedImageName`"`"`" $EditConfig]")
    $RmAPI.Bang("[!SetOption Shortcut$index.String Text `"`"`"$selectedFileName`"`"`" $EditConfig]")
    $RmAPI.Bang("[!UpdateMeter * $mainConfig][!HideMeterGroup Overlay $mainConfig][!Redraw $EditConfig]")
    # ------------------------------- write values ------------------------------- #
    $Ini["Shortcut$index.Image"]['LeftMouseUpAction'] = "[`"$selectedFile`"]"
    $Ini["Shortcut$index.Image"]['ImageName'] = "`"$imageDirectory$returnedImageName.png`""
    Set-IniContent $Ini $file
	$RmAPI.Bang("[!Refresh $mainConfig]")
	$RmAPI.Bang("[!Refresh $EditConfig]")
}

function ShortcutImageChangeTo {
    param (
    [int]$index,
    $selectedFile
    )
    debug "Changing $index image to $selectedFile"
    
    $Ini = Get-IniContent $file
    # ---------------------------- change cache values --------------------------- #
    $RmAPI.Bang("[!SetOption Shortcut$index.Image ImageName `"`"`"$selectedFile`"`"`" $EditConfig]")
    $RmAPI.Bang("[!UpdateMeter * $mainConfig][!HideMeterGroup Overlay $mainConfig][!Redraw $EditConfig]")
    # ------------------------------- write values ------------------------------- #
    $Ini["Shortcut$index.Image"]['ImageName'] = "`"$selectedFile`""
    Set-IniContent $Ini $file
	$RmAPI.Bang("[!Refresh $mainConfig]")
	$RmAPI.Bang("[!Refresh $EditConfig]")
}

function ShortcutSwapBetween {
    param (
        [int]$i1,
        [int]$i2
    )
    debug "$i1 $i2"

    $Ini = Get-IniContent $file
    # --------------------------- swap values in cache --------------------------- #
    $RmAPI.Bang("[!SetOption Shortcut$i1.Image ImageName $($Ini["Shortcut$i2.Image"]['ImageName']) $EditConfig ]")
    $RmAPI.Bang("[!SetOption Shortcut$i2.Image ImageName $($Ini["Shortcut$i1.Image"]['ImageName']) $EditConfig ]")
	$RmAPI.Bang("[!SetOption Shortcut$i1.Image ImageName $($Ini["Shortcut$i2.Image"]['ImageName']) $MainConfig ]")
    $RmAPI.Bang("[!SetOption Shortcut$i2.Image ImageName $($Ini["Shortcut$i1.Image"]['ImageName']) $MainConfig ]")
    $RmAPI.Bang("[!UpdateMeter * $mainConfig][!Redraw $mainConfig]")
	$RmAPI.Bang("[!UpdateMeter * $EditConfig][!Redraw $EditConfig]")
    # --------------------------- swap and write values -------------------------- #
    
    $Ini["Shortcut$i2.Image"]['ImageName'], $Ini["Shortcut$i1.Image"]['ImageName'] = $Ini["Shortcut$i1.Image"]['ImageName'], $Ini["Shortcut$i2.Image"]['ImageName']
	$Ini["Shortcut$i2.Image"]['LeftMouseUpAction'], $Ini["Shortcut$i1.Image"]['LeftMouseUpAction'] = $Ini["Shortcut$i1.Image"]['LeftMouseUpAction'], $Ini["Shortcut$i2.Image"]['LeftMouseUpAction']
    
    Set-IniContent $Ini $file
	
}

function ShortcutNew {
    param (
    [int]$index,
    $selectedFile,
    $selectedFileName,
    $returnedImageName,
    [int]$ti,
    [int]$ri
	)
    debug "Adding $index shortcut to $selectedFile which is $selectedFileName with image $returnedImageName"

    $r = $ti % $ri

    If ($r -eq 0) {
        $shapestyle = 'Shortcut.Shape:S | Shortcut.Shape.NewLine:S'
    } else {
        $shapestyle = 'Image:B | Shortcut.Shape:S'
    }

    Add-Content $file @"

[Shortcut$index.Image]
Meter=Image
MeterStyle=Image:B | Shortcut.Shape:S
ImageName=`"$imageDirectory$returnedImageName.png`"
LeftMouseUpAction=[`"$selectedFile`"]
"@
    $Ini = Get-IniContent $file
    $Ini["Variables"]['TotalShortcuts_Count'] = $index
	$Ini["Variables"]['Icons'] = $index
	Set-IniContent $Ini $file
    $RmAPI.Bang("[!Refresh $mainConfig]")
	$RmAPI.Bang("[!Refresh $EditConfig]")
	
}

function ShortcutRemove {
    param (
    [int]$index,
    [int]$ti,
    [int]$ri
    )
    debug "Removing shortut $index where current total is $ti with $ri shortcuts in each row"
    $Ini = Get-IniContent $file
    $StartingIndex = $index
    $NewTotal = $ti - 1
    debug "$StartingIndex $NewTotal"
    # ------------------------------ Collpase values ----------------------------- #
    for ($i = $StartingIndex; $i -le $NewTotal; $i++) {
        $Ini["Shortcut$i.Image"]['ImageName']   = $Ini["Shortcut$($i + 1).Image"]['ImageName']
		$Ini["Shortcut$i.Image"]['LeftMouseUpAction']   = $Ini["Shortcut$($i + 1).Image"]['LeftMouseUpAction']
	
    }
    # ----------------------------- remove last value ---------------------------- #
    $Ini.Remove("Shortcut$ti.Image")
    $Ini["Variables"]['TotalShortcuts_Count'] = $ti - 1
	$Ini["Variables"]['icons'] = $ti - 1
    # ------------------------------ Set and refresh ----------------------------- #
    Set-IniContent $Ini $file
    $RmAPI.Bang("[!Refresh $mainConfig]")
	$RmAPI.Bang("[!Refresh $EditConfig]")

    if ($($ti - 1) -ge $index) {
        $RmAPI.Bang("[!Refresh $mainConfig]")
	    $RmAPI.Bang("[!Refresh $EditConfig]")
    }
}

function rmbang ($bang) {
    $RmAPI.Bang($bang)
}

rmbang "[!SetOption Shortcut1.Image X `"(20*#Scale#)`"][!SetOption Shortcut1.Image Y `"(60*#Scale#)r`"][!SetOption Shortcut6.Image X `"(20*#Scale#)`"][!SetOption Shortcut6.Image Y `"(80*#Scale#)r`"][!SetOption Shortcut11.Image X `"(20*#Scale#)`"][!SetOption Shortcut11.Image Y `"(80*#Scale#)r`"][!SetOption Shortcut16.Image X `"(20*#Scale#)`"][!SetOption Shortcut16.Image Y `"(80*#Scale#)r`"][!SetOption Shortcut21.Image X `"(20*#Scale#)`"][!SetOption Shortcut21.Image Y `"(80*#Scale#)r`"][!SetOption Shortcut26.Image X `"(20*#Scale#)`"][!SetOption Shortcut26.Image Y `"(80*#Scale#)r`"][!SetOption Shortcut31.Image X `"(20*#Scale#)`"][!SetOption Shortcut31.Image Y `"(80*#Scale#)r`"][!SetOption Shortcut36.Image X `"(20*#Scale#)`"][!SetOption Shortcut36.Image Y `"(80*#Scale#)r`"][!SetOption Shortcut41.Image X `"(20*#Scale#)`"][!SetOption Shortcut41.Image Y `"(80*#Scale#)r`"][!SetOption Shortcut46.Image X `"(20*#Scale#)`"][!SetOption Shortcut46.Image Y `"(80*#Scale#)r`"][!SetOption Shortcut51.Image X `"(20*#Scale#)`"][!SetOption Shortcut51.Image Y `"(80*#Scale#)r`"][!UpdateMeter *][!Redraw]"