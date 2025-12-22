# Git Repository Setup Guide

This guide helps you set up the Git repository correctly and upload it to GitHub.

## Step 1: Fix Permissions

The folder was created with root permissions. Let's fix it:

```bash
sudo chown -R $USER:$USER ~/Projects/easy-fingerprint-installer
```

## Step 2: Initialize Git Repository

```bash
cd ~/Projects/easy-fingerprint-installer

# Initialize Git with 'main' branch from the start
git init -b main
```

## Step 3: Add Files and Create Commit

```bash
# Add all project files
git add .

# Create the initial commit
git commit -m "Initial commit: Easy Fingerprint Installer v1.0

- Persistent state system (resumes after reboot)
- Intelligent firmware error detection
- Interactive menu for enrolling multiple fingers
- Robust sanity checks and validations
- Complete installation and uninstallation scripts
- Professional documentation (README, CHANGELOG, CONTRIBUTING)
- MIT License"
```

## Step 4: Create Repository on GitHub

1. Go to: https://github.com/new
2. Fill in:
   - **Repository name:** `easy-fingerprint-installer`
   - **Description:** `Automated python-validity driver installation for Synaptics/Validity fingerprint readers on Linux laptops`
   - **Visibility:** Public
   - ⚠️ **DO NOT** check "Add a README file" (we already have one!)
   - ⚠️ **DO NOT** check "Add .gitignore" (we already have one!)
   - ⚠️ **DO NOT** choose a license (we already have MIT!)
3. Click **"Create repository"**

## Step 5: Connect and Push to GitHub

```bash
# Add the GitHub remote
git remote add origin https://github.com/geekgil/easy-fingerprint-installer.git

# Push the files
git push -u origin main
```

## Step 6: Share!

Your repository will be at:
```
https://github.com/geekgil/easy-fingerprint-installer
```

Share it with your friends! 🚀

---

## Troubleshooting

### Error: "Permission denied"

If you get permission errors when pushing, configure authentication:

**Option 1: SSH (Recommended)**
```bash
# Generate an SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "gilvalente@ufmg.br"

# Copy the public key
cat ~/.ssh/id_ed25519.pub

# Paste it at: https://github.com/settings/keys

# Change the remote to SSH
git remote set-url origin git@github.com:geekgil/easy-fingerprint-installer.git
```

**Option 2: Personal Access Token**
```bash
# Create a token at: https://github.com/settings/tokens
# Check only the 'repo' scope
# Use the token as password when running git push
```

### Error: "Branch main doesn't exist on remote"

This is normal if GitHub created the repo with master branch. Force push:

```bash
git push -u origin main --force
```

---

**After setup, you can delete this file:**
```bash
rm ~/Projects/easy-fingerprint-installer/SETUP.md
```
