# Changelog

## [1.3.0] - 2025-04-26

### Added
- Start and end timestamps around Preboot update operations for auditability.
- Full capture of Preboot diskutil output appended to `/var/log/policy_banner_update.log`.
- New logging entries for Preboot status and duration.

### Changed
- Improved Preboot operation output handling for Jamf Pro console truncation prevention.
- More precise filtering of standard vs. error Preboot outcomes.

### Fixed
- Ensured complete audit trail even when Preboot outputs lacked internal timestamps.

---

## [1.2.0] - 2025-04-26

### Added
- Captured Preboot update logs to separate output file inside temp directory.
- Filtered diskutil preboot output cleanly for Jamf Console viewing.
- Made policy banner validation macOS version aware.

---

## [1.1.0] - 2025-04-26

### Added
- Forced Preboot volume update after replacing PolicyBanner.
- Prevented false positive warnings due to Preboot lag.

---

## [1.0.0] - 2025-04-26

### Added
- Initial release.
- Full support for `.rtfd` policy banner replacement with backup, ownership, permissions.
- Structured logging system.