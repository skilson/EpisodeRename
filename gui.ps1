. .\controls.ps1

Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase, system.windows.forms

[xml]$xaml = Get-Content .\form.xaml
$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    Set-Variable -Name ($_.Name) -Value $window.FindName($_.Name) -Scope Global
}

Function Confirm-Location {
    if ($location.Text) {
        return $true
    }

    return $false
}

Function Get-EditSelections {
    return  [PSCustomObject]@{ 
        name_tail       = $name_tail.Text
        name_head       = $name_head.Text
        name_prefix     = $name_prefix.Text
        name_find       = $name_find.Text
        name_replace    = $name_replace.Text
        name_spaces     = $name_spaces.IsChecked

        episode_fix     = $episode_fix.IsChecked
        episode_start   = $episode_start.Text
        episode_length  = $episode_length.Text
        episode_change  = $episode_change.Text
    }
}

Function Step-ThroughFiles($operation) {
    if (Confirm-Location) {
        $preview_box.Text = ""
        $content = Get-ChildItem -LiteralPath $location.Text -File
        if ($content.Length -eq 0) {
            $preview_box.Text = "No files found"
        }
        else {
            foreach ($file in $content) {
                $fileName = $file.Name
                switch ($operation) {
                    0 { break }
                    1 { $fileName = Update-FileName -fileName $fileName -editSelections $(Get-EditSelections) }
                    2 {
                        $fileName = Update-FileName -fileName $fileName -editSelections $(Get-EditSelections)
                        Rename-Item -LiteralPath $file.FullName -NewName $fileName
                    }
                }
                $preview_box.AppendText("$fileName`n")
            }
        }
    }
    else {
        $preview_box.Text = "Missing Location"
    }
}

Function Clear-Input{
    $name_tail.Text = ""
    $name_head.Text = ""
    $name_prefix.Text = ""
    $name_find.Text = ""
    $name_replace.Text = ""
    $name_spaces.IsChecked = $false

    $episode_fix.IsChecked = $false
    $episode_change.Text = ""
    $episode_length.Text = ""
    $episode_start.Text = ""
}

Function Build-ButtonClicks {
    $search.Add_Click(
        {        
            if (Confirm-Location) {
                $location.Text = Get-Folder -initialDirectory $location.Text
            }
            else {
                $location.Text = Get-Folder
            }
        }
    ) 
    $preview_current.Add_Click(
        {
            Step-ThroughFiles -operation 0
        }
    )
    $preview_changes.Add_Click(
        {
            Step-ThroughFiles -operation 1
        }
    )
    $commit.Add_Click(
        {
            Step-ThroughFiles -operation 2
        }
    )
    $reset.Add_Click(
        {
            Clear-Input
        }
    )
}

Function Invoke-Interface {
    Build-ButtonClicks
    [void]$window.ShowDialog()
}
