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

## GitHub Actions CI/CD

We use GitHub Actions for automated builds and TestFlight deployment.

### Automatic Build

Every push to `main` or `ios26-alarmkit` triggers a build:
- View status: https://github.com/tsuwave/BusAlarm/actions

### TestFlight Deployment (Manual)

1. Go to Actions → "Deploy to TestFlight"
2. Click "Run workflow"
3. Enter version (e.g., 1.0.0) and build number
4. Click "Run workflow"

### Required GitHub Secrets

Add these in GitHub → Settings → Secrets → Actions:

| Secret | Value | How to Get |
|--------|-------|------------|
| `LTA_API_KEY` | Your LTA DataMall API key | https://datamall.lta.gov.sg |
| `CERTIFICATES_P12` | Base64-encoded Apple Distribution certificate | Export from Keychain |
| `CERTIFICATES_PASSWORD` | Certificate export password | Set when exporting |
| `APPSTORE_ISSUER_ID` | App Store Connect Issuer ID | App Store Connect → Users → Keys |
| `APPSTORE_KEY_ID` | App Store Connect Key ID | App Store Connect → Users → Keys |
| `APPSTORE_PRIVATE_KEY` | App Store Connect private key content | Download from App Store Connect |

**Who sets this up**: [@ajmalafif](https://github.com/ajmalafif) (Apple Developer account holder)

> **Note**: [@macminimaru](https://github.com/macminimaru) (agent) maintains the codebase but does not have Apple Developer membership. TestFlight deployment requires @ajmalafif's developer credentials.

## Manual TestFlight Distribution

If not using GitHub Actions:

1. **Set up signing**
   - In Xcode, select BusAlarm target
   - Go to Signing & Capabilities
   - Select your Team
   - Update Bundle Identifier (e.g., `com.yourname.busrun`)

2. **Archive**
   - Select target device: "Any iOS Device"
   - Product → Archive

3. **Upload**
   - In Organizer, select the archive
   - Distribute App → App Store Connect → Upload

4. **TestFlight**
   - Go to App Store Connect
   - Select your app → TestFlight
   - Add internal testers

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

## Project Structure

```
TsuWave/
├── App/                 # SwiftUI app entry point
├── Core/
│   ├── API/            # LTA API client
│   ├── Models/         # Data models
│   └── Services/       # Bus monitoring service
├── Features/
│   ├── Alarm/          # AlarmKit implementation
│   └── LiveActivity/   # Live Activity widget
└── Resources/          # Info.plist, Assets
```

## Regenerating Xcode Project

If you modify `project.yml`:

```bash
xcodegen generate
```

## Known Limitations

- Background refresh limited by iOS (15 min - 6 hours)
- Location-based polling used for more frequent updates
- Requires "Always" location permission for best results
- TestFlight requires Apple Developer account ($99/year)
- **iOS 26 beta required** for AlarmKit features

## Contributors

| Role | GitHub | Responsibilities |
|------|--------|------------------|
| Product Owner | [@ajmalafif](https://github.com/ajmalafif) | Apple Developer account, TestFlight deployment, requirements |
| Agent Developer | [@macminimaru](https://github.com/macminimaru) | Code maintenance, CI/CD setup, bug fixes |

---

⚠️ **Note:** AlarmKit APIs are based on preliminary documentation and may change. Verify with latest iOS 26 SDK before shipping.

Built with 🌊 by TsuWave
