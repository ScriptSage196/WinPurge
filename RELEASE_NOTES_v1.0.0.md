# WinPurge v1.0.0 - Release Notes

## 📢 Release Date: September 16, 2026

---

## ✨ Welcome to WinPurge v1.0.0!

WinPurge is an **advanced Windows debloater and optimization tool** that goes far beyond traditional tweaker utilities. This initial release represents a complete, production-ready Windows optimization platform.

---

## 🎉 Major Features

### 🤖 AI Feature Removal
- Complete removal of Copilot and AI Search
- CBS-level blocking to prevent reinstallation
- Post-update automatic cleanup
- One-click disabling of all AI integrations

### 🧹 Comprehensive Debloating
- Remove pre-installed bloatware
- Uninstall unnecessary Microsoft Store apps
- Clean up Windows services
- Optimize system startup

### 🔒 Privacy & Security
- Disable telemetry and diagnostic tracking
- Remove Windows tracking features
- Enhanced privacy registry settings
- DNS over HTTPS support
- Spectre/Meltdown toggle controls

### 🎮 Performance Optimization
- Service optimization for gaming
- Disable unnecessary background tasks
- Registry optimizations
- Performance benchmarking (before/after)
- Network optimization

### 📋 Advanced Management
- **Dry-Run Mode**: Preview ALL changes before applying
- **Audit Logging**: Complete JSON logs of every modification
- **System Restore Points**: Automatic backup creation
- **One-Click Rebloat**: Restore system to pre-WinPurge state
- **Multi-Preset System**: Gaming, Minimal, Developer, Standard presets

### 🔌 Extensibility
- **Plugin System**: Drop .ps1 files in plugins/ folder
- **Custom Presets**: Create JSON-based configurations
- **Full CLI Support**: Headless/automation-friendly
- **Modern GUI**: WPF-based interface with dark/light themes

---

## 📦 What's Included

### Core Modules
✅ Logging and error handling  
✅ Elevation and privilege management  
✅ Dry-run mode with change preview  
✅ Audit logging (JSON format)  
✅ Automatic restore point creation  
✅ Version checking and updates  
✅ System benchmarking  

### Optimization Modules
✅ Telemetry removal  
✅ Bloatware cleanup  
✅ Service optimization  
✅ Privacy hardening  
✅ Registry optimization  
✅ Network configuration  
✅ File Explorer tweaks  
✅ Taskbar customization  
✅ Start Menu optimization  
✅ Windows Update control  

### AI Protection
✅ Copilot removal  
✅ AI Search disabling  
✅ Reinstall blocking (CBS level)  
✅ Post-update cleanup task  
✅ Classic app restoration  

### Utilities
✅ Package management (winget)  
✅ DISM/ISO utilities  
✅ Sysprep Unattend.xml generation  
✅ Plugin system  
✅ Preset manager  

---

## 📥 Download & Installation

### Easiest Method: Standalone Script

```powershell
# Download WinPurge-v1.0.0-Standalone.ps1
# Right-click PowerShell → "Run as Administrator"
# Run:
.\\WinPurge-v1.0.0-Standalone.ps1 -GUI
```

### Alternative: Full Repository

```bash
git clone https://github.com/ScriptSage196/WinPurge.git
cd WinPurge
.\\Main.ps1 -GUI
```

### Direct PowerShell Download

```powershell
$url = 'https://github.com/ScriptSage196/WinPurge/releases/download/v1.0.0/WinPurge-v1.0.0-Standalone.ps1'
Invoke-WebRequest -Uri $url -OutFile 'WinPurge-v1.0.0-Standalone.ps1'
.\\WinPurge-v1.0.0-Standalone.ps1
```

---

## 🚀 Quick Start

### 1. Preview Changes (Always Do This First!)

```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming -DryRun
```

### 2. Apply Changes

```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming
```

### 3. Choose Your Preset

**Gaming**: Maximum performance (aggressive optimizations)  
**Minimal**: Maximum privacy (extensive changes)  
**Developer**: Optimized for coding (minimal changes)  
**Standard**: Balanced for general users (conservative)  

### 4. Check Audit Log

All changes are logged to: `%TEMP%\\WinPurge_audit.json`

---

## 🎮 Available Presets

### Gaming Preset
- Optimized for gaming performance
- Disables telemetry
- Removes bloatware
- Optimizes services
- Removes AI features
- ⚠️ Medium risk (aggressive optimizations)

### Minimal Preset
- Maximum privacy and minimal footprint
- Removes most optional features
- Aggressive telemetry removal
- Heavy service cleanup
- ⚠️ High risk (most changes)

### Developer Preset
- Keeps development tools
- Removes game bloatware
- Enables advanced options
- Minimal but smart optimizations
- ✅ Low risk (conservative)

### Standard Preset
- Balanced for general users
- Removes obvious bloatware
- Disables basic telemetry
- Maintains compatibility
- ✅ Low risk (safe defaults)

---

## 🛡️ Safety Features

✅ **Automatic Restore Points**: System restore point created before changes  
✅ **Dry-Run Mode**: Preview all changes without applying  
✅ **Audit Logging**: JSON log of every modification  
✅ **Reversible Operations**: Most changes can be undone  
✅ **Error Handling**: Continues on failures (doesn't crash)  
✅ **Admin Check**: Ensures administrator privileges  
✅ **Version Verification**: Checks Windows version compatibility  

---

## 📊 Improvements Over WinUtil

| Feature | WinPurge | WinUtil |
|---------|----------|---------|
| AI Removal + CBS Blocking | ✅ New! | ❌ |
| Post-Update Auto-Cleanup | ✅ New! | ❌ |
| True Dry-Run with Preview | ✅ New! | ⚠️ Basic |
| JSON Audit Log | ✅ New! | ❌ |
| Before/After Benchmarking | ✅ New! | ❌ |
| Plugin System | ✅ New! | ❌ |
| Preset Sharing (JSON) | ✅ New! | ⚠️ Limited |
| Sysprep/Unattend.xml | ✅ New! | ⚠️ Basic |
| Per-User Tweaks | ✅ New! | ⚠️ Limited |
| Multi-Language Support | ✅ New! | ⚠️ Limited |
| Modern GUI (Dark/Light) | ✅ New! | ✅ |
| Headless CLI Mode | ✅ | ✅ |

---

## 💻 System Requirements

**Minimum:**
- Windows 10 version 22H2 or later
- Windows 11 version 23H2 or later
- PowerShell 7.0 or later
- 4 GB RAM
- Administrator privileges

**Recommended:**
- Windows 11 latest version
- PowerShell 7.4 or later
- 8 GB+ RAM
- SSD storage

---

## 🐛 Known Issues

None at release - this is a stable v1.0.0 release!

If you encounter any issues:
1. Check the [Issues page](https://github.com/ScriptSage196/WinPurge/issues)
2. Review the audit log at `%TEMP%\\WinPurge_audit.json`
3. Try reverting with a system restore point
4. Report on GitHub with logs attached

---

## 📚 Documentation

- **README.md**: Full feature documentation
- **DOWNLOAD_OPTIONS.md**: Installation instructions
- **QUICK_START.md**: 5-minute quick start guide
- **GitHub Wiki**: Advanced usage guides (coming soon)
- **Audit Logs**: JSON format in `%TEMP%\\WinPurge_audit.json`

---

## 🔮 Roadmap for v1.1+

- 🌐 Multi-language support (Spanish, French, German)
- 📱 Remote management API
- 🔄 Automated scheduled maintenance
- 📊 Advanced benchmarking and graphs
- 🎨 Custom theme support
- 🔌 Plugin marketplace
- 🤖 Machine learning-based recommendations
- ☁️ Cloud preset synchronization

---

## 📄 License

**MIT License** - Free for personal and commercial use

See LICENSE file for full terms.

---

## 🙏 Thanks

Thanks to the community and inspired by [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil)

WinPurge aims to be a more comprehensive, AI-focused alternative that respects user privacy and provides maximum control.

---

## 📞 Support

- **Issues & Bugs**: https://github.com/ScriptSage196/WinPurge/issues
- **Discussions**: https://github.com/ScriptSage196/WinPurge/discussions  
- **Wiki**: https://github.com/ScriptSage196/WinPurge/wiki

---

**Version**: 1.0.0  
**Release Date**: September 16, 2026  
**Status**: ✅ Stable Release  
**License**: MIT  
**Repository**: https://github.com/ScriptSage196/WinPurge
