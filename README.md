# Swell (iOS 26 AlarmKit Branch)

**⚠️ Experimental Branch: iOS 26 AlarmKit Integration**

This branch contains AlarmKit integration for system-level alarms that bypass Silent mode and Focus modes on iOS 26+.

**BusRun / Swell** — Bus Alarm for Singapore. Never miss your bus again.

## What's Different from Main

| Feature | Main Branch | This Branch |
|---------|-------------|-------------|
| Min iOS Version | 16.1 | 26.0 |
| Alarms | Local Notifications | AlarmKit System Alarms |
| Silent Mode Bypass | ❌ | ✅ |
| Focus Mode Bypass | ❌ | ✅ |
| Full-screen Alarm UI | ❌ | ✅ |
| Apple Watch Support | ❌ | ✅ |

## Core Features

- 🚌 Real-time bus arrival via LTA DataMall API
- ⏱️ Live Activity countdown on Lock Screen & Dynamic Island
- 🔔 Smart alarms with configurable warnings (2/5/10 min)
- 🎯 Background monitoring with location updates
- 📍 Save favorite stops & routes
- ⏰ **AlarmKit system alarms** — fire even if app killed

## Quick Start

### Requirements
- macOS with **Xcode 26.0 beta**
- iOS 26.0 beta Simulator or device
- AlarmKit framework (bundled with iOS 26 SDK)

### Build
```bash
git clone https://github.com/tsuwave/BusAlarm.git
cd BusAlarm
git checkout ios26-alarmkit
cp Config/Secrets.template.xcconfig Config/Secrets.xcconfig
# Add your LTA API key to Config/Secrets.xcconfig
xcodegen generate
open BusAlarm.xcodeproj
```

## AlarmKit Overview

AlarmKit (iOS 26+) provides:
- System-level alarms that fire even if app is killed
- Bypasses Silent mode and all Focus modes
- Full-screen alarm UI with snooze/stop
- Lock Screen, Dynamic Island, and Apple Watch visibility
- No special Apple entitlement required (unlike Critical Alerts)

## Implementation Status

- [x] AlarmKitService with full API structure
- [x] Info.plist NSAlarmKitUsageDescription
- [x] BusMonitorService integration
- [ ] Actual AlarmKit framework import (verify with Xcode 26)
- [ ] Test on real iOS 26 device

## GitHub Actions CI

This branch uses GitHub Actions for cloud builds:
- **Build workflow**: Runs on every push
- Trigger: `.github/workflows/build.yml`

## TestFlight Distribution

Use the deploy workflow (requires Apple Developer secrets):
1. Go to Actions tab → Deploy to TestFlight
2. Click "Run workflow"
3. Enter version and build number

## Backwards Compatibility

This branch maintains a fallback to Local Notifications for:
- Pre-iOS 26 devices
- If AlarmKit permission is denied
- If AlarmKit scheduling fails

## Migration from Main

The main changes are in:
- `TsuWave/Features/Alarm/AlarmKitService.swift` — Full AlarmKit implementation
- `TsuWave/Core/Services/BusMonitorService.swift` — AlarmKit integration points
- `TsuWave/Resources/Info.plist` — NSAlarmKitUsageDescription

## Test Bus Stops

- `59009` — Orchard (Bus 14)
- `75009` — Tampines (Bus 31)
- `46009` — Woodlands

---

⚠️ **Note:** AlarmKit APIs are based on preliminary documentation and may change. Verify with latest iOS 26 SDK before shipping.

Built with 🌊 by TsuWave
