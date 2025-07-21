Function Write-Log {
    Param ([string]$LogMessage)
    $LogFile = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LockScreen_Image_Setup.log"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$Timestamp - $LogMessage" -ErrorAction SilentlyContinue
}

# --- CONFIGURATION ---
# IMPORTANT: Replace this URL with the direct public link to your image.
$ImageUrl = ""

# This path should match the one in the Detection script.
$DestinationFolder = "C:\Windows\Web\Screen"
$DestinationFile = "CompanyLockScreen.jpg"
$DestinationPath = Join-Path -Path $DestinationFolder -ChildPath $DestinationFile
# --- END CONFIGURATION ---

Write-Log "Starting PersonalizationCSP Lock Screen remediation."

# Step 1: Create destination folder if it doesn't exist
if (-not (Test-Path $DestinationFolder)) {
    try {
        New-Item -Path $DestinationFolder -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Write-Log "Created destination folder: $DestinationFolder"
    } catch {
        Write-Log "FATAL: Could not create destination folder. Error: $_"
        Exit 1
    }
}

# Step 2: Download the image file
try {
    Write-Log "Downloading image from '$ImageUrl' to '$DestinationPath'."
    # Using Invoke-RestMethod for robust downloads as SYSTEM
    Invoke-RestMethod -Uri $ImageUrl -OutFile $DestinationPath -ErrorAction Stop
    Write-Log "Image downloaded successfully."
}
catch {
    Write-Log "FATAL: Failed to download image. Check URL and network access. Error: $_"
    Exit 1
}

# Step 3: Create the registry keys
$cspRegPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
if (-not (Test-Path $cspRegPath)) {
    try {
        New-Item -Path $cspRegPath -Force -ErrorAction Stop | Out-Null
        Write-Log "Created registry path: $cspRegPath"
    } catch {
        Write-Log "FATAL: Could not create registry path. Error: $_"
        Exit 1
    }
}

try {
    # Set LockScreenImageStatus as DWORD with value 1
    Set-ItemProperty -Path $cspRegPath -Name "LockScreenImageStatus" -Value 1 -Type DWord -Force -ErrorAction Stop
    Write-Log "Successfully set 'LockScreenImageStatus' to 1."
    
    # Set LockScreenImageUrl as String with the file path
    Set-ItemProperty -Path $cspRegPath -Name "LockScreenImageUrl" -Value $DestinationPath -Type String -Force -ErrorAction Stop
    Write-Log "Successfully set 'LockScreenImageUrl' to '$DestinationPath'."
    
    # Set LockScreenImagePath as String with the file path
    Set-ItemProperty -Path $cspRegPath -Name "LockScreenImagePath" -Value $DestinationPath -Type String -Force -ErrorAction Stop
    Write-Log "Successfully set 'LockScreenImagePath' to '$DestinationPath'."

    Write-Log "All registry values set successfully."
}
catch {
    Write-Log "FATAL: Failed to set one or more registry values. Error: $_"
    Exit 1
}

Write-Log "Remediation finished successfully."
Exit 0