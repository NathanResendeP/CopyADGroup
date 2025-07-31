Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "Copy AD Groups"
$form.Size = New-Object System.Drawing.Size(500, 460)
$form.StartPosition = "CenterScreen"
$form.BackColor = 'White'

$font = New-Object System.Drawing.Font("Segoe UI", 10)

# Logo Image
$logoPath = "C:\CopyAdGroup\logo\logo.jpg"
if (Test-Path $logoPath) {
    $pictureBox = New-Object System.Windows.Forms.PictureBox
    $pictureBox.Location = New-Object System.Drawing.Point(150, 10)
    $pictureBox.Size = New-Object System.Drawing.Size(200, 50)
    $pictureBox.SizeMode = 'StretchImage'
    $pictureBox.Image = [System.Drawing.Image]::FromFile($logoPath)
    $form.Controls.Add($pictureBox)
}

# Source User Field
$labelSource = New-Object System.Windows.Forms.Label
$labelSource.Text = "Source User:"
$labelSource.Location = New-Object System.Drawing.Point(20, 70)
$labelSource.Size = New-Object System.Drawing.Size(200, 20)
$labelSource.Font = $font

$textSource = New-Object System.Windows.Forms.TextBox
$textSource.Location = New-Object System.Drawing.Point(20, 95)
$textSource.Size = New-Object System.Drawing.Size(440, 20)
$textSource.Font = $font

# Target User Field
$labelTarget = New-Object System.Windows.Forms.Label
$labelTarget.Text = "Target User:"
$labelTarget.Location = New-Object System.Drawing.Point(20, 130)
$labelTarget.Size = New-Object System.Drawing.Size(200, 20)
$labelTarget.Font = $font

$textTarget = New-Object System.Windows.Forms.TextBox
$textTarget.Location = New-Object System.Drawing.Point(20, 155)
$textTarget.Size = New-Object System.Drawing.Size(440, 20)
$textTarget.Font = $font

# Log / Progress Box
$textLog = New-Object System.Windows.Forms.TextBox
$textLog.Location = New-Object System.Drawing.Point(20, 190)
$textLog.Size = New-Object System.Drawing.Size(440, 160)
$textLog.Multiline = $true
$textLog.ScrollBars = "Vertical"
$textLog.Font = $font
$textLog.BackColor = "White"
$textLog.ReadOnly = $true

# Copy Groups Button
$buttonCopy = New-Object System.Windows.Forms.Button
$buttonCopy.Text = "Copy Groups"
$buttonCopy.Location = New-Object System.Drawing.Point(90, 370)
$buttonCopy.Size = New-Object System.Drawing.Size(140, 30)
$buttonCopy.Font = $font
$buttonCopy.BackColor = 'DarkSeaGreen'

# Clear Fields Button
$buttonClear = New-Object System.Windows.Forms.Button
$buttonClear.Text = "Clear"
$buttonClear.Location = New-Object System.Drawing.Point(260, 370)
$buttonClear.Size = New-Object System.Drawing.Size(140, 30)
$buttonClear.Font = $font
$buttonClear.BackColor = 'DarkSeaGreen'

# Error Message Box
function Show-Error($message) {
    [System.Windows.Forms.MessageBox]::Show($message, "Error", "OK", "Error")
}

# Copy Groups Button Click
$buttonCopy.Add_Click({
    $source = $textSource.Text.Trim()
    $target = $textTarget.Text.Trim()
    $executedBy = $env:USERNAME
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    if (-not $source -or -not $target) {
        Show-Error "Please fill in both user fields."
        return
    }

    if ($source -eq $target) {
        Show-Error "Source and target users must be different."
        return
    }

    $confirmation = [System.Windows.Forms.MessageBox]::Show(
        "Are you sure you want to copy groups from '$source' to '$target'?",
        "Confirmation",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($confirmation -ne "Yes") {
        return
    }

    try {
        Import-Module ActiveDirectory -ErrorAction Stop

        # Verifica se o usuário SOURCE existe
        try {
            $userSource = Get-ADUser $source -Properties MemberOf -ErrorAction Stop
        } catch {
            Show-Error "The user '$source' does not exist."
            return
        }

        # Verifica se o usuário TARGET existe
        try {
            $userTarget = Get-ADUser $target -Properties MemberOf -ErrorAction Stop
        } catch {
            Show-Error "The user '$target' does not exist."
            return
        }

        # Verifica se estão habilitados
        if (-not $userSource.Enabled) {
            Show-Error "The source user '$source' is disabled."
            return
        }

        if (-not $userTarget.Enabled) {
            Show-Error "The target user '$target' is disabled."
            return
        }

        # Busca grupos
        $sourceGroups = $userSource.MemberOf
        $targetGroups = ($userTarget.MemberOf | ForEach-Object { (Get-ADGroup $_).DistinguishedName })

        $addedGroups = @()
        $skippedGroups = @()
        $errorGroups = @()

        foreach ($groupDN in $sourceGroups) {
            $group = Get-ADGroup -Identity $groupDN
            $groupName = $group.Name

            if ($targetGroups -contains $group.DistinguishedName) {
                $msg = "User is already a member of the group: $groupName"
                $textLog.AppendText("$msg`r`n")
                $skippedGroups += "$groupName (already a member)"
            } else {
                try {
                    Add-ADGroupMember -Identity $group -Members $userTarget -ErrorAction Stop
                    $msg = "Added to group: $groupName"
                    $textLog.AppendText("$msg`r`n")
                    $addedGroups += $groupName
                } catch {
                    $msg = "Error adding to group: $groupName - $_"
                    $textLog.AppendText("$msg`r`n")
                    $errorGroups += "$groupName (error: $_)"
                }
            }
        }

        # Criação do diretório e gravação do log
        $logPath = "C:\CopyAdGroup\logs\log_copygroups.txt"
        $logDir = [System.IO.Path]::GetDirectoryName($logPath)
        if (-not (Test-Path $logDir)) {
            New-Item -Path $logDir -ItemType Directory | Out-Null
        }

        Add-Content -Path $logPath -Value @"
[$timestamp] Executed by: $executedBy
Source user: $source
Target user: $target
Groups added: $($addedGroups -join ", ")
Groups skipped: $($skippedGroups -join ", ")
Groups with errors: $($errorGroups -join ", ")
------------------------------------------------------------
"@

        [System.Windows.Forms.MessageBox]::Show("Process completed!", "Done", "OK", "Information")
    
    } catch {
        Show-Error "Unexpected error: $_"
    }
})

# Clear Button Click
$buttonClear.Add_Click({
    $textSource.Clear()
    $textTarget.Clear()
    $textLog.Clear()
})

# Add controls to form
$form.Controls.AddRange(@(
    $labelSource, $textSource,
    $labelTarget, $textTarget,
    $textLog, $buttonCopy, $buttonClear
))

[void]$form.ShowDialog()
