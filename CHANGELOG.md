# Changelog

All notable changes to this project will be documented in this file.

---

## [1.2.0] - 2025-04-26
### Changed
- Captured full `diskutil apfs updatePreboot /` output into custom log file `/var/log/policy_banner_update.log`.
- Filtered preboot update output for Jamf console logs to prevent log truncation issues.
- Added macOS version detection to skip `/private/var/db/.PolicyBanner` check on macOS 14+ (Sonoma and newer).

---

## [1.1.0] - 2025-04-26
### Changed
- Updated `validate_filevault_banner` to run `diskutil apfs updatePreboot /` before checking for preboot banner status.
- Eliminated false preboot warnings by syncing preboot volume immediately after policy banner replacement.

---

## [1.0.0] - 2025-04-26
### Added
- Initial creation of `update_policy_banner_rtfd.sh`.
- Support for replacing PolicyBanner.rtfd in `/Library/Security/` for macOS 15+.
- Implemented backup, remove, and replace logic with correct permissions and ownership.
- Built internal logging system to `/var/log/policy_banner_update.log`.
- Designed for Jamf Pro modular deployment via custom triggers or postinstall actions.