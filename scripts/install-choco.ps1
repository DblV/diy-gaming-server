[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
(New-Object System.Net.WebClient).DownloadFile("https://community.chocolatey.org/install.ps1", "$ENV:UserProfile\Downloads\install-chocolatey.ps1")
& "$ENV:UserProfile\Downloads\install-chocolatey.ps1"
