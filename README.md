# 🔐 Easy Fingerprint Installer for Linux

> Automated and robust installation of python-validity driver for Synaptics fingerprint readers on Linux laptops

[![Version](https://img.shields.io/badge/version-1.0-blue.svg)](https://github.com/geekgil/easy-fingerprint-installer)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-24.04+-orange.svg)](https://ubuntu.com/)
[![Shell Script](https://img.shields.io/badge/shell-bash-89e051.svg)](https://www.gnu.org/software/bash/)

---

## 📖 Table of Contents

- [The Problem](#-the-problem)
- [The Solution](#-the-solution)
- [Quick Start](#-quick-start)
- [Features](#-features)
- [Compatibility](#-compatibility)
- [Detailed Usage](#-detailed-usage)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [References](#-references)

---

## 🔍 The Problem

Fingerprint readers generally don't have official drivers on Linux. The open-source `python-validity` solution works as a substitute, but manual installation is complex and prone to errors that cause system freezes.

### ⚠️ Common Symptoms (Without This Script)

- `sudo` takes 10-30 seconds to respond when there are issues with the fingerprint detection system
- Login screen freezes waiting for the fingerprint reader
- In logs: `"The service is suspended, delay the call"`
- After manual installation: `USBTimeoutError` or `message type 15` errors

### 🔬 Root Cause

The Linux kernel uses **USB autosuspend** for power saving. The fingerprint reader doesn't wake up correctly after suspension, getting stuck in a "zombie" state and freezing authentication operations.

---

## ✨ The Solution

This script implements a **robust, phased installation with protections** that:

✅ Automatically detects your fingerprint reader  
✅ Configures udev rules to disable USB autosuspend on the device  
✅ Installs necessary packages from the official PPA  
✅ **Detects when reboot is necessary** (firmware loading)  
✅ **Persistent state system** - resumes after reboot  
✅ **Interactive menu** to enroll multiple fingers  
✅ Optional PAM activation (login/sudo)  
✅ Complete and clean uninstall script  

---

## 🚀 Quick Start

### Installation in 3 Steps

```bash
# 1. Clone the repository
git clone https://github.com/geekgil/easy-fingerprint-installer.git
cd easy-fingerprint-installer

# 2. Run the installer
chmod +x install-fingerprint.sh
./install-fingerprint.sh

# 3. If it asks for reboot, restart and run again
# The script automatically resumes from where it stopped!
```

### Example Output

```
╔════════════════════════════════════════════════════════════════╗
║       Easy Fingerprint Installer for Linux                     ║
║                          Version 1.0                           ║
║  Stack: python-validity + open-fprintd                         ║
╚════════════════════════════════════════════════════════════════╝

[INFO] Current installation state: Phase 0

=> PHASE 1: Pre-Installation Checks
[OK] Reader found: Synaptics Metallica MIS Touch (06cb:009a)

=> PHASE 2: Power Configuration (Freeze Prevention)
[OK] Udev rule created

=> PHASE 3: Package Installation
[OK] Packages installed successfully

=> PHASE 4: Initialization and Verification
[OK] python3-validity service is active

=> PHASE 5: Fingerprint Enrollment
[Interactive menu appears here...]
```

---

## ⭐ Features

| Feature | Description |
|---------|-------------|
| **Persistent State System** | Resumes installation from where it stopped (even after reboot) |
| **Intelligent Reboot Detection** | Identifies firmware errors (`USBTimeoutError`, `message type` errors) and clearly warns when reboot is necessary |
| **Interactive Enrollment Menu** | Friendly interface to enroll as many fingers as you want |
| **Automatic Sanity Check** | Validates system consistency before proceeding (detects missing packages) |
| **Clean Uninstall** | Completely removes all state files and configurations |
| **Phased Installation** | 7 well-defined phases with validation at each step |
| **USB Autosuspend Protection** | Custom udev rule prevents freezes |

### 🎯 Interactive Enrollment Menu

```
╔════════════════════════════════════════════════════════════════╗
║           FINGERPRINT ENROLLMENT MENU                          ║
╚════════════════════════════════════════════════════════════════╝

[INFO] Fingers already enrolled:
  ✓ right-index-finger

[INFO] Choose which finger to enroll:

  RIGHT HAND:
    1) Right Index Finger    4) Right Ring Finger
    2) Right Thumb           5) Right Little Finger
    3) Right Middle Finger

  LEFT HAND:
    6) Left Index Finger     9) Left Ring Finger
    7) Left Thumb           10) Left Little Finger
    8) Left Middle Finger

  0) Finish enrollment and continue

Enter your choice (0-10): _
```

---

## 📦 Compatibility

### Tested Operating Systems

- ✅ Pop!_OS 24.04+
- ✅ Ubuntu 24.04 LTS (Noble) (should work)
- 🔶 Linux Mint 21+ or other Ubuntu derivatives (may work)

### Supported Devices

This installer works with **any laptop** equipped with a **Synaptics/Validity** fingerprint reader (USB ID `06cb:xxxx`).

| Model | USB ID | Status |
|-------|--------|--------|
| Synaptics Metallica MIS Touch | `06cb:009a` | ✅ Tested |
| Other Synaptics models | `06cb:xxxx` | 🔶 Should work |

**Tested on:** Lenovo ThinkPad T480

**Compatible with:** Dell, HP, Lenovo (ThinkPad, IdeaPad), Asus, and other laptops with Synaptics/Validity sensors

> 💡 **Tip:** Check if your reader is compatible with `lsusb | grep 06cb`

---

## 📘 Detailed Usage

### Complete Installation

```bash
# 1. Clone and enter directory
git clone https://github.com/geekgil/easy-fingerprint-installer.git
cd easy-fingerprint-installer

# 2. Make scripts executable
chmod +x *.sh

# 3. Run the installer
./install-fingerprint.sh
```

The script executes **7 phases**:

1. **Pre-Installation Checks** - Detects reader and configures repository
2. **Power Configuration** - Creates anti-freeze udev rule
3. **Package Installation** - Installs python-validity + open-fprintd
4. **Initialization and Verification** - Tests services and detects if reboot is needed
5. **Fingerprint Enrollment** - Interactive menu to enroll fingers
6. **Verification Test** - Validates that the reader recognizes your fingerprint
7. **System Activation** - (Optional) Integrates with login/sudo via PAM

### If the Script Asks for Reboot

```bash
# The script detected that firmware needs to be loaded
# Simply restart:
sudo reboot

# After restarting, run again:
./install-fingerprint.sh

# ✨ It will automatically continue from fingerprint enrollment (Phase 5)!
```

### Uninstall

```bash
./uninstall-fingerprint.sh
```

Completely removes:
- ✅ Installed packages
- ✅ Udev rules
- ✅ PAM configuration
- ✅ State files
- ✅ Enrolled fingerprints

---

## 🔧 Useful Commands

After successful installation:

### Managing Fingerprints

```bash
# Manually enroll new finger
fprintd-enroll -f right-thumb

# Verify if it recognizes your fingerprint
fprintd-verify

# List enrolled fingers
fprintd-list $USER

# Delete all fingerprints
fprintd-delete $USER
```

**Available finger names:**
- **Right Hand:** `right-thumb`, `right-index-finger`, `right-middle-finger`, `right-ring-finger`, `right-little-finger`
- **Left Hand:** `left-thumb`, `left-index-finger`, `left-middle-finger`, `left-ring-finger`, `left-little-finger`

### Monitoring System

```bash
# View service status
systemctl status python3-validity

# Monitor logs in real-time
journalctl -u python3-validity -f

# Check USB power configuration
cat /etc/udev/rules.d/99-fingerprint-power.rules
```

### Configure PAM (Login/Sudo)

```bash
# Enable/disable fingerprint authentication
sudo pam-auth-update

# Check if PAM is configured
grep pam_fprintd /etc/pam.d/common-auth
```

---

## 🐛 Troubleshooting

### Problem: `sudo` is still slow

**Cause:** PAM configured with fingerprint, but service doesn't respond quickly

**Solution:**
```bash
# Temporarily disable fingerprint authentication
sudo pam-auth-update
# → Uncheck "Fingerprint authentication"
```

### Problem: Service doesn't start

**Symptoms:**
```
[ERROR] python3-validity service failed to start
```

**Solution:**
```bash
# 1. Check the logs
sudo journalctl -u python3-validity --since "5 minutes ago"

# 2. If you see "message type" or "USBTimeoutError" → Needs reboot
sudo reboot

# 3. Try resetting the USB device
sudo systemctl restart python3-validity
```

### Problem: "No devices available"

**Solution:**
```bash
# 1. Confirm that the reader is detected
lsusb | grep 06cb

# 2. If it appears, probably needs reboot
sudo reboot

# 3. Run the installer again
./install-fingerprint.sh
```

### Problem: Script doesn't resume after reboot

**Solution:**
```bash
# Check the state file
cat ~/.fingerprint_install_state

# If it shows a phase, run the script again
./install-fingerprint.sh

# If you want to start from scratch, delete the state
rm ~/.fingerprint_install_state ~/.fingerprint_*
./install-fingerprint.sh
```

### Problem: fprintd-enroll not found

**Cause:** Packages were uninstalled but state file persists

**Solution:**
```bash
# The script automatically detects and reinstalls
./install-fingerprint.sh

# Or force manual cleanup:
rm ~/.fingerprint_install_state
./install-fingerprint.sh
```

### Problem: `Unexpected TLS version` Error

**Symptoms:**
```
Exception: Unexpected TLS version 4 0
```

**Cause:** The fingerprint reader is in an inconsistent state or protocol mismatch. This commonly occurs after a fresh installation or when the device firmware hasn't been properly initialized.

**Solution:**
```bash
# 1. The script should automatically detect this and ask for reboot
# If not, manually restart your computer
sudo reboot

# 2. After restarting, run the installer again
./install-fingerprint.sh

# 3. The script will automatically resume from where it stopped
```

> 💡 **Note:** This error is now automatically detected by the installer (v1.0.1+), which will guide you through the necessary reboot process.

---

## 🤝 Contributing

Your contributions are very welcome! 🎉

### How to Contribute

1. **Report Success/Failure**
   - Open an [issue](https://github.com/geekgil/easy-fingerprint-installer/issues) with:
     - Laptop model and brand
     - Reader USB ID (`lsusb | grep 06cb`)
     - Linux distribution and version
     - Error logs (if any)

2. **Suggest Improvements**
   - Fork the project
   - Create a branch (`git checkout -b feature/improvement`)
   - Commit your changes (`git commit -m 'Add new feature'`)
   - Push to the branch (`git push origin feature/improvement`)
   - Open a Pull Request

3. **Share with Friends**
   - If it worked for you, share with other Linux users! 🐧

### Volunteer Testers

We're looking for testers with:
- Different laptop brands (Dell, HP, Asus, Acer, etc.)
- Other Linux distributions (Fedora, Arch, Debian)
- Different fingerprint reader models

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guide.

---

## ⚙️ Technical Details

### Installed Components

| Package | Description | Version |
|---------|-------------|---------|
| `python3-validity` | DBus driver for hardware communication | 0.14+ |
| `open-fprintd` | Open-source fprintd implementation | 0.6+ |
| `fprintd-clients` | CLI tools (fprintd-enroll, etc.) | 1.90.1+ |

### Modified System Files

```
/etc/udev/rules.d/99-fingerprint-power.rules  # Power rule
/etc/pam.d/common-auth                        # (Optional) PAM config
/usr/lib/systemd/system/python3-validity.service
/usr/share/python-validity/                   # Extracted firmware
```

### Temporary Files (Removed at End)

```
~/.fingerprint_install_state    # Installation state
~/.fingerprint_vendor_id        # USB vendor ID
~/.fingerprint_product_id       # USB product ID
```

### PPA Repository Used

```bash
ppa:uunicorn/open-fprintd
# Maintained by: @uunicorn (python-validity author)
# Compatibility: Ubuntu 20.04+
```

---

## 📚 References

### Related Projects

- [python-validity](https://github.com/uunicorn/python-validity) - Original driver
- [open-fprintd](https://github.com/uunicorn/open-fprintd) - fprintd implementation
- [Arch Wiki - Validity](https://wiki.archlinux.org/title/Validity_fingerprint_sensors)

### Useful Documentation

- [fprintd Documentation](https://fprint.freedesktop.org/)
- [PAM Configuration Guide](https://wiki.archlinux.org/title/PAM)
- [udev Rules Tutorial](https://wiki.archlinux.org/title/Udev)

---

## ⚖️ License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
SPDX-License-Identifier: MIT
Copyright (c) 2025 Gileade C. Valente (@geekgil)
```

---

## ⚠️ Disclaimer

These scripts modify system configurations (PAM, udev, systemd).

**Security recommendations:**
- ✅ Backup important files before running
- ✅ Test the reader for a few days before enabling PAM
- ✅ Keep a root session open when testing (in case sudo freezes)
- ✅ Read the scripts before running (they are fully auditable)

**Disclaimer:** This software is provided "as is", without warranties. Use at your own risk.

---

## 🙏 Acknowledgments

### Credits

- **[@uunicorn](https://github.com/uunicorn)** - Author of python-validity and open-fprintd
- **[@geekgil](https://github.com/geekgil)** - Creator and maintainer of this installer
- **Linux Community** - Support and documentation

---

## 📞 Support

Found a problem? Have a question?

- 🐛 [Open an issue](https://github.com/geekgil/easy-fingerprint-installer/issues)
- 💬 [Discussions](https://github.com/geekgil/easy-fingerprint-installer/discussions)
- 📧 Email: gilvalente@ufmg.br

---

<div align="center">

**Made with ❤️ for the Linux community**

🐧 **Linux** • 🔐 **Security** • 🚀 **Easy Setup**

[![Star this repo](https://img.shields.io/github/stars/geekgil/easy-fingerprint-installer?style=social)](https://github.com/geekgil/easy-fingerprint-installer)
[![Fork this repo](https://img.shields.io/github/forks/geekgil/easy-fingerprint-installer?style=social)](https://github.com/geekgil/easy-fingerprint-installer/fork)

**[⬆ Back to top](#-easy-fingerprint-installer-for-linux)**

</div>
