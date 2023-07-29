# Show hidden files in Windows Explorer
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name Hidden -Value 1 | Out-Null

# Show file extensions in Windows Explorer
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name HideFileExt -Value 0 | Out-Null

# Disable enhanced mouse precision https://www.howtogeek.com/321763/what-is-enhance-pointer-precision-in-windows/
Set-ItemProperty -Path 'HKCU:\Control Panel\Mouse' -Name MouseSpeed -Value 0 | Out-Null

# Enable mouse keys https://support.microsoft.com/en-us/windows/use-mouse-keys-to-move-the-mouse-pointer-9e0c72c8-b882-7918-8e7b-391fd62adf33
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\MouseKeys' -Name Flags -Value 63 | Out-Null

# Ensure time zone is correct
Set-TimeZone -Id "GMT Standard Time"

# Set Edge as the default browser
# If ((Get-ItemProperty HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice -Name ProgId).ProgId -ne "MSEdgeHTM") {
#     Set -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "DefaultAssociationsConfiguration" -Value "\\NetworkShare\EDGE\defaultapplication.XML" -PropertyType String -Force | Out-Null
# }