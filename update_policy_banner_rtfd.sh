#!/bin/bash

#########################################################################################################################################################################
# MacJediWizard Consulting, Inc.
# Copyright (c) 2025 MacJediWizard Consulting, Inc.
# All rights reserved.
# Created by: William Grzybowski
#
# Script: update_policy_banner_rtfd.sh
#
# Description: - This script will update the macOS policy banner located in /Library/Security to use an .rtfd bundle for macOS 15 and above.
#               - The new policy banner is expected to be staged in /tmp/new_policy_banner.rtfd by a separate package or installer.
#               - This script will:
#                   - Create temporary working directories
#                   - Backup any existing PolicyBanner.rtfd found in /Library/Security
#                   - Remove the old policy banner safely
#                   - Replace it with the new .rtfd policy banner
#                   - Apply correct permissions and ownership recursively
#                   - Verify basic FileVault policy banner configuration status
#                   - Log all actions, warnings, errors, and debug information into /var/log/policy_banner_update.log
#
# Notes:
# - Must be run as root (required for filesystem and permission changes)
# - DEBUG_MODE can be enabled internally for more verbose logging if needed
# - Designed for use inside Jamf Pro via custom triggers or postinstall scripts
# - Assumes that the new banner is already deployed to /tmp before execution
#
# License:
# This script is licensed under the MIT License.
# See the LICENSE file in the root of this repository for details.
#
#
# Change Log:
# Version 1.0.0 - 2025-04-26
#   - Initial creation of script.
#   - Added full support for replacing PolicyBanner.rtfd on macOS 15+.
#   - Implemented backup, remove, and replace operations with proper permissions and ownership.
#   - Integrated full logging system to /var/log/policy_banner_update.log.
#   - Designed script for modular deployment via Jamf Pro custom triggers or postinstall actions.
#
# Version 1.1.0 - 2025-04-26
#   - Improved validate_filevault_banner function:
#       - Added diskutil apfs updatePreboot / before checking preboot banner status.
#       - Prevented false warnings by forcing preboot sync immediately after banner replacement.
#
# Version 1.2.0 - 2025-04-26
#   - Captured full Preboot update output to custom log file.
#   - Filtered diskutil output for Jamf console logs to prevent truncation.
#   - Added macOS version-aware logic to skip unreliable /private/var/db/.PolicyBanner check on macOS 14+ (Sonoma+).
#
# Version 1.3.0 - 2025-04-26
#   - Added start and end timestamps around Preboot update process.
#   - Improved logging clarity for Preboot sync operations.
#   - Ensured complete audit trail even when diskutil output lacks internal timestamps.
#
#########################################################################################################################################################################

set -o pipefail
set -u
set -e

# Global Variables
STAGING_DIR="/tmp"
TEMP_DIR="${STAGING_DIR}/banner_temp"
ZIP_FILE="new_policy_banner.rtfd.zip"
ZIP_FILE_PATH="${STAGING_DIR}/${ZIP_FILE}"
NEW_BANNER_NAME="new_policy_banner.rtfd"
TARGET_BANNER_NAME="PolicyBanner.rtfd"
NEW_BANNER_PATH="${STAGING_DIR}/${NEW_BANNER_NAME}"
INSTALL_DIR="/Library/Security"
TARGET_BANNER_PATH="${INSTALL_DIR}/${TARGET_BANNER_NAME}"
LOG_FILE="/var/log/policy_banner_update.log"
DEBUG_MODE=0

trap 'cleanup' EXIT HUP INT QUIT TERM

# Logging Functions
log_info() {
    local message="$1"
    printf "[%s] [INFO] %s\n" "$(date "+%Y-%m-%d %H:%M:%S")" "$message" | tee -a "$LOG_FILE"
}

log_warn() {
    local message="$1"
    printf "[%s] [WARN] %s\n" "$(date "+%Y-%m-%d %H:%M:%S")" "$message" | tee -a "$LOG_FILE" >&2
}

log_error() {
    local message="$1"
    printf "[%s] [ERROR] %s\n" "$(date "+%Y-%m-%d %H:%M:%S")" "$message" | tee -a "$LOG_FILE" >&2
}

log_debug() {
    local message="$1"
    if [[ "$DEBUG_MODE" -eq 1 ]]; then
        printf "[%s] [DEBUG] %s\n" "$(date "+%Y-%m-%d %H:%M:%S")" "$message" | tee -a "$LOG_FILE"
    fi
}

# Prepare log file
prepare_log_file() {
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
        chmod 644 "$LOG_FILE"
    fi
}

# Create temporary directory
create_temp_dir() {
    if ! mkdir -p "$TEMP_DIR"; then
        log_error "Could not create temporary directory $TEMP_DIR"
        return 1
    fi
    log_debug "Temporary directory $TEMP_DIR created"
}

# Extract zip file containing .rtfd Banner
extract_banner() {
    if [[ ! -f "$ZIP_FILE_PATH" ]]; then
        log_error "zip file not found in $STAGING_DIR"
        return 1
    fi
    unzip -qou $ZIP_FILE_PATH -d $TEMP_DIR
}

# Validate the new banner exists
validate_new_banner() {
    if [[ ! -d "$NEW_BANNER_PATH" ]]; then
        log_error "New policy banner directory not found at $NEW_BANNER_PATH"
        return 1
    fi
    log_debug "New policy banner found at $NEW_BANNER_PATH"
}

# Prepare install directory
prepare_install_dir() {
    if [[ ! -d "$INSTALL_DIR" ]]; then
        if ! mkdir -p "$INSTALL_DIR"; then
            log_error "Failed to create $INSTALL_DIR"
            return 1
        fi
        log_info "Created $INSTALL_DIR"
    fi
}

# Compare banners to see if current one needs replacing
compare_banners() {
    local NEW="${NEW_BANNER_PATH}"
    local CURRENT="${TARGET_BANNER_PATH}"

    if [[ ! -d "$NEW" ]]; then
        log_error "New policy banner not found at $NEW"
        return 1
    fi

    if [[ ! -d "$CURRENT" ]]; then
        log_info "No existing PolicyBanner found. Will install new one."
        return 1
    fi

    if diff -qr "$NEW" "$CURRENT" >/dev/null; then
        log_info "PolicyBanner content is the same. No update needed."
        return 0
    else
        log_info "PolicyBanner content differs. Update required."
        return 1
    fi
}

# Backup existing banner
backup_existing_banner() {
    if [[ -d "$TARGET_BANNER_PATH" ]]; then
        local backup_dir;
        backup_dir="${TEMP_DIR}/PolicyBanner_backup_$(date +%Y%m%d%H%M%S).rtfd"
        if ! cp -R "$TARGET_BANNER_PATH" "$backup_dir"; then
            log_error "Failed to backup existing policy banner to $backup_dir"
            return 1
        fi
        log_info "Existing policy banner backed up to $backup_dir"
    else
        log_info "No existing policy banner to backup"
    fi
}

# Remove old banner
remove_old_banner() {
    if [[ -d "$TARGET_BANNER_PATH" ]]; then
        if ! rm -rf "$TARGET_BANNER_PATH"; then
            log_error "Failed to remove old policy banner at $TARGET_BANNER_PATH"
            return 1
        fi
        log_info "Old policy banner removed"
    fi
}

# Replace with new banner
replace_banner() {
    if ! cp -R "$NEW_BANNER_PATH" "$TARGET_BANNER_PATH"; then
        log_error "Failed to copy new policy banner to $TARGET_BANNER_PATH"
        return 1
    fi
    if ! chmod -R 755 "$TARGET_BANNER_PATH"; then
        log_error "Failed to set permissions on $TARGET_BANNER_PATH"
        return 1
    fi
    if ! chown -R root:wheel "$TARGET_BANNER_PATH"; then
        log_error "Failed to set ownership on $TARGET_BANNER_PATH"
        return 1
    fi
    log_info "New policy banner deployed successfully at $TARGET_BANNER_PATH"
}

# Validate FileVault Preboot Banner
validate_filevault_banner() {
    log_info "Starting Preboot volume update to sync PolicyBanner..."
    
    local update_log="${TEMP_DIR}/updatepreboot_output.log"
    local start_time;
    start_time="$(date '+%Y-%m-%d %H:%M:%S')"
    
    if ! diskutil apfs updatePreboot / > "$update_log" 2>&1; then
        log_warn "Failed to update preboot volume. Preboot banner status might not be accurate."
        log_info "Preboot update started at $start_time and failed at $(date '+%Y-%m-%d %H:%M:%S')."
        cat "$update_log" >> "$LOG_FILE"
        return 0
    fi
    
    local end_time;
    end_time="$(date '+%Y-%m-%d %H:%M:%S')"
    log_info "Preboot volume update completed. Start: $start_time | End: $end_time"
    
    cat "$update_log" >> "$LOG_FILE"
    
    # Filter clean summary for Jamf console
    if grep -q "Successfully wrote Encrypted Root PList File" "$update_log"; then
        log_info "Preboot update completed successfully."
    elif grep -q "Error" "$update_log"; then
        log_warn "Potential issues detected during Preboot update. Check detailed logs."
    else
        log_info "Preboot update completed with standard output."
    fi
    
    # Version-aware check for policy banner
    local os_major_version;
    os_major_version=$(sw_vers -productVersion | awk -F '.' '{print $1}')
    
    if [[ "$os_major_version" -ge 14 ]]; then
        log_info "Running macOS $os_major_version detected; skipping /private/var/db/.PolicyBanner check (not reliable on macOS 14+)."
        return 0
    fi
    
    local preboot_banner="/private/var/db/.PolicyBanner"
    if [[ -e "$preboot_banner" ]]; then
        log_info "Policy banner is configured for FileVault preboot screen."
    else
        log_warn "Policy banner not configured for FileVault preboot screen after update."
    fi
}

# Cleanup temporary directory
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
        log_debug "Temporary directory $TEMP_DIR cleaned up"
    fi
}

# Main Execution
main() {
    if [[ $(id -u) -ne 0 ]]; then
        log_error "This script must be run as root"
        return 1
    fi
    
    prepare_log_file
    log_info "Starting policy banner update process"

    extract_banner || return 1
    create_temp_dir || return 1
    validate_new_banner || return 1
    prepare_install_dir || return 1
    compare_banners || return 1
    backup_existing_banner || return 1
    remove_old_banner || return 1
    replace_banner || return 1
    validate_filevault_banner
    
    log_info "Policy banner update completed"
}

main


#########################################################################################################################################################################
# End of Script: update_policy_banner_rtfd.sh
# MacJediWizard Consulting, Inc. © 2025. All rights reserved.
#########################################################################################################################################################################
