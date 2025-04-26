# update_policy_banner_rtfd.sh

---

### MacJediWizard Consulting, Inc.
**Copyright (c) 2025 MacJediWizard Consulting, Inc.**  
All rights reserved.  
Created by: **William Grzybowski**

---

### Description:
- This script updates the macOS Policy Banner located in `/Library/Security` to use an `.rtfd` bundle, compatible with macOS 15 and newer.
- The new `.rtfd` banner must be pre-staged into `/tmp/new_policy_banner.rtfd` before script execution.
- The script will:
  - Create temporary working directories in `/tmp`
  - Backup any existing `PolicyBanner.rtfd`
  - Remove the old policy banner safely
  - Install the new `.rtfd` policy banner
  - Apply correct permissions (`755`) and ownership (`root:wheel`) recursively
  - Force a Preboot volume update to sync FileVault Preboot Login screens
  - Capture and log the full Preboot update output
  - Add timestamps for Preboot operation start and end
  - Log all actions, warnings, errors, and debug info into `/var/log/policy_banner_update.log`
  - Optionally enable internal `DEBUG_MODE` for verbose logging

---

### Notes:
- Must be run as **root** (required for filesystem and Preboot changes).
- Designed for use inside **Jamf Pro** policies using **Custom Triggers** or **postinstall scripts**.
- Assumes that the `.rtfd` bundle is already deployed to `/tmp` prior to running.
- Fully supports macOS 15.x+.
- Logs are clean and structured for both Jamf Console and system auditing.

---

### License:
This project is licensed under the **MIT License**.  
See the [LICENSE](LICENSE) file for full details.

---

### Usage Examples:
| Context | Command |
|:--------|:--------|
| **Jamf Pro Policy (Custom Trigger)** | Triggers the script after deploying new `.rtfd` |
| **Terminal (Command Line)** | `sudo ./update_policy_banner_rtfd.sh` |

---

### Requirements:
- macOS 15 or higher
- Root privileges
- Jamf Pro (optional for deployment)
- `.rtfd` banner must exist at `/tmp/new_policy_banner.rtfd`

---

### Version:
`v1.3.0`

---

> End of Script Documentation: **update_policy_banner_rtfd.sh**  
> MacJediWizard Consulting, Inc. © 2025. All rights reserved.