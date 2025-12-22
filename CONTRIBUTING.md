# Contributing Guide

Thank you for considering contributing to the Easy Fingerprint Installer! 🎉

## 🤝 How to Contribute

### Reporting Bugs

If you found a bug, please open an [issue](../../issues/new) including:

1. **System Information**
   - Linux distribution and version (e.g., Ubuntu 24.04)
   - Laptop model and brand (e.g., Dell XPS 13, ThinkPad T480)
   - Fingerprint reader ID (run: `lsusb | grep 06cb`)

2. **Problem Description**
   - What were you trying to do?
   - What did you expect to happen?
   - What actually happened?

3. **Relevant Logs**
   ```bash
   # Include the output of these commands:
   sudo journalctl -u python3-validity --since "10 minutes ago"
   systemctl status python3-validity
   cat ~/.fingerprint_install_state
   ```

4. **Steps to Reproduce**
   - List the exact commands you executed

### Reporting Success

Successful tests are equally important! If the script worked for you, please open an issue with the title:

**"[SUCCESS] Model X with Reader Y"**

And include:
- Laptop model and brand
- Reader ID (`lsusb | grep 06cb`)
- Linux distribution
- Any useful observations or tips

This helps other users know if their hardware is compatible!

### Suggesting Improvements

Have an idea to improve the project? Great!

1. Check if there isn't already an [open issue](../../issues) on the topic
2. Open a new issue with the prefix `[FEATURE]` in the title
3. Clearly describe:
   - What problem the feature solves
   - How it should work
   - Usage examples (if applicable)

### Submitting Pull Requests

#### Preparation

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/geekgil/easy-fingerprint-installer.git
   cd easy-fingerprint-installer
   ```

3. Create a branch for your change:
   ```bash
   git checkout -b feature/my-improvement
   # or
   git checkout -b fix/bug-fix
   ```

#### Development

**For Script Changes:**

1. Test extensively on a VM or test system
2. Verify it works on clean installation AND resume after reboot
3. Maintain existing code style:
   - Use 4 spaces for indentation
   - Comment complex code
   - Use functions for reusable logic
   - Descriptive error messages

**For Documentation Changes:**

1. Use correct Markdown
2. Check for broken links
3. Maintain friendly and educational tone
4. Include practical examples when possible

#### Commit

Use descriptive commit messages:

```bash
# Good ✅
git commit -m "Fix: Detect 'message type 16' error for firmware loading"
git commit -m "Feat: Add support for VFS5011 reader"
git commit -m "Docs: Update troubleshooting with frozen PAM case"

# Bad ❌
git commit -m "fix bug"
git commit -m "update"
git commit -m "changes"
```

Recommended prefixes:
- `Feat:` - New feature
- `Fix:` - Bug fix
- `Docs:` - Documentation only
- `Refactor:` - Code refactoring
- `Test:` - Add or fix tests
- `Chore:` - Maintenance tasks

#### Pull Request

1. Push to your fork:
   ```bash
   git push origin feature/my-improvement
   ```

2. Open a Pull Request on GitHub

3. Fill out the PR template with:
   - Clear description of the change
   - Motivation (why is it necessary?)
   - Tests performed
   - Screenshots (if applicable)
   - Related issues (if any)

## 📋 Pull Request Checklist

Before submitting, verify:

- [ ] Code follows project style
- [ ] Tested changes on real system or VM
- [ ] Updated documentation (if necessary)
- [ ] Added entry in CHANGELOG.md
- [ ] Code doesn't introduce shellcheck warnings
- [ ] Scripts remain executable (`chmod +x`)
- [ ] Commit messages are descriptive

## 🧪 Testing Your Changes

### Test Environment

Recommendations:
1. Use an **Ubuntu VM** for destructive tests
2. For real hardware tests, make **backups** first
3. Test on **clean** installation and **with existing state**

### Important Test Scenarios

1. **Clean Installation**
   ```bash
   rm -f ~/.fingerprint_*
   ./install-fingerprint.sh
   ```

2. **Resume After Reboot**
   ```bash
   # Run until it asks for reboot
   ./install-fingerprint.sh
   # Simulate reboot (don't actually restart)
   # Run again
   ./install-fingerprint.sh
   ```

3. **Reinstallation**
   ```bash
   ./uninstall-fingerprint.sh
   ./install-fingerprint.sh
   ```

4. **Sanity Check**
   ```bash
   # Manually uninstall packages
   sudo apt remove python3-validity
   # Run the installer
   ./install-fingerprint.sh
   # Should detect and reinstall
   ```

### Checking Code

```bash
# Use shellcheck for static analysis
shellcheck install-fingerprint.sh
shellcheck uninstall-fingerprint.sh

# Check permissions
ls -l *.sh
# Should be -rwxr-xr-x
```

## 🎨 Code Style

### Shell Script

```bash
# Good ✅
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

if [ "$CURRENT_STATE" -lt 3 ]; then
    print_info "Installing packages..."
    sudo apt install -y package-name
fi

# Bad ❌
printInfo(){
echo -e "${BLUE}[INFO]${NC} $1"
}

if [ "$CURRENT_STATE" -lt 3 ]
then
print_info "Installing packages..."
sudo apt install -y package-name
fi
```

### Documentation

**Good example ✅**

```markdown
## Problem: Script doesn't resume after reboot

**Solution:**
1. Check the state file
2. Run the script again

Example command:
    cat ~/.fingerprint_install_state
```

**Bad example ❌**

```markdown
## script doesnt work

check state file and run again
```

Documentation tips:
- Use clear and descriptive titles
- Provide command examples when relevant
- Maintain consistent formatting
- Write in clear and accessible language

## 📞 Questions?

If you have questions about how to contribute:

1. Open a [discussion issue](../../issues/new)
2. Mark it with the `question` label
3. Someone from the community will help! 😊

## 🙏 Acknowledgments

Every contribution is valuable, no matter the size:
- Reporting bugs helps improve quality
- Better documentation helps new users
- Testing on new hardware expands compatibility
- Code makes the project more robust

**Thank you for being part of this project!** 🎉

---

**Maintainer:** @geekgil  
**Last Update:** December 21, 2025
