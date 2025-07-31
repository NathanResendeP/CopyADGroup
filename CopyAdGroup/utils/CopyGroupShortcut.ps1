# Script path
$scriptPath = "C:\CopyAdGroup\script\CopyADGroup.ps1"

# Shortcut path
$shortcutPath = "$env:PUBLIC\Desktop\Copy AD Groups.lnk"

# Custom icon path
$iconPath = "C:\CopyAdGroup\logo\Icon.ico"

# Create the shortcut
$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptPath`""
$shortcut.WorkingDirectory = "C:\CopyAdGroup"
$shortcut.WindowStyle = 7
$shortcut.Description = "Copy AD Group Memberships"
$shortcut.IconLocation = "$iconPath"
$shortcut.Save()