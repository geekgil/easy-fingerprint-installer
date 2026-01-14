# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

---

## [1.1.1] - 2026-01-14

### 🐛 Fixed

- **Critical Bug: Duplicate PAM entries in `pam-auth-update`**
  - Fixed issue where backup files were created in `/usr/share/pam-configs/` causing duplicate "Fingerprint authentication" entries
  - The old backup strategy (`fprintd.bak` in system directories) was being read by PAM as a separate configuration
  - This caused confusion and potential authentication issues for users

### 🔧 Changed

- **New Backup Strategy: Centralized and Persistent**
  - All backup files now stored in `~/.fingerprint_backups/` instead of system directories
  - Backup files include timestamp: `fprintd.bak.YYYYMMDD_HHMMSS`
  - Both `fprintd` and `gdm-fingerprint` configs now backed up to same location
  
- **Enhanced Uninstaller**
  - Uninstaller now checks `~/.fingerprint_backups/` for restoration
  - Added interactive prompt to optionally remove backup directory during uninstall
  - Removed legacy code that searched for old-style `.bak` files in system directories

### 📚 Documentation

- Updated internal code comments to reflect new backup location
- Documented backup strategy change in CHANGELOG

---

## [1.1.0] - 2025-12-23

### ✨ Added

- **Interactive Sensor Configuration** in Phase 7
  - User can now customize fingerprint sensor timeout (default: 300s / 5 minutes)
  - User can configure max authentication attempts before fallback to password (default: 3)
  - Input validation ensures minimum values (timeout >= 10s, max-tries >= 1)
  - Fixes common issue where sensor would turn off too quickly on lock screen

- **Enhanced PAM Configuration**
  - Script now modifies `/usr/share/pam-configs/fprintd` for sudo/login authentication
  - Script now modifies `/etc/pam.d/gdm-fingerprint` for lock screen authentication
  - Creates backup files (`.bak`) before making changes
  - Ensures consistent behavior across all authentication scenarios

### 🐛 Fixed

- Fixed PAM configuration syntax bug: changed `max_tries` to `max-tries` (proper hyphen syntax)
  - Previous configuration used underscore which was being ignored by `pam_fprintd`
  - This explains why users were getting 3 attempts despite config showing `max_tries=1`
  
### 🔧 Changed

- **Phase 7** renamed from "System Activation (Login/Sudo)" to "Fingerprint Sensor Configuration"
- Enhanced uninstaller to properly restore customized PAM configuration files
  - Removes custom parameters from `/etc/pam.d/gdm-fingerprint`
  - Restores backup files when available
  - Cleans up all `.bak` files in Phase 5

### 📚 Documentation

- Updated README.md with new "Customizable Sensor Behavior" feature
- Updated Phase 7 description in "Detailed Usage" section
- Added `/etc/pam.d/gdm-fingerprint` and `/usr/share/pam-configs/fprintd` to "Modified System Files" list

---

## [1.0.1] - 2025-12-23

### 🐛 Fixed

- Improved reboot detection logic in `install-fingerprint.sh` to correctly handle `Unexpected TLS version` and other Python `Traceback` errors during the initialization of `python3-validity`. This prevents the script from failing and guides the user to perform the necessary system reboot.

### 🔧 Changed

- Standardized output messages to English: changed `[AVISO]` to `[WARNING]` and `[ERRO]` to `[ERROR]` for consistency with other log messages.

---

## [1.0.0] - 2025-12-22

### 🎉 Initial Release

First stable version of Easy Fingerprint Installer, a complete and robust solution for installing the python-validity driver on Linux laptops with Synaptics/Validity fingerprint readers.

### ✨ Features

- **Persistent State System**
  - `~/.fingerprint_install_state` file tracks installation progress
  - Script automatically resumes from where it stopped after reboot
  - Auxiliary files: `~/.fingerprint_vendor_id` and `~/.fingerprint_product_id`

- **Intelligent Reboot Detection**
  - Detects `USBTimeoutError` that requires reboot
  - Detects firmware `message type XX` errors
  - Clear messages and step-by-step instructions for the user
  - Automatic state saving before requesting reboot

- **Interactive Enrollment Menu**
  - TUI interface to choose which fingers to enroll
  - Support for all 10 fingers (both hands)
  - Display of already enrolled fingers
  - User input validation
  - Option to finish when desired

- **Automatic Sanity Check**
  - Validates if binaries exist before proceeding
  - Detects inconsistency between saved state and installed packages
  - Forces automatic reinstallation if necessary
  - Prevents "command not found" errors

- **7-Phase Phased Installation**
  1. Pre-Installation Checks
  2. Power Configuration (USB autosuspend)
  3. Package Installation
  4. Initialization and Verification
  5. Fingerprint Enrollment
  6. Verification Test
  7. System Activation (PAM)

- **Anti-Freeze Protections**
  - Custom udev rule to disable USB autosuspend
  - Device-specific configuration (vendor/product ID)
  - Immediate and persistent application after reboot

- **User-Friendly Interface**
  - Professional ASCII art banner
  - Colors for different message types (INFO, OK, WARNING, ERROR)
  - Consistent output formatting
  - Attention boxes for critical warnings

- **Complete Uninstall Script**
  - Removes all installed packages
  - Cleans udev rules
  - Removes PAM configuration
  - Deletes state files
  - Erases enrolled fingerprints
  - Final verification of residues

### 🔧 Technical Components

- **Installed Packages:**
  - `python3-validity` (0.14+) - DBus Driver
  - `open-fprintd` (0.6+) - fprintd implementation
  - `fprintd-clients` (1.90.1+) - CLI tools

- **Created Files:**
  - `/etc/udev/rules.d/99-fingerprint-power.rules`
  - Temporary state files in `~/.fingerprint_*`
  - Optional modifications in `/etc/pam.d/common-auth`

### 📦 Compatibility

- **Systems:** Ubuntu 24.04+, Pop!_OS 24.04+
- **Devices:** Validity/Synaptics readers (USB ID: `06cb:xxxx`)
- **Laptops:** Any laptop with Synaptics/Validity sensors (Tested on: Lenovo ThinkPad T480)

### 📚 Documentation

- Complete README with installation guide and troubleshooting
- CHANGELOG for version tracking
- CONTRIBUTING with guide for contributors
- LICENSE (MIT) for free use and attribution

### 🔒 Security

- Auditable scripts without obfuscation
- Password request only when necessary
- Clear warnings about system modifications
- Documented security recommendations

---

## Change Types

- `✨ Added` - for new features
- `🔧 Changed` - for changes in existing features
- `🗑️ Removed` - for removed features
- `🐛 Fixed` - for bug fixes
- `🔒 Security` - for vulnerability fixes
- `📚 Documentation` - for documentation-only changes

---

**Maintainer:** @geekgil  
**Current Version:** 1.1.1  
**Release Date:** January 14, 2026
