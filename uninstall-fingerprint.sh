#!/bin/bash
################################################################################
# Easy Fingerprint Installer - Uninstaller for Linux
################################################################################
#
# This script completely removes the python-validity + open-fprintd driver
# and restores the system's default password authentication.
#
# Author: Gileade C. Valente (@geekgil)
# Date: December 2025
# Compatibility: Ubuntu 24.04+ and derivatives
#
################################################################################

set -e  # Stop on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print with color
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

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "DO NOT run this script as root (sudo). It will ask for password when needed."
    exit 1
fi

# Banner
clear
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║       Easy Fingerprint Installer - Uninstaller                ║"
echo "║                                                                ║"
echo "║  This script will completely remove python-validity            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

print_warning "ATTENTION: This script will:"
echo "   • Stop and disable fingerprint services"
echo "   • Remove fingerprint authentication from PAM (sudo/login)"
echo "   • Uninstall python3-validity, open-fprintd and fprintd-clients"
echo "   • Delete enrolled fingerprints and configuration files"
echo ""
read -p "Do you want to continue? (y/N): " CONFIRM

if [[ ! "$CONFIRM" =~ ^[YySs]$ ]]; then
    print_info "Operation cancelled by user."
    exit 0
fi

################################################################################
# PHASE 1: STOP SERVICES
################################################################################

print_step "PHASE 1: Stopping Services"

print_info "Stopping python3-validity..."
sudo systemctl stop python3-validity.service 2>/dev/null || print_warning "Service was already stopped"

print_info "Stopping open-fprintd..."
sudo systemctl stop open-fprintd.service 2>/dev/null || print_warning "Service was already stopped"

print_success "Services stopped"

################################################################################
# PHASE 2: DISABLE SERVICES
################################################################################

print_step "PHASE 2: Disabling Services"

print_info "Disabling python3-validity..."
sudo systemctl disable python3-validity.service 2>/dev/null || print_warning "Service was not enabled"

print_success "Services disabled"

################################################################################
# PHASE 3: REMOVE FROM PAM
################################################################################

print_step "PHASE 3: Removing Fingerprint Authentication from System"

print_info "Checking current PAM configuration..."
if grep -q "pam_fprintd.so" /etc/pam.d/common-auth 2>/dev/null; then
    print_warning "pam_fprintd.so module found in /etc/pam.d/common-auth"
    print_info "Opening pam-auth-update for you to UNCHECK 'Fingerprint authentication'..."
    echo ""
    print_warning "INSTRUCTIONS:"
    echo "   1. Use arrows to navigate"
    echo "   2. Use SPACE to UNCHECK 'Fingerprint authentication'"
    echo "   3. Press TAB to go to <Ok>"
    echo "   4. Press ENTER to confirm"
    echo ""
    read -p "Press ENTER to open pam-auth-update..."
    
    sudo pam-auth-update
    
    # Check if it was removed
    if grep -q "pam_fprintd.so" /etc/pam.d/common-auth 2>/dev/null; then
        print_error "The pam_fprintd.so module is still present!"
        print_warning "You need to uncheck the 'Fingerprint authentication' option"
        exit 1
    else
        print_success "pam_fprintd.so module removed from PAM"
    fi
else
    print_success "PAM was already without fingerprint authentication"
fi

################################################################################
# PHASE 4: UNINSTALL PACKAGES
################################################################################

print_step "PHASE 4: Uninstalling Packages"

print_info "Removing python3-validity, open-fprintd and fprintd-clients..."
sudo apt remove --purge -y python3-validity open-fprintd fprintd-clients

print_success "Packages removed"

print_info "Removing orphan dependencies..."
sudo apt autoremove -y

print_success "Dependencies cleaned"

################################################################################
# PHASE 5: CLEAN RESIDUAL FILES
################################################################################

print_step "PHASE 5: Cleaning Residual Files"

# Remove residual directories
RESIDUAL_DIRS=(
    "/usr/share/python-validity"
    "/etc/python-validity"
    "/usr/lib/python-validity"
)

for DIR in "${RESIDUAL_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        print_info "Removing $DIR..."
        sudo rm -rf "$DIR"
        print_success "Removed: $DIR"
    fi
done

# Remove udev power rule
UDEV_RULE_FILE="/etc/udev/rules.d/99-fingerprint-power.rules"
if [ -f "$UDEV_RULE_FILE" ]; then
    print_info "Removing udev power rule..."
    sudo rm -f "$UDEV_RULE_FILE"
    sudo udevadm control --reload-rules
    sudo udevadm trigger
    print_success "Udev rule removed"
fi

# Remove installer state files
print_info "Removing previous installation state files..."
rm -f "$HOME/.fingerprint_install_state"
rm -f "$HOME/.fingerprint_vendor_id"
rm -f "$HOME/.fingerprint_product_id"
print_success "State files removed"

print_success "Cleanup completed"

################################################################################
# PHASE 6: FINAL VERIFICATION
################################################################################

print_step "PHASE 6: Final Verification"

print_info "Checking if any related packages remain..."
REMAINING=$(dpkg -l | grep -E "(validity|fprintd)" || true)

if [ -z "$REMAINING" ]; then
    print_success "No related packages found"
else
    print_warning "Some related packages or files still exist:"
    echo "$REMAINING"
fi

################################################################################
# FINALIZATION
################################################################################

print_step "✓ Uninstallation Completed!"

echo ""
print_success "The fingerprint reader has been completely removed from the system."
echo ""
print_info "Your system now uses only password authentication."
print_info "Sudo and screen unlock should work normally."
echo ""
print_info "To reinstall in the future, use the script: install-fingerprint.sh"
echo ""
print_warning "If you kept the PPA, you can remove it with:"
echo "   sudo add-apt-repository --remove ppa:uunicorn/open-fprintd"
echo ""
