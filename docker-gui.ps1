Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$dockerExe = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
$procNames = @(
    "Docker Desktop",
    "com.docker.backend",
    "com.docker.build",
    "docker-agent",
    "docker-sandbox",
    "com.docker.cli"
)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$form = New-Object System.Windows.Forms.Form
$form.Text = "Docker Control (Win11)"
$form.Size = New-Object System.Drawing.Size(420, 360)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 18)
$statusLabel.Size = New-Object System.Drawing.Size(370, 28)
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($statusLabel)

$btnStop = New-Object System.Windows.Forms.Button
$btnStop.Location = New-Object System.Drawing.Point(20, 58)
$btnStop.Size = New-Object System.Drawing.Size(180, 58)
$btnStop.Text = "STOP Docker"
$btnStop.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnStop.BackColor = [System.Drawing.Color]::MistyRose
$form.Controls.Add($btnStop)

$btnStart = New-Object System.Windows.Forms.Button
$btnStart.Location = New-Object System.Drawing.Point(210, 58)
$btnStart.Size = New-Object System.Drawing.Size(180, 58)
$btnStart.Text = "START Docker"
$btnStart.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnStart.BackColor = [System.Drawing.Color]::Honeydew
$form.Controls.Add($btnStart)

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Location = New-Object System.Drawing.Point(20, 130)
$logBox.Size = New-Object System.Drawing.Size(370, 180)
$logBox.Multiline = $true
$logBox.ReadOnly = $true
$logBox.ScrollBars = "Vertical"
$logBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$logBox.BackColor = [System.Drawing.Color]::Black
$logBox.ForeColor = [System.Drawing.Color]::LightGreen
$form.Controls.Add($logBox)

function Write-Log {
    param([string]$msg)
    $ts = Get-Date -Format "HH:mm:ss"
    $logBox.AppendText("[$ts] $msg`r`n")
    $logBox.SelectionStart = $logBox.Text.Length
    $logBox.ScrollToCaret()
}

function Update-Status {
    $running = Get-Process "Docker Desktop" -ErrorAction SilentlyContinue
    if ($running) {
        $statusLabel.Text = "Status: RUNNING"
        $statusLabel.ForeColor = [System.Drawing.Color]::ForestGreen
    } else {
        $statusLabel.Text = "Status: STOPPED"
        $statusLabel.ForeColor = [System.Drawing.Color]::Gray
    }
}

function Invoke-Stop {
    $btnStop.Enabled = $false
    $btnStart.Enabled = $false
    try {
        Write-Log "Stopping Docker processes..."
        foreach ($p in $procNames) {
            $procs = Get-Process $p -ErrorAction SilentlyContinue
            if ($procs) {
                $procs | Stop-Process -Force -ErrorAction SilentlyContinue
                Write-Log "  killed: $p"
            }
        }
        Write-Log "wsl --shutdown ..."
        & wsl --shutdown 2>&1 | ForEach-Object { Write-Log "  $_" }
        Write-Log "Stop complete."
    } catch {
        Write-Log "ERROR: $_"
    } finally {
        Update-Status
        $btnStop.Enabled = $true
        $btnStart.Enabled = $true
    }
}

function Invoke-Start {
    if (-not (Test-Path $dockerExe)) {
        Write-Log "ERROR: not found -> $dockerExe"
        return
    }
    Write-Log "Starting Docker Desktop..."
    Start-Process -FilePath $dockerExe
    Write-Log "Launch sent. (engine takes ~10-30s)"
    Update-Status
}

$btnStop.Add_Click({ Invoke-Stop })
$btnStart.Add_Click({ Invoke-Start })

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 2000
$timer.Add_Tick({ Update-Status })
$timer.Start()

Update-Status
Write-Log "Docker Control ready. admin=$isAdmin"
if (-not $isAdmin) {
    Write-Log "WARN: not elevated. STOP may fail to kill some processes."
}

[void]$form.ShowDialog()
$timer.Stop()
