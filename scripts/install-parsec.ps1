[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

$Path = [Environment]::GetFolderPath("Desktop")
$ScriptWebArchive = "https://github.com/parsec-cloud/Parsec-Cloud-Preparation-Tool/archive/master.zip"
$LocalArchivePath = "$Path\Parsec-Cloud-Preparation-Tool"

Write-Output "Downloading Parsec installer scripts"

(New-Object System.Net.WebClient).DownloadFile($ScriptWebArchive, "$LocalArchivePath.zip")
Expand-Archive "$LocalArchivePath.zip" -DestinationPath $LocalArchivePath -Force

Write-Output "Setting up environment"

If ((Test-Path -Path $Path\ParsecTemp ) -eq $true) {
}
Else {
    New-Item -Path $Path\ParsecTemp -ItemType directory| Out-Null
}

# Move to source dir
Set-Location $Path\Parsec-Cloud-Preparation-Tool\Parsec-Cloud-Preparation-Tool-master
Unblock-File -Path .\*

Copy-Item .\* -Destination $Path\ParsecTemp\ -Force -Recurse | Out-Null
#lil nap
Start-Sleep -s 1

#Unblocking all script files
Get-ChildItem -Path $Path\ParsecTemp -Recurse | Unblock-File

Write-Output "Starting Parsec installer script"
Start-Process -FilePath "powershell" -Verb RunAs -Argument "-file $Path\ParsecTemp\PostInstall\PostInstall.ps1 -DontPromptPasswordUpdateGPU True" -Wait

Write-Output "Finished Parsec installer script"
