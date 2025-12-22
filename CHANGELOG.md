# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

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
**Current Version:** 1.0.0  
**Release Date:** December 22, 2024
