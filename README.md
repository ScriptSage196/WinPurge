# WinPurge - Advanced Windows Debloater/Tweaker

[![GitHub Stars](https://img.shields.io/github/stars/ScriptSage196/WinPurge?style=flat-square)](https://github.com/ScriptSage196/WinPurge)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](https://opensource.org/licenses/MIT)
[![PowerShell 7+](https://img.shields.io/badge/PowerShell-7.0%2B-blue?style=flat-square)](https://github.com/PowerShell/PowerShell)

WinPurge is a comprehensive Windows optimization tool that goes beyond traditional debloaters. It features complete AI feature removal, dry-run mode, detailed audit logging, a plugin system, and community presets.

## 🎯 Key Features

- **Complete AI Removal**: Remove Copilot, AI Search, and all AI integrations with CBS blocking to prevent reinstallation
- **Dry-Run Mode**: Preview ALL changes before applying them
- **Audit Logging**: Detailed JSON logs with one-click full rebloat capability
- **Performance Benchmarking**: Before/after system metrics (RAM, processes, disk usage)
- **Plugin System**: Drop .ps1 files in `plugins/` folder - they appear in the GUI
- **Community Presets**: Gaming, Minimal, Developer, Standard configurations (shareable as JSON)
- **Sysprep Ready**: Generate Unattend.xml for clean installations
- **Per-User Support**: Apply tweaks per-user or system-wide
- **CLI + GUI**: Full-featured command-line mode + modern WPF interface with ModernWpf
- **Post-Update Protection**: Scheduled task auto-removes AI features after Windows Updates
- **Multi-Language**: English, Hindi, and more to come
- **Advanced Security**: DNS over HTTPS, Spectre/Meltdown toggles, Modern Standby control

## 📋 System Requirements

- **Windows 10** 22H2 or later
- **Windows 11** 23H2 or later
- **PowerShell 7.0** or later
- Administrator privileges

## 🚀 Quick Start

### GUI Mode (Default)
```powershell
.\Main.ps1 -GUI
```

### Dry-Run (Preview Changes)
```powershell
.\Main.ps1 -Preset Gaming -DryRun
```

### Apply Preset
```powershell
.\Main.ps1 -Preset Minimal
```

### Headless/CLI Mode
```powershell
.\Main.ps1 -Headless -Preset Developer
```

### Compile to Standalone
```powershell
.\Compile.ps1 -OutputPath WinPurge-Standalone.ps1
```

## 📁 Project Structure

```
WinPurge/
├── src/
│   ├── Main.ps1                 # Entry point
│   ├── Core/                    # Core modules
│   │   ├── Logging.ps1
│   │   ├── Elevation.ps1
│   │   ├── DryRun.ps1
│   │   ├── AuditLog.ps1
│   │   ├── RestorePoint.ps1
│   │   ├── VersionCheck.ps1
│   │   └── Benchmark.ps1
│   ├── Tweaks/                  # Optimization tweaks
│   │   ├── Telemetry.ps1
│   │   ├── Bloatware.ps1
│   │   ├── Services.ps1
│   │   ├── Privacy.ps1
│   │   ├── Registry.ps1
│   │   ├── Network.ps1
│   │   ├── FileExplorer.ps1
│   │   ├── Taskbar.ps1
│   │   ├── StartMenu.ps1
│   │   └── WindowsUpdate.ps1
│   ├── AI/                      # AI feature removal
│   │   ├── AIProtection.ps1
│   │   ├── AIReinstallBlock.ps1
│   │   ├── PostUpdateCleanup.ps1
│   │   └── ClassicAppReplace.ps1
│   ├── Install/                 # Package management
│   │   ├── WingetHelper.ps1
│   │   └── Packages.json
│   ├── Iso/                     # DISM & Sysprep
│   │   ├── DisMHelper.ps1
│   │   └── UnattendGenerator.ps1
│   ├── Plugins/                 # Plugin system
│   │   ├── PluginLoader.ps1
│   │   └── PluginInterface.ps1
│   └── Presets/                 # Configuration presets
│       ├── PresetManager.ps1
│       └── Presets/
│           ├── Gaming.json
│           ├── Minimal.json
│           ├── Developer.json
│           └── Standard.json
├── plugins/                     # User-dropped custom plugins
├── Compile.ps1                  # Build standalone version
└── README.md
```

## 🧩 Module System

Every module follows these rules:
- ✅ `Function-Name` and `Undo-Function-Name` pairs
- ✅ `-DryRun`, `-Verbose`, `-Quiet` parameters on all tweaks
- ✅ Audit logging to JSON with timestamp, category, old/new values
- ✅ Reversible flag (true/false)
- ✅ Supports `-Preserve` to skip specific items
- ✅ Supports `-User` for per-user application
- ✅ Error handling with continue-on-failure
- ✅ Exported via `Export-ModuleMember`

## 🎮 Presets

### Gaming
- Aggressive optimization for gaming performance
- Disables telemetry, bloatware, unnecessary services
- Removes animations and visual effects
- Blocks AI features

### Minimal
- Maximum privacy and minimal footprint
- Removes ALL optional features and services
- Aggressive AI blocking
- DNS over HTTPS enabled

### Developer
- Keeps development tools and environments
- Enables hidden files and advanced options
- Optimizes for coding workflow
- Removes game-related bloatware

### Standard
- Balanced approach for general users
- Removes telemetry and obvious bloatware
- Maintains compatibility
- Safe defaults

## 🔧 Creating Custom Presets

```json
{
  "name": "MyPreset",
  "version": "2.0",
  "description": "My custom configuration",
  "tweaks": [
    {
      "name": "Disable Telemetry",
      "function": "Disable-Telemetry",
      "description": "Remove telemetry"
    },
    {
      "name": "Custom Tweak",
      "function": "My-CustomFunction",
      "params": { "Aggressive": true }
    }
  ]
}
```

## 🔌 Plugin System

Create a plugin by dropping a .ps1 file in `plugins/` folder:

```powershell
# plugins/MyPlugin.ps1
# Name: My Custom Plugin
# Description: Does something awesome

function Invoke-MyPlugin {
    Write-Host "Running custom plugin"
    # Your code here
}
```

Plugins automatically appear in GUI tabs and CLI menus.

## 📊 Audit Logging

All changes are logged to `%TEMP%\WinPurge_audit.json`:

```json
[
  {
    "timestamp": "2024-01-15 14:30:22",
    "category": "Telemetry",
    "target": "DiagTrack",
    "oldValue": "Running",
    "newValue": "Disabled",
    "command": "Set-Service -Name DiagTrack -StartupType Disabled",
    "reversible": true,
    "success": true,
    "isDryRun": false
  }
]
```

## 🔄 One-Click Rebloat

Restore your system to pre-WinPurge state:

```powershell
# In GUI: Settings → Audit Log → Restore
# Via CLI:
Invoke-Rebloat -AuditLogPath "%TEMP%\WinPurge_audit.json"
```

## 🛡️ Differential Features vs WinUtil

| Feature | WinPurge | WinUtil |
|---------|----------|----------|
| AI Removal + CBS Blocking | ✅ | ❌ |
| Post-Update Auto-Cleanup | ✅ | ❌ |
| True Dry-Run with Diff | ✅ | ⚠️ |
| JSON Audit Log | ✅ | ❌ |
| Before/After Benchmarking | ✅ | ❌ |
| Plugin System | ✅ | ❌ |
| Preset Sharing (JSON) | ✅ | ⚠️ |
| Sysprep/Unattend.xml | ✅ | ⚠️ |
| Per-User Tweaks | ✅ | ⚠️ |
| Multi-Language | ✅ | ⚠️ |
| Headless CLI | ✅ | ✅ |

## ⚠️ Safety Notes

- **Always use `-DryRun` first** to preview changes
- **Create a restore point** before applying changes (automatic)
- **Use presets** instead of random tweaks if unsure
- **Test in VM** before applying to production machines
- **Read the audit log** to understand what changed

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add undo functions for all changes
4. Include audit logging
5. Test with `-DryRun` mode
6. Submit a pull request

## 📝 License

MIT License - See LICENSE file

## 🙏 Credits

Inspired by [ChrisTitusTech/winutil](https://github.com/ChrisTitusTech/winutil) but designed as a more comprehensive alternative with AI focus.

## 📧 Support

For issues, questions, or feature requests, please open a GitHub issue.

---

**Last Updated**: 2024
**Status**: Active Development
**Latest Version**: 2.0
