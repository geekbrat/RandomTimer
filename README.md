# Random Timer

[![CI](https://github.com/geekbrat/RandomTimer/actions/workflows/objective-c-xcode.yml/badge.svg)](https://github.com/geekbrat/RandomTimer/actions/workflows/objective-c-xcode.yml)
![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20watchOS-blue)
![Apple Watch](https://img.shields.io/badge/Apple%20Watch-compatible-000000?logo=apple&logoColor=white)

Random Timer is a simple, “picky-friendly” random countdown timer: instead of alerting after a fixed interval, it alerts at a **random moment within a range** you choose. It’s built with SwiftUI for iOS, watchOS, and macOS.

> © 2026 Kirstyn Piper Plummer. All rights reserved.


## About Random Timer

Random Timer is a deliberately simple tool designed to interrupt predictability.

Instead of a fixed interval, it alerts you at a random moment within a range you choose. That unpredictability can help with focus breaks, habit disruption, accessibility cues, and any workflow that benefits from time prompts you can’t anticipate.
<img width="2556" height="1178" alt="iPhone 16-03_About" src="https://github.com/user-attachments/assets/ea170f3c-1b30-49df-95c2-9e75bd8deaf8" />

## Features

- Pick a **minimum** and **maximum** duration, then start a timer that ends at a random time in that range
- Clear countdown + progress
- Alarm that **rings until acknowledged**
- Multiple alarm sounds with a selector in Settings
- iOS ⇄ watchOS sync via WatchConnectivity (mirrors timer state)
  
<img width="2556" height="1178" alt="iPhone 16-01_Home" src="https://github.com/user-attachments/assets/ce1c7f79-a6e7-4e10-b477-726c52d3291f" />

## Alarm Sounds

Included alarm sounds live in the Shared resources and are bundled into the iOS/macOS apps:

- Soft Chime
- Classic Beep
- Urgent Siren

<img width="2556" height="1178" alt="iPhone 16-02_Settings" src="https://github.com/user-attachments/assets/28d69f43-d740-42ec-b85a-fc1c6d2a45b0" />

## Support the Developer

If you enjoy Random Timer and want to help support continued development, you can support the developer.

- **iOS / Mac App Store builds:** tip-jar uses StoreKit (App Store compliant)
- **Direct-download macOS builds:** an optional “gift” link can be enabled at build time

Optional gift link (external):
- https://paypal.biz/REPlummer

## Build & Run (Xcode 16)

1. Open `RandomTimer.xcodeproj`
2. Select your Team under **Signing & Capabilities** for:
   - RandomTimeriOS
   - RandomTimerWatchOS Watch App
   - (macOS target if present)
3. Run the **Watch App** scheme once (installs the watch app)
4. Run **RandomTimeriOS**

### Bundle ID rules for watchOS

The Watch App bundle ID must be prefixed by the iOS app bundle ID:

- iOS: `KirstynPlummer.RandomTimeriOS`
- Watch App: `KirstynPlummer.RandomTimeriOS.watchkitapp`

## Repository Layout

- `Shared/` – cross-platform SwiftUI + shared services (timer model, connectivity, audio)
- `RandomTimeriOS/` – iOS app target
- `RandomTimerWatchOS Watch App/` – watchOS app target
- `RandomTimer/` – macOS target (if included)

## License

All rights reserved. This repository is provided for reference and personal use unless you have explicit permission from the author.
