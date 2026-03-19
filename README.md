# Swell (iOS 26 AlarmKit Branch)

**⚠️ Experimental Branch: iOS 26 AlarmKit Integration**

This branch contains AlarmKit integration for system-level alarms that bypass Silent mode and Focus modes on iOS 26+.

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
- ⏱️ Live Activity countdown on Lock Screen & Dynamic Island (iOS 16.1+)
- 🔔 Smart alarms with configurable warnings (2/5/10 min)
- 🎯 Background monitoring with location updates
- 📍 Save favorite stops & routes

## AlarmKit Overview

AlarmKit (iOS 26+) provides:
- System-level alarms that fire even if app is killed
- Bypasses Silent mode and all Focus modes
- Full-screen alarm UI with snooze/stop
- Lock Screen, Dynamic Island, and Apple Watch visibility
- No special Apple entitlement required (unlike Critical Alerts)

## Implementation Status

- [x] AlarmKitService stub with API structure
- [x] Info.plist NSAlarmKitUsageDescription
- [x] BusMonitorService integration points
- [ ] Actual AlarmKit framework import (waiting on Xcode 26)
- [ ] Real AlarmManager implementation
- [ ] Alarm scheduling/cancellation
- [ ] Background alarm persistence

## Building

This branch requires:
- macOS with Xcode 26.0 beta
- iOS 26.0 beta Simulator or device
- AlarmKit framework (bundled with iOS 26 SDK)

### Quick Start

1. Clone the repo
2. Copy `Config/Secrets.template.xcconfig` to `Config/Secrets.xcconfig`
3. Add your LTA DataMall API key from https://datamall.lta.gov.sg
4. Open `BusAlarm.xcodeproj` in Xcode 26
5. Build & run

## Migration from Main

The main changes are in:
- `TsuWave/Features/Alarm/AlarmKitService.swift` - Full implementation
- `TsuWave/Core/Services/BusMonitorService.swift` - AlarmKit integration
- `TsuWave/Resources/Info.plist` - NSAlarmKitUsageDescription

## Backwards Compatibility

This branch maintains a fallback to Local Notifications for:
- Pre-iOS 26 devices
- If AlarmKit permission is denied
- If AlarmKit scheduling fails

---

⚠️ **Note:** AlarmKit APIs are based on preliminary documentation and may change. Verify with latest iOS 26 SDK before shipping.

Built with 🌊 by TsuWave
