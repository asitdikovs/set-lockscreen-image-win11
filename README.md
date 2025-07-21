# set-lockscreen-image-win11

This repository provides PowerShell scripts to configure a custom lock screen image on Windows 10/11 devices using Microsoft Intune Remediation. The built-in OMA-URI setting `./Vendor/MSFT/Personalization/DesktopImageUrl` only works on Windows Enterprise editions, so these scripts provide a workaround for other editions.

## How it works

- [`Detection_lockscreen.ps1`](Detection_lockscreen.ps1) checks if the lock screen image and required registry values are set correctly.
- [`Remediation_set_lockscreen.ps1`](Remediation_set_lockscreen.ps1) downloads the image from a public URL, saves it locally, and sets the required registry values.

## Prerequisites

- The lock screen image must be hosted at a public URL (e.g., Azure Blob Storage, SharePoint, or other accessible storage).
- Update the `$ImageUrl` variable in [`Remediation_set_lockscreen.ps1`](Remediation_set_lockscreen.ps1) with the direct link to your image.

## Deployment Steps

1. **Upload your lock screen image to a public location.**

   - Ensure the image is accessible without authentication.

2. **Edit the remediation script:**

   - Open [`Remediation_set_lockscreen.ps1`](Remediation_set_lockscreen.ps1).
   - Set the `$ImageUrl` variable to your image's public URL:
     ```powershell
     $ImageUrl = "https://yourstorageaccount.blob.core.windows.net/images/CompanyLockScreen.jpg"
     ```

3. **Create an Intune Remediation:**

   - In the Microsoft Intune admin center, go to **Devices > Remediations**.
   - Click **Create script package**.
   - Upload [`Detection_lockscreen.ps1`](Detection_lockscreen.ps1) as the detection script.
   - Upload your edited [`Remediation_set_lockscreen.ps1`](Remediation_set_lockscreen.ps1) as the remediation script.
   - Assign the remediation to the desired device group(s).

4. **Configure remediation script settings as follows:**

   - **Run this script using the logged-on credentials:** No
   - **Enforce script signature check:** No
   - **Run script in 64-bit PowerShell:** Yes

5. **Monitor deployment:**
   - Check Intune reports to ensure the remediation runs successfully and devices receive the custom lock screen.

## Notes

- The scripts write logs to `C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\LockScreen_Image_Setup.log`.
- The lock screen image is saved to `C:\Windows\Web\Screen\CompanyLockScreen.jpg`.
- The registry keys are set under `HKLM:\Software\Microsoft\Windows\CurrentVersion\PersonalizationCSP`.

## Troubleshooting

- Ensure the image URL is accessible from the target devices.
- Review the log file for errors if the remediation fails.

---

**Scripts:**

- [Detection_lockscreen.ps1](Detection_lockscreen.ps1)
- [Remediation_set_lockscreen.ps1](Remediation_set_lockscreen.ps1)
