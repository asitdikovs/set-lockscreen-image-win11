# --- CONFIGURATION ---
# This path must exactly match the path used in the Remediation script.
$ExpectedImagePath = "C:\Windows\Web\Screen\CompanyLockScreen.jpg"
# --- END CONFIGURATION ---

try {
    Write-Host "Starting PersonalizationCSP Lock Screen detection."

    # --- Check 1: Does the image file exist? ---
    if (-not (Test-Path $ExpectedImagePath)) {
        Write-Host "Detection FAILED: Image file not found at '$ExpectedImagePath'."
        Exit 1 # Problem detected, run remediation.
    }
    Write-Host "Detection PASSED: Image file exists."

    # --- Check 2: Are the registry values correct? ---
    $cspRegPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP"

    # Get all values at once for efficiency.
    $regKey = Get-Item -Path $cspRegPath -ErrorAction SilentlyContinue
    if (-not $regKey) {
        Write-Host "Detection FAILED: Registry path '$cspRegPath' does not exist."
        Exit 1
    }

    $regStatus = $regKey.GetValue("LockScreenImageStatus", $null)
    $regUrl = $regKey.GetValue("LockScreenImageUrl", $null)
    $regPath = $regKey.GetValue("LockScreenImagePath", $null)

    # Check Status
    if (($null -eq $regStatus) -or ($regStatus -ne 1)) {
        Write-Host "Detection FAILED: LockScreenImageStatus is missing or not 1."
        Exit 1
    }
    Write-Host "Detection PASSED: LockScreenImageStatus is correct."

    # Check ImageUrl
    if (($null -eq $regUrl) -or ($regUrl -ne $ExpectedImagePath)) {
        Write-Host "Detection FAILED: LockScreenImageUrl is missing or incorrect."
        Exit 1
    }
    Write-Host "Detection PASSED: LockScreenImageUrl is correct."
    
    # Check ImagePath
    if (($null -eq $regPath) -or ($regPath -ne $ExpectedImagePath)) {
        Write-Host "Detection FAILED: LockScreenImagePath is missing or incorrect."
        Exit 1
    }
    Write-Host "Detection PASSED: LockScreenImagePath is correct."

    # --- If all checks pass ---
    Write-Host "COMPLIANT: Lock screen is configured correctly via PersonalizationCSP."
    Exit 0 # No problems detected.
}
catch {
    Write-Host "ERROR: An unexpected error occurred during detection. Error: $_"
    # Assume the worst and run remediation just in case.
    Exit 1
}