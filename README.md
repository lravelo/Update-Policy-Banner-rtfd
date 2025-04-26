# update_policy_banner_rtfd.sh

---

### MacJediWizard Consulting, Inc.
**Copyright (c) 2025 MacJediWizard Consulting, Inc.**  
All rights reserved.  
Created by: **William Grzybowski**

---

### Description:
- This script updates the macOS policy banner located in `/Library/Security` to use an `.rtfd` bundle, compatible with macOS 15 and newer.
- The new `.rtfd` banner must be pre-staged into `/tmp/new_policy_banner.rtfd` before script execution.
- The script will:
  - Create temporary working directories
  - Backup any existing `PolicyBanner.rtfd` found in `/Library/Security`
  - Safely remove the old policy banner
  - Install the new `.rtfd` policy banner
  - Apply correct permissions (755) and ownership (`root:wheel`) recursively
  - Verify basic FileVault policy banner configuration
  - Log all actions, warnings, errors, and debug info to `/var/log/policy_banner_update.log`

---

### Notes:
- Must be run as **root**.
- Internal `DEBUG_MODE` can be enabled for detailed logs.
- Designed for use with **Jamf Pro** policies using **Custom Triggers** or **postinstall scripts**.
- Assumes the `.rtfd` bundle is **already** deployed to `/tmp` before running the script.

---

### Footer:
> End of Script: **update_policy_banner_rtfd.sh**  
> MacJediWizard Consulting, Inc. © 2025. All rights reserved.

---