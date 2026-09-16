# WinPurge v1.0.0 - Quick Start Guide

## ⚡ 5-Minute Setup

### Step 1: Download (30 seconds)

**Option A: Direct Download**
- Download `WinPurge-v1.0.0-Standalone.ps1` from Releases
- Size: ~16 KB
- No dependencies needed

**Option B: PowerShell Download**
```powershell
$url = 'https://github.com/ScriptSage196/WinPurge/releases/download/v1.0.0/WinPurge-v1.0.0-Standalone.ps1'
Invoke-WebRequest -Uri $url -OutFile 'WinPurge-v1.0.0-Standalone.ps1'
```

### Step 2: Run as Administrator (1 minute)

1. Right-click on PowerShell
2. Select "Run as Administrator"
3. Navigate to the script location

```powershell
cd C:\\Users\\YourName\\Downloads
.\\WinPurge-v1.0.0-Standalone.ps1 -GUI
```

### Step 3: Preview Changes (2 minutes) - **IMPORTANT!**

Before making any actual changes, always preview:

```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming -DryRun
```

This shows you exactly what will change WITHOUT applying changes.

### Step 4: Apply Changes (1-2 minutes)

Once satisfied with the preview:

```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming
```

---

## 🎯 Choose Your Preset

### For Gamers
```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming -DryRun
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming
```
**What it does**: Aggressive optimization for maximum FPS

### For Privacy Warriors
```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Minimal -DryRun
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Minimal
```
**What it does**: Remove telemetry, bloatware, and surveillance

### For Developers
```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Developer -DryRun
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Developer
```
**What it does**: Safe optimizations, keeps dev tools

### For Regular Users
```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Standard -DryRun
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Standard
```
**What it does**: Balanced, conservative optimizations

---

## 📋 Common Commands

### Interactive Mode (GUI)
```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -GUI
```

### Preview Mode (Always Do First)
```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming -DryRun
```

### Apply Changes
```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming
```

### Headless/CLI Mode (No GUI)
```powershell
.\\WinPurge-v1.0.0-Standalone.ps1 -Preset Gaming -Headless
```

---

## ✅ What Gets Optimized

### Disabled by Default ✋
- Telemetry services (DiagTrack, etc.)
- Bloatware apps
- Unnecessary Windows services
- AI features (Copilot, AI Search)

### Your Data Is Safe 🔒
- No data collection from WinPurge
- No tracking
- Open source (you can review the code)
- MIT License (free, commercial use OK)

### Automatic Safety Features 🛡️
- System restore point created automatically
- All changes logged in JSON format
- Can be undone by loading audit log
- Continues on errors (won't crash)

---

## 📂 Where Are My Files?

### Audit Log Location
```
%TEMP%\\WinPurge_audit.json
```

**Show audit log:**
```powershell
cat $env:TEMP\\WinPurge_audit.json | ConvertFrom-Json | Format-Table
```

### Script Location
Wherever you downloaded/ran it from

---

## ⚠️ Before You Start

### Requirements
- ✅ Windows 10 (version 22H2) or Windows 11 (version 23H2)
- ✅ PowerShell 7.0 or later
- ✅ Administrator access
- ✅ Internet connection (for downloads)

### Check PowerShell Version
```powershell
$PSVersionTable.PSVersion
```

If you see 5.x, upgrade:
```powershell
iex \"& { \$(irm https://aka.ms/install-powershell.ps1) } -UseMSI\"
```

### Execution Policy
If you get an execution policy error:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 🚨 Emergency Undo

If something goes wrong:

### Option 1: System Restore
1. Press Win + R
2. Type: `rstrui`
3. Restore to point before WinPurge

### Option 2: Manual Undo
```powershell
# Review what changed
cat $env:TEMP\\WinPurge_audit.json | ConvertFrom-Json

# Manually revert specific services
Set-Service -Name DiagTrack -StartupType Automatic
Start-Service -Name DiagTrack
```

---

## 📞 Need Help?

### Check These First
1. **Did you use `-DryRun`?** (Always preview first!)
2. **Are you admin?** (Right-click → Run as Administrator)
3. **PowerShell 7+?** (Check version above)
4. **Windows 10/11?** (Earlier versions not supported)

### Get Support
- **Issues**: https://github.com/ScriptSage196/WinPurge/issues
- **Discussions**: https://github.com/ScriptSage196/WinPurge/discussions
- **Wiki**: https://github.com/ScriptSage196/WinPurge/wiki

---

## 🎉 Next Steps

1. ✅ Download the standalone script
2. ✅ Run as Administrator
3. ✅ Choose your preset
4. ✅ Use `-DryRun` to preview
5. ✅ Apply the changes
6. ✅ Enjoy optimized Windows!

---

**Version**: 1.0.0  
**Last Updated**: September 16, 2026  
**License**: MIT
