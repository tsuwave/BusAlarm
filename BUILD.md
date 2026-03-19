# How to Build

## Prerequisites

- macOS with Xcode 14.0+
- iOS 16.1+ Simulator or device (for Live Activities)
- LTA DataMall API key

## Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/tsuwave/tsuwave.git
   cd tsuwave
   ```

2. **Add your API key**
   ```bash
   cp Config/Secrets.template.xcconfig Config/Secrets.xcconfig
   # Edit Config/Secrets.xcconfig and add your LTA API key
   ```

3. **Open in Xcode**
   - Open `TsuWave.xcodeproj` in Xcode
   - Select your team for signing
   - Build and run

## Creating the Xcode Project

Since this repo doesn't include the `.xcodeproj` file (to avoid merge conflicts), you'll need to create it:

### Option 1: Use the provided script
```bash
./scripts/setup-project.sh
```

### Option 2: Manual setup
1. Open Xcode
2. File → New → Project → iOS App
3. Name: "TsuWave"
4. Organization: Your name or "TsuWave"
5. Bundle ID: `com.tsuwave.swell`
6. Interface: SwiftUI
7. Language: Swift
8. Target: iOS 16.1+

Then:
- Delete the auto-generated files
- Add all files from this repo
- Add Widget Extension target for Live Activities
- Link the Config/Secrets.xcconfig in build settings

## Running

- Select iPhone 14 Pro or newer (for Dynamic Island support)
- Press Run

Test with these bus stops:
- `59009` - Orchard (Bus 14)
- `75009` - Tampines (Bus 31)

## Archive & TestFlight

1. Product → Archive
2. Distribute App → App Store Connect
3. Upload and process
4. Add to TestFlight internal testing
