# Changelog

All notable changes to this project will be documented in this file.

---

## [1.3.0] - 2025-04-26
### Changed
- Added timestamp logging at start and end of `diskutil apfs updatePreboot /` process.
- Improved auditability by ensuring Preboot update operations have clear time window logs.
- Enhanced reliability of operational logging without modifying diskutil's internal output.

---

## [1.2.0] - 2025-04-26
### Changed
- Captured full `diskutil apfs updatePreboot /` output into the custom script log.
- Filtered key success or error messages for Jamf Pro console log to prevent log truncation.
- Added version detection to skip `/private/var/db/.PolicyBanner` check on macOS 14+ (Sonoma or newer).

---

## [1.1.0] - 2025-04-26
### Changed
- Updated `validate_filevault_banner` to run `diskutil apfs updatePreboot /` before checking for preboot banner.
- Eliminated false preboot warnings by forcing preboot volume sync immediately after banner replacement.

---

## [1.0.0] - 2025-04-26
### Added
- Initial creation of `update_policy_banner_rtfd.sh`.
- Support for replacing PolicyBanner.rtfd in `/Library/Security/` for macOS 15 and above.
- Implemented backup, remove, and replace logic with correct permissions and ownership.
- Built internal logging system outputting to `/var/log/policy_banner_update.log`.
- Designed for Jamf Pro modular deployment via custom triggers or postinstall actions.