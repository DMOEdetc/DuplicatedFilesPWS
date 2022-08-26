$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [System.Text.UTF8Encoding]::new()

Function Get-Folder($initialDirectory="")

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Ordner auswählen, in dem nach Duplikaten gesucht werden soll."
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

$Path = Get-Folder

$group = Get-ChildItem -Path $Path -File -Recurse -ErrorAction Ignore |
    Where-Object Length -gt 0 |
    Group-Object -Property Length -AsHashTable 
	

$candidates = foreach($pile in $group.Values)
{
	$data = [System.Collections.ArrayList]$pile
	
    if ($data.Count -gt 1)
    {
		$data.RemoveAt($data.Count-1)
		$data
    }
}
write-host "`n"
write-host "Duplikate:"
Write-Output $candidates
write-host "`n"
write-host "`n"

$title    = 'Duplikate können jetzt in Unterordner "Duplikate" verschoben werden. Dabei werden alle doppelten Dateien verschoben. Eine Datei verbleibt immer im ursprünglichen Ordner.'
$question = 'Sollen die Duplikate jetzt verschoben werden?'
$choices  = '&Ja', '&Nein'

$decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)

write-host "`n"
write-host "`n"

if ($decision -eq 0) {
    Write-Host 'beginne mit dem verschieben...'
	
	
	$sub_folder = "$Path\Duplikate"
	If(!(test-path -PathType container $sub_folder))
	{
		  New-Item -ItemType Directory -Path $sub_folder
	}

	foreach($ele in $candidates)
	{
		Move-Item -Path $Path\$ele -Destination $Path\Duplikate\$ele
	}
	
} else {
    Write-Host 'abgebrochen'
}

write-host "`n"
write-host "`n"
pause

