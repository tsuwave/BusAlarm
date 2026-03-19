# BusRun / Swell

**Bus Alarm for Singapore**

Never miss your bus again. BusRun tracks your bus arrival in real-time and alerts you when it's time to head to the stop.

Codename: **Swell** — the wave building before it breaks.

## Features

- 🚌 Real-time bus arrival via LTA DataMall API
- ⏱️ Live Activity countdown on Lock Screen & Dynamic Island (iOS 16.1+)
- 🔔 Smart alarms with configurable warnings (2/5/10 min)
- 🎯 Background monitoring with location updates
- 📍 Save favorite stops & routes

## Quick Start (Build for Simulator)

1. **Clone**
   ```bash
   git clone https://github.com/tsuwave/BusAlarm.git
   cd BusAlarm
   ```

2. **Add API Key**
   ```bash
   cp Config/Secrets.template.xcconfig Config/Secrets.xcconfig
   # Edit Config/Secrets.xcconfig and add your LTA API key
   ```

3. **Open & Build**
   - Open `BusAlarm.xcodeproj` in Xcode 15 or 16
   - Select iPhone 15 Pro simulator
   - Press Cmd+R

## Getting LTA API Key

1. Go to https://datamall.lta.gov.sg/content/datamall/en/request-for-api.html
2. Register an account
3. Request API access
4. Copy your Account Key

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

> **Note**: Requires an active Apple Developer account ($99/year) to generate certificates and API keys.

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

## Branches

- `main` — **Ready now** — iOS 16.1+ with Live Activities + Local Notifications
- `ios26-alarmkit` — Experimental — iOS 26+ with AlarmKit system alarms

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
│   ├── Alarm/          # Alarm service (stubs in main)
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

---

Built with 🌊 by TsuWave
