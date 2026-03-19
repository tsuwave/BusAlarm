# Swell

**TsuWave | Bus Arrival Alarm for Singapore**

Never miss your bus again. Swell tracks your bus arrival in real-time and alerts you when it's time to head to the stop.

## Features

- 🚌 Real-time bus arrival via LTA DataMall API
- ⏱️ Live Activity countdown on Lock Screen & Dynamic Island
- 🔔 Smart alarms with 2/5/10 minute warnings
- 🎯 Background monitoring with location updates
- 📍 Save favorite stops & routes

## Requirements

- iOS 16.1+ (main branch)
- iOS 26+ (alarmkit branch - experimental)
- Xcode 14+
- LTA DataMall API key

## Setup

1. Clone the repo
2. Copy `Config/Secrets.template.xcconfig` to `Config/Secrets.xcconfig`
3. Add your LTA DataMall API key
4. Build & run

## Branches

- `main` — Stable version using Live Activities + Local Notifications (iOS 16.1+)
- `ios26-alarmkit` — Experimental AlarmKit integration (iOS 26+)

## Codename Origin

*Swell* — the wave building before it breaks. Just like your alarm swelling as the bus approaches.

---

Built with 🌊 by TsuWave
