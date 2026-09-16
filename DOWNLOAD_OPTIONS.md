# WinPurge v1.0.0 - Download Options

## 🚀 Quick Start

Choose your preferred installation method below:

---

## 1️⃣ **Standalone PowerShell Script (Recommended)**

### Download
- **File**: `WinPurge-v1.0.0-Standalone.ps1`
- **Size**: ~16 KB
- **Requirements**: PowerShell 7.0+, Administrator privileges
- **Platform**: Windows 10 22H2+, Windows 11 23H2+

### Installation

```powershell
# Step 1: Download the file from Releases
# Step 2: Right-click PowerShell and select "Run as Administrator"
# Step 3: Run the script

.\\WinPurge-v1.0.0-Standalone.ps1 -GUI
```

### Usage Examples

```powershell
# Launch Interactive GUI (Default)
.\\WinPurge-v1.0.0-Standalone.ps1 -GUI

# Apply Gaming preset with dry-run (preview changes)
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming -DryRun

# Apply Gaming preset (actually make changes)
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming

# Apply Minimal preset
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Minimal

# Apply Developer preset
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Developer

# Apply Standard preset
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Standard

# Headless mode (no GUI, direct application)
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming -Headless
```

**Advantages:**
- ✅ Single file - easy to download and run
- ✅ No dependencies - everything included
- ✅ Portable - works from any location
- ✅ No installation required
- ✅ Easy to backup and share

---

## 2️⃣ **Clone Full Repository**

### Download

```bash
git clone https://github.com/ScriptSage196/WinPurge.git
cd WinPurge
```

### Run from Repository

```powershell
# Launch with GUI
.\\Main.ps1 -GUI

# Apply preset
.\\Main.ps1 -Preset Gaming

# Dry-run mode
.\\Main.ps1 -Preset Minimal -DryRun
```

### Build Standalone Version

```powershell
# Compile all modules into single script
.\\Compile.ps1 -OutputPath WinPurge-Compiled.ps1

# Run compiled version
.\\WinPurge-Compiled.ps1 -GUI
```

**Advantages:**
- ✅ Full source code access
- ✅ Can modify and extend
- ✅ Plugin system available
- ✅ Build custom versions
- ✅ Contribute back to project

---

## 3️⃣ **Download via PowerShell**

```powershell
# Download directly to current directory
$url = 'https://github.com/ScriptSage196/WinPurge/releases/download/v1.0.0/WinPurge-v1.0.0-Standalone.ps1'
Invoke-WebRequest -Uri $url -OutFile 'WinPurge-v1.0.0-Standalone.ps1'

# Make executable and run
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\\WinPurge-v1.0.0-Standalone.ps1 -GUI
```

---

## Available Presets

### 🎮 **Gaming**
- **Purpose**: Maximum performance for gaming
- **Changes**: Disables telemetry, removes bloatware, optimizes services, removes AI
- **Risk Level**: ⚠️ Medium (aggressive optimizations)

```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming -DryRun  # Preview first!
```

### 🔒 **Minimal**
- **Purpose**: Maximum privacy and minimal footprint
- **Changes**: Aggressive telemetry removal, extensive bloatware cleanup, minimal services
- **Risk Level**: ⚠️ High (most changes)

```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Minimal -DryRun
```

### 👨‍💻 **Developer**
- **Purpose**: Optimized for software development
- **Changes**: Keeps dev tools, removes game bloatware, enables advanced options
- **Risk Level**: ✅ Low (minimal changes)

```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Developer
```

### 📊 **Standard**
- **Purpose**: Balanced optimization for general users
- **Changes**: Removes obvious bloatware, disables telemetry, maintains compatibility
- **Risk Level**: ✅ Low (conservative)

```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Standard
```

---

## ⚠️ Important Notes

### Before Running

1. **Always use `-DryRun` first** to preview changes:
   ```powershell
   .\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming -DryRun
   ```

2. **Create a system restore point** (automatic but confirm):
   - Windows will create one automatically
   - You can manually create one via System Protection settings

3. **Run as Administrator**:
   - Right-click PowerShell → "Run as Administrator"
   - Or use: `powershell -RunAs`

4. **Review the audit log**:
   - Located at: `%TEMP%\\WinPurge_audit.json`
   - Shows all changes made
   - Can be used to undo changes

### Undo Changes

All changes are reversible through the audit log:

```powershell
# The audit log is saved at:
# %TEMP%\\WinPurge_audit.json

# Open it to see what changed
cat $env:TEMP\\WinPurge_audit.json | ConvertFrom-Json

# Manually reverse changes if needed
# Each entry includes the old value and the command used
```

---

## System Requirements

✅ **Windows 10**: Version 22H2 or later
✅ **Windows 11**: Version 23H2 or later
✅ **PowerShell**: Version 7.0 or later
✅ **Administrator Rights**: Required for most changes
✅ **RAM**: Minimum 4 GB (8 GB recommended)
✅ **Storage**: ~50 MB free space

### Check Your PowerShell Version

```powershell
$PSVersionTable.PSVersion
```

If you have PowerShell 5.1, upgrade to PowerShell 7:
```powershell
iex \"& { \$(irm https://aka.ms/install-powershell.ps1) } -UseMSI\"
```

---

## Features Included

### Core Features
- 🔧 **Dry-Run Mode**: Test changes without applying them
- 📋 **Audit Logging**: JSON logs of all changes
- 🔄 **System Restore Points**: Automatic backup creation
- 🚀 **Fast Execution**: Optimized for speed
- 🛡️ **Safe Mode**: Continues on errors

### Optimization Categories

- **Telemetry Removal**: Disable tracking and diagnostics
- **Bloatware Removal**: Remove unnecessary apps
- **Service Optimization**: Disable unneeded services
- **Privacy Hardening**: Enhanced privacy settings
- **AI Feature Removal**: Remove Copilot and AI features
- **Registry Optimization**: Safe registry modifications
- **Performance Tuning**: Optimize for speed

---

## Troubleshooting

### PowerShell Execution Policy Error

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Script Won't Run

1. Ensure PowerShell is running as Administrator
2. Check PowerShell version: `$PSVersionTable.PSVersion`
3. Unblock the file: `Unblock-File -Path .\\WinPurge-v1.0.0-Standalone.ps1`

### Antivirus False Positive

- Add to antivirus whitelist
- Build from source using `Compile.ps1`
- The script is completely open-source and safe

---

## Support & Issues

- 📧 **Issues**: https://github.com/ScriptSage196/WinPurge/issues
- 💬 **Discussions**: https://github.com/ScriptSage196/WinPurge/discussions
- 📚 **Documentation**: https://github.com/ScriptSage196/WinPurge/wiki

---

## License

MIT License - See LICENSE file in repository

---

**Version**: 1.0.0  
**Release Date**: September 16, 2026  
**Status**: Stable
