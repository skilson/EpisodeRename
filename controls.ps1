
Function Get-Folder($initialDirectory = "") {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if ($foldername.ShowDialog() -eq "OK") {
        $folder += $foldername.SelectedPath
    }

    return $folder 
}

Function Invoke-RemoveTail {
    param(
        [Parameter(Mandatory)]
        [string]$fileName,
        [Parameter(Mandatory)]
        [string]$tailStart
    )
    if ($fileName.Contains($tailStart)) {
        $fileName = "$($fileName.Substring(0,$fileName.IndexOf($tailStart)))$([io.path]::GetExtension($fileName))"
    }
    return $fileName
}


Function Invoke-RemoveHead {
    param(
        [Parameter(Mandatory)]
        [string]$fileName,
        [Parameter(Mandatory)]
        [string]$headString
    )
    if ($fileName.Contains($headString)) {
        $fileName = Invoke-Replace -fileName $fileName -findString $headString -replaceString "" 
    }
    return $fileName
}

Function Invoke-AddHead {
    param(
        [Parameter(Mandatory)]
        [string]$fileName,
        [Parameter(Mandatory)]
        [string]$headString
    )
    return $headString+$fileName
}

Function Invoke-Replace {
    param(
        [Parameter(Mandatory)]
        [string]$fileName,
        [Parameter(Mandatory)]
        [string]$findString,
        [string]$replaceString
    )
    if ($fileName.Contains($findString)) {
        $fileName = $fileName.Replace($findString, $replaceString)
    }
    return $fileName
}

Function Update-FileName {
    param(
        [Parameter(Mandatory)]
        [string]$fileName,
        [PSCustomObject]$editSelections
    )
    $selections = $editSelections.PSObject.Members | Where-Object Membertype -like 'NoteProperty'    
    foreach ($selection in $selections) {
        switch ($selection.Name) {
            name_spaces {
                if ($selection.Value) {
                    $fileName = Invoke-Replace -fileName $fileName -findString "  " -replaceString " "
                } continue
            }
            name_tail {  
                if ($selection.Value) {
                    $fileName = Invoke-RemoveTail -fileName $fileName -tailStart $selection.Value
                } continue
            }
            name_head {
                if ($selection.Value) {
                    $fileName = Invoke-RemoveHead -fileName $fileName -headString $selection.Value
                } continue
            }
            name_prefix {
                if ($selection.Value) {
                    $fileName = Invoke-AddHead -fileName $fileName -headString $selection.Value
                } continue
            }
            name_find {
                if ($selection.Value) {
                    $fileName = Invoke-Replace -fileName $fileName -findString $selection.Value -replaceString $editSelections.name_replace
                } continue
            }
        }
    }

    


    return $fileName
}