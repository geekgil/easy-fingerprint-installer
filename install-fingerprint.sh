#!/bin/bash
################################################################################
# Easy Fingerprint Installer for Linux (Validity/Synaptics)
# Version 1.1.0
################################################################################
#
# This script installs and configures the python-validity + open-fprintd driver
# for Validity/Synaptics fingerprint readers on Linux laptops.
#
# Author: Gileade C. Valente (@geekgil)
# Date: December 2025
# Compatibility: Ubuntu 24.04+ and derivatives
#
# Features:
# - Persistent state system (resumes from where it stopped after reboot)
# - Intelligent reboot detection
# - Interactive menu for enrolling multiple fingers
# - Robust sanity checks and validations
# - USB autosuspend protection
#
################################################################################

# Temporarily disable exit on error (we'll manage errors manually)
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# State file
STATE_FILE="$HOME/.fingerprint_install_state"

# Backup directory
BACKUP_DIR="$HOME/.fingerprint_backups"

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "\n${GREEN}=>${NC} ${BLUE}$1${NC}\n"
}

print_critical() {
    echo ""
    echo -e "${RED}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}║  $1${NC}"
    echo -e "${RED}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# State management functions
save_state() {
    echo "$1" > "$STATE_FILE"
}

get_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "0"
    fi
}

clear_state() {
    rm -f "$STATE_FILE"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "DO NOT run this script as root (sudo). It will ask for password when needed."
    exit 1
fi

# Banner
clear
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║       Easy Fingerprint Installer for Linux                    ║"
echo "║                        Version 1.1.0                           ║"
echo "║  Stack: python-validity + open-fprintd                         ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Read current state
CURRENT_STATE=$(get_state)
print_info "Current installation state: Phase $CURRENT_STATE"

if [ "$CURRENT_STATE" != "0" ]; then
    print_warning "Previous installation in progress detected."
    print_info "The script will continue from where it stopped."
    echo ""
fi

################################################################################
# PHASE 1: PRE-INSTALLATION CHECKS
################################################################################

if [ "$CURRENT_STATE" -lt 1 ]; then
    print_step "PHASE 1: Pre-Installation Checks"

    # Check if device exists
    print_info "Looking for Validity/Synaptics fingerprint reader..."
    FINGERPRINT_DEVICE=$(lsusb | grep -i "06cb:" || true)

    if [ -z "$FINGERPRINT_DEVICE" ]; then
        print_error "No Validity/Synaptics reader detected (ID 06cb:xxxx)"
        print_info "USB devices found:"
        lsusb
        exit 1
    fi

    print_success "Reader found:"
    echo "   $FINGERPRINT_DEVICE"

    # Extract and save vendor and product ID
    VENDOR_ID=$(echo "$FINGERPRINT_DEVICE" | grep -oP 'ID \K[0-9a-f]{4}(?=:)')
    PRODUCT_ID=$(echo "$FINGERPRINT_DEVICE" | grep -oP 'ID [0-9a-f]{4}:\K[0-9a-f]{4}')
    print_info "Vendor ID: $VENDOR_ID, Product ID: $PRODUCT_ID"
    
    # Save IDs for next runs
    echo "$VENDOR_ID" > "$HOME/.fingerprint_vendor_id"
    echo "$PRODUCT_ID" > "$HOME/.fingerprint_product_id"

    # Check if PPA is already configured
    print_info "Checking PPA repository..."
    if ! grep -q "uunicorn/open-fprintd" /etc/apt/sources.list /etc/apt/sources.list.d/* 2>/dev/null; then
        print_warning "PPA not found. Adding repository..."
        sudo add-apt-repository -y ppa:uunicorn/open-fprintd
        sudo apt update
    else
        print_success "PPA already configured"
    fi

    save_state 1
    print_success "Phase 1 completed!"
else
    print_info "✓ Phase 1 already completed, skipping..."
    # Recover saved IDs
    VENDOR_ID=$(cat "$HOME/.fingerprint_vendor_id" 2>/dev/null || echo "06cb")
    PRODUCT_ID=$(cat "$HOME/.fingerprint_product_id" 2>/dev/null || echo "009a")
fi

################################################################################
# PHASE 2: POWER CONFIGURATION (FREEZE PREVENTION)
################################################################################

if [ "$CURRENT_STATE" -lt 2 ]; then
    print_step "PHASE 2: Power Configuration (Freeze Prevention)"

    UDEV_RULE_FILE="/etc/udev/rules.d/99-fingerprint-power.rules"
    print_info "Creating udev rule to disable USB autosuspend..."

    # Create udev rule
    sudo tee "$UDEV_RULE_FILE" > /dev/null << EOF
# Rule to prevent USB autosuspend on fingerprint reader
# This prevents the driver from getting "stuck" in suspension state
# Automatically generated by install-fingerprint.sh v1.0

ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="$VENDOR_ID", ATTR{idProduct}=="$PRODUCT_ID", ATTR{power/autosuspend}="-1"
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="$VENDOR_ID", ATTR{idProduct}=="$PRODUCT_ID", ATTR{power/control}="on"
EOF

    print_success "Rule created at: $UDEV_RULE_FILE"

    # Reload udev rules
    print_info "Reloading udev rules..."
    sudo udevadm control --reload-rules
    sudo udevadm trigger

    # Apply manually to current device
    print_info "Applying power configuration to current device..."
    USB_DEVICE_PATH=$(find /sys/bus/usb/devices/ -name "*$VENDOR_ID:$PRODUCT_ID*" 2>/dev/null | head -n1)
    if [ -n "$USB_DEVICE_PATH" ]; then
        echo -1 | sudo tee "$USB_DEVICE_PATH/power/autosuspend" > /dev/null 2>&1 || true
        echo on | sudo tee "$USB_DEVICE_PATH/power/control" > /dev/null 2>&1 || true
        print_success "Power configuration applied"
    else
        print_warning "Could not apply configuration immediately"
        print_info "It will be applied automatically after restart"
    fi

    save_state 2
    print_success "Phase 2 completed!"
else
    print_info "✓ Phase 2 already completed, skipping..."
fi

################################################################################
# SANITY CHECK: VERIFY IF BINARIES EXIST
################################################################################

# Sanity Check: Verify if binaries actually exist
# This prevents errors if user uninstalled but state file persisted
if [ "$CURRENT_STATE" -ge 3 ]; then
    if ! command -v fprintd-enroll &> /dev/null; then
        print_warning "Inconsistency detected: State says Phase $CURRENT_STATE, but fprintd-enroll was not found."
        print_info "Forcing package reinstallation (Going back to Phase 2)..."
        CURRENT_STATE=2
        save_state 2
    fi
fi

################################################################################
# PHASE 3: PACKAGE INSTALLATION
################################################################################

if [ "$CURRENT_STATE" -lt 3 ]; then
    print_step "PHASE 3: Package Installation"

    print_info "Installing python3-validity, open-fprintd and fprintd-clients..."
    sudo apt update
    
    if sudo apt install -y python3-validity open-fprintd fprintd-clients; then
        print_success "Packages installed successfully"
        save_state 3
        print_success "Phase 3 completed!"
    else
        print_error "Package installation failed"
        print_info "Try running the script again"
        exit 1
    fi
else
    print_info "✓ Phase 3 already completed, skipping..."
fi

################################################################################
# PHASE 4: INITIALIZATION AND VERIFICATION
################################################################################

if [ "$CURRENT_STATE" -lt 4 ]; then
    print_step "PHASE 4: Initialization and Verification"

    # Restart services
    print_info "Restarting python3-validity service..."
    sudo systemctl restart python3-validity.service
    sleep 3

    print_info "Checking service status..."
    if systemctl is-active --quiet python3-validity.service; then
        print_success "python3-validity service is active"
    else
        print_warning "python3-validity service is not active"
        print_info "Checking failure cause..."
        
        # Capture logs for analysis
        SERVICE_LOGS=$(sudo journalctl -u python3-validity.service --since "1 minute ago" 2>/dev/null)
        
        # Check if it's a firmware error that needs reboot
        if echo "$SERVICE_LOGS" | grep -qE "message type|USBTimeoutError|Operation timed out|Unexpected TLS version|Traceback"; then
            print_critical "  COMPUTER RESTART REQUIRED!  "
            echo ""
            print_warning "Firmware was installed, but the reader needs a physical reset."
            print_info "This is normal on first installation."
            echo ""
            print_info "NEXT STEPS:"
            echo "   1. Restart your computer now"
            echo "   2. After restarting, run this script again:"
            echo -e "      ${CYAN}./install-fingerprint.sh${NC}"
            echo "   3. The script will automatically continue from fingerprint enrollment"
            echo ""
            save_state 4
            print_info "State saved. See you soon!"
            exit 0
        else
            # Unknown error
            print_error "python3-validity service failed to start (unknown cause)"
            sudo systemctl status python3-validity.service --no-pager
            exit 1
        fi
    fi

    # Check open-fprintd
    print_info "Checking open-fprintd..."
    sleep 2
    if systemctl is-active --quiet open-fprintd.service || pgrep -f open-fprintd > /dev/null; then
        print_success "open-fprintd service is active"
    else
        print_warning "open-fprintd will be started on demand via D-Bus"
    fi
    
    # Test if it can list devices
    print_info "Testing communication with the reader..."
    if timeout 5 fprintd-list "$USER" &>/dev/null; then
        print_success "Communication with the reader is working!"
        save_state 4
        print_success "Phase 4 completed!"
    else
        # Probably needs reboot
        print_critical "  COMPUTER RESTART REQUIRED!  "
        echo ""
        print_warning "The reader is not responding to commands."
        print_info "A computer restart is needed to load the firmware."
        echo ""
        print_info "NEXT STEPS:"
        echo "   1. Restart your computer now"
        echo "   2. After restarting, run this script again:"
        echo -e "      ${CYAN}./install-fingerprint.sh${NC}"
        echo "   3. The script will automatically continue from fingerprint enrollment"
        echo ""
        save_state 4
        print_info "State saved. See you soon!"
        exit 0
    fi
else
    print_info "✓ Phase 4 already completed, skipping..."
fi

################################################################################
# PHASE 5: FINGERPRINT ENROLLMENT (INTERACTIVE MENU)
################################################################################

if [ "$CURRENT_STATE" -lt 5 ]; then
    print_step "PHASE 5: Fingerprint Enrollment"

    # Finger mapping
    declare -A FINGER_MAP
    FINGER_MAP[1]="right-index-finger|Right Index Finger"
    FINGER_MAP[2]="right-thumb|Right Thumb"
    FINGER_MAP[3]="right-middle-finger|Right Middle Finger"
    FINGER_MAP[4]="right-ring-finger|Right Ring Finger"
    FINGER_MAP[5]="right-little-finger|Right Little Finger"
    FINGER_MAP[6]="left-index-finger|Left Index Finger"
    FINGER_MAP[7]="left-thumb|Left Thumb"
    FINGER_MAP[8]="left-middle-finger|Left Middle Finger"
    FINGER_MAP[9]="left-ring-finger|Left Ring Finger"
    FINGER_MAP[10]="left-little-finger|Left Little Finger"

    # Enrollment loop
    while true; do
        clear
        echo "╔════════════════════════════════════════════════════════════════╗"
        echo "║           FINGERPRINT ENROLLMENT MENU                          ║"
        echo "╚════════════════════════════════════════════════════════════════╝"
        echo ""
        
        # Show already enrolled fingers
        print_info "Fingers already enrolled:"
        ENROLLED_FINGERS=$(fprintd-list "$USER" 2>/dev/null | grep -oP '#\d+: \K.*' || echo "  None")
        if [ "$ENROLLED_FINGERS" = "  None" ]; then
            echo -e "  ${YELLOW}No fingers enrolled yet${NC}"
        else
            echo "$ENROLLED_FINGERS" | while read -r finger; do
                echo -e "  ${GREEN}✓${NC} $finger"
            done
        fi
        echo ""
        
        print_info "Choose which finger to enroll:"
        echo ""
        echo -e "  ${CYAN}RIGHT HAND:${NC}"
        echo "    1) Right Index Finger"
        echo "    2) Right Thumb"
        echo "    3) Right Middle Finger"
        echo "    4) Right Ring Finger"
        echo "    5) Right Little Finger"
        echo ""
        echo -e "  ${CYAN}LEFT HAND:${NC}"
        echo "    6) Left Index Finger"
        echo "    7) Left Thumb"
        echo "    8) Left Middle Finger"
        echo "    9) Left Ring Finger"
        echo "   10) Left Little Finger"
        echo ""
        echo -e "  ${GREEN}0) Finish enrollment and continue${NC}"
        echo ""
        read -p "Enter your choice (0-10): " CHOICE

        if [ "$CHOICE" = "0" ]; then
            # Check if at least one finger was enrolled
            ENROLLED_COUNT=$(fprintd-list "$USER" 2>/dev/null | grep -c "^Device at" || echo "0")
            if [ "$ENROLLED_COUNT" -gt 0 ]; then
                print_success "Enrollment completed!"
                save_state 5
                break
            else
                print_warning "You need to enroll at least one finger before continuing."
                read -p "Press ENTER to return to menu..."
                continue
            fi
        fi

        # Validate choice
        if ! [[ "$CHOICE" =~ ^[1-9]$|^10$ ]]; then
            print_error "Invalid choice. Please choose a number between 0 and 10."
            read -p "Press ENTER to continue..."
            continue
        fi

        # Extract technical and friendly name
        FINGER_INFO="${FINGER_MAP[$CHOICE]}"
        FINGER_TECH=$(echo "$FINGER_INFO" | cut -d'|' -f1)
        FINGER_NAME=$(echo "$FINGER_INFO" | cut -d'|' -f2)

        echo ""
        print_info "Enrolling: ${CYAN}$FINGER_NAME${NC}"
        print_info "Follow the instructions and swipe your finger on the sensor multiple times."
        echo ""
        
        # Try to enroll
        if fprintd-enroll -f "$FINGER_TECH" "$USER"; then
            echo ""
            print_success "$FINGER_NAME enrolled successfully!"
            echo ""
            read -p "Press ENTER to return to menu..."
        else
            echo ""
            print_error "Failed to enroll $FINGER_NAME"
            print_info "You can try again."
            echo ""
            read -p "Press ENTER to return to menu..."
        fi
    done

    print_success "Phase 5 completed!"
else
    print_info "✓ Phase 5 already completed, skipping..."
fi

################################################################################
# PHASE 6: VERIFICATION TEST
################################################################################

if [ "$CURRENT_STATE" -lt 6 ]; then
    print_step "PHASE 6: Verification Test"

    print_info "Let's test if the reader recognizes your fingerprints."
    echo ""
    read -p "Press ENTER and place your finger on the sensor when prompted..."

    if fprintd-verify; then
        print_success "Verification successful! The reader is working correctly."
    else
        print_warning "Verification failed."
        print_info "You can enroll more fingers by running: fprintd-enroll -f <finger-name>"
    fi

    save_state 6
    print_success "Phase 6 completed!"
else
    print_info "✓ Phase 6 already completed, skipping..."
fi

################################################################################
# PHASE 7: SYSTEM ACTIVATION (OPTIONAL)
################################################################################

if [ "$CURRENT_STATE" -lt 7 ]; then
    print_step "PHASE 7: Fingerprint Sensor Configuration"

    echo ""
    print_info "Let's configure the fingerprint sensor behavior."
    echo ""
    
    # Configure timeout
    print_info "TIMEOUT: How long should the sensor stay active waiting for your finger?"
    echo "   • Recommended: 300 seconds (5 minutes) for lock screen"
    echo "   • Minimum allowed: 10 seconds"
    echo "   • You can use large values like 3600 (1 hour) if desired"
    echo ""
    read -p "Enter timeout in seconds [default: 300]: " USER_TIMEOUT
    
    # Use default if empty
    if [ -z "$USER_TIMEOUT" ]; then
        USER_TIMEOUT=300
    fi
    
    # Validate timeout (minimum 10 seconds)
    if ! [[ "$USER_TIMEOUT" =~ ^[0-9]+$ ]] || [ "$USER_TIMEOUT" -lt 10 ]; then
        print_warning "Invalid timeout. Using default: 300 seconds"
        USER_TIMEOUT=300
    fi
    
    echo ""
    
    # Configure max tries
    print_info "MAX TRIES: How many failed attempts before falling back to password?"
    echo "   • Recommended: 3 attempts"
    echo "   • Minimum allowed: 1 attempt"
    echo ""
    read -p "Enter max tries [default: 3]: " USER_MAX_TRIES
    
    # Use default if empty
    if [ -z "$USER_MAX_TRIES" ]; then
        USER_MAX_TRIES=3
    fi
    
    # Validate max tries (minimum 1)
    if ! [[ "$USER_MAX_TRIES" =~ ^[0-9]+$ ]] || [ "$USER_MAX_TRIES" -lt 1 ]; then
        print_warning "Invalid max tries. Using default: 3"
        USER_MAX_TRIES=3
    fi
    
    echo ""
    print_success "Configuration: timeout=${USER_TIMEOUT}s, max-tries=${USER_MAX_TRIES}"
    echo ""
    
    # Apply configuration to PAM configs
    print_info "Applying configuration to system authentication..."
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Backup and configure /usr/share/pam-configs/fprintd (for sudo/login)
    PAM_CONFIG_FILE="/usr/share/pam-configs/fprintd"
    if [ -f "$PAM_CONFIG_FILE" ]; then
        print_info "Configuring sudo/login authentication..."
        # Save backup to defined location
        sudo cp "$PAM_CONFIG_FILE" "$BACKUP_DIR/fprintd.bak.$(date +%Y%m%d_%H%M%S)"
        
        # Replace the auth line
        sudo sed -i "s|^\t\[success=end default=ignore\].*pam_fprintd\.so.*|\t[success=end default=ignore]\tpam_fprintd.so max-tries=${USER_MAX_TRIES} timeout=${USER_TIMEOUT}|" "$PAM_CONFIG_FILE"
        print_success "Sudo/login configuration updated"
    else
        print_warning "PAM config file not found at $PAM_CONFIG_FILE"
    fi
    
    # Backup and configure /etc/pam.d/gdm-fingerprint (for lock screen)
    GDM_CONFIG_FILE="/etc/pam.d/gdm-fingerprint"
    if [ -f "$GDM_CONFIG_FILE" ]; then
        print_info "Configuring lock screen authentication..."
        
        # Save backup to defined location
        sudo cp "$GDM_CONFIG_FILE" "$BACKUP_DIR/gdm-fingerprint.bak.$(date +%Y%m%d_%H%M%S)"
        
        # Replace the auth line to add our parameters
        sudo sed -i "s|^auth\trequired\tpam_fprintd\.so.*|auth\trequired\tpam_fprintd.so max-tries=${USER_MAX_TRIES} timeout=${USER_TIMEOUT}|" "$GDM_CONFIG_FILE"
        print_success "Lock screen configuration updated"
    else
        print_warning "GDM config file not found at $GDM_CONFIG_FILE"
    fi
    
    echo ""
    print_success "Fingerprint sensor configuration applied successfully!"
    echo ""
    
    # Now ask about PAM activation
    print_warning "IMPORTANT: Integration with login and sudo is OPTIONAL."
    echo ""
    print_info "To enable fingerprint authentication on the system:"
    echo "   1. Run: sudo pam-auth-update"
    echo "   2. Check the 'Fingerprint authentication' option with the spacebar"
    echo "   3. Select <Ok> and confirm"
    echo ""
    print_info "Recommendation: Test the reader for a few days before enabling PAM!"
    print_warning "If the reader freezes (slow sudo), disable with: sudo pam-auth-update"
    echo ""

    read -p "Do you want to activate fingerprint authentication NOW? (y/N): " ENABLE_PAM

    if [[ "$ENABLE_PAM" =~ ^[YySs]$ ]]; then
        print_info "Opening pam-auth-update..."
        sudo pam-auth-update
        print_success "PAM configuration updated"
    else
        print_info "Skipping PAM activation. You can do this later with: sudo pam-auth-update"
    fi

    save_state 7
    print_success "Phase 7 completed!"
else
    print_info "✓ Phase 7 already completed, skipping..."
fi

################################################################################
# FINALIZATION
################################################################################

print_step "✓ Installation Completed!"

# Clear state file
clear_state
rm -f "$HOME/.fingerprint_vendor_id" "$HOME/.fingerprint_product_id"

echo ""
print_success "The fingerprint reader is installed and configured."
echo ""
print_info "Useful commands:"
echo -e "   • Enroll new finger:             ${CYAN}fprintd-enroll -f <finger-name>${NC}"
echo -e "   • Verify fingerprint:            ${CYAN}fprintd-verify${NC}"
echo -e "   • List saved fingers:            ${CYAN}fprintd-list \$USER${NC}"
echo -e "   • Delete all fingers:            ${CYAN}fprintd-delete \$USER${NC}"
echo -e "   • Service status:                ${CYAN}systemctl status python3-validity${NC}"
echo -e "   • View logs:                     ${CYAN}journalctl -u python3-validity -f${NC}"
echo -e "   • Configure PAM:                 ${CYAN}sudo pam-auth-update${NC}"
echo ""
print_info "Finger names for fprintd-enroll -f:"
echo "   Right: right-thumb, right-index-finger, right-middle-finger,"
echo "          right-ring-finger, right-little-finger"
echo "   Left: left-thumb, left-index-finger, left-middle-finger,"
echo "         left-ring-finger, left-little-finger"
echo ""
print_info "If you encounter problems, check the logs and report on GitHub:"
echo "   https://github.com/uunicorn/python-validity"
echo ""

