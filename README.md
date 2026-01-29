# Random Timer

Random Timer is a simple, “picky-friendly” random countdown timer: instead of alerting after a fixed interval, it alerts at a **random moment within a range** you choose. It’s built with SwiftUI for iOS, watchOS, and macOS.

> © 2026 Kirstyn Piper Plummer. All rights reserved.

## Features

- Pick a **minimum** and **maximum** duration, then start a timer that ends at a random time in that range
- Clear countdown + progress
- Alarm that **rings until acknowledged**
- Multiple alarm sounds with a selector in Settings
- iOS ⇄ watchOS sync via WatchConnectivity (mirrors timer state)

## Alarm Sounds

Included alarm sounds live in the Shared resources and are bundled into the iOS/macOS apps:

- Soft Chime
- Classic Beep
- Urgent Siren

## Support the Developer

If you enjoy the project and want to support ongoing development:

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
