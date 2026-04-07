<p align="center">
  <img src="docs/icon.svg" width="128" height="128" alt="Light Up My Life icon">
</p>

<h1 align="center">Light Up My Life</h1>

<p align="center">
  <strong>Unlock the full brightness of your MacBook Pro XDR display.</strong><br>
  Free & open-source. Up to 1,600 nits. No subscription. No nonsense.
</p>

<p align="center">
  <a href="https://github.com/ben4mn/light-up-my-life/releases"><img src="https://img.shields.io/github/v/release/ben4mn/light-up-my-life?style=flat-square&color=F2A900" alt="Release"></a>
  <a href="LICENSE"><img src="https://img.shields.io/github/license/ben4mn/light-up-my-life?style=flat-square" alt="License"></a>
  <img src="https://img.shields.io/badge/platform-macOS%2013%2B-blue?style=flat-square" alt="Platform">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange?style=flat-square&logo=swift&logoColor=white" alt="Swift">
</p>

<p align="center">
  <a href="https://ben4mn.github.io/light-up-my-life">Website</a> &bull;
  <a href="#install">Install</a> &bull;
  <a href="#how-it-works">How It Works</a> &bull;
  <a href="#build-from-source">Build</a>
</p>

---

## Why?

Your MacBook Pro has an XDR display capable of **1,600 nits** of brightness — but macOS only lets you use ~500 nits for everyday tasks. The extra brightness is locked behind HDR content playback.

**Light Up My Life** removes that limitation. Toggle it on and your entire screen gets brighter. Perfect for outdoor use, bright rooms, or just because you paid for those nits.

Apps like [Vivid](https://www.getvivid.app/) charge $10+ for this. We think it should be free.

## Features

- **Full XDR Brightness** — boost from 500 to 1,600 nits
- **Menu Bar App** — lives quietly in your menu bar, no dock icon
- **Brightness Slider** — fine-grained control over your boost level
- **Live Nits Display** — see exactly how bright your screen is
- **EDR Status** — shows boost percentage and max capability
- **Remembers Your Settings** — persists brightness level between launches
- **Sleep/Wake Aware** — automatically re-applies after your Mac wakes up
- **Multi-Display** — works across all connected XDR displays
- **Lightweight** — minimal CPU/GPU usage (~10 FPS solid color render)
- **No Permissions Needed** — no accessibility access, no admin privileges

## Requirements

| Requirement | Details |
|---|---|
| **macOS** | 13.0 (Ventura) or later |
| **Display** | MacBook Pro 14"/16" (2021+) or Pro Display XDR |
| **Chip** | Apple Silicon recommended (M1/M2/M3/M4) |

## Install

### Download

Grab the latest `.app` from [**Releases**](https://github.com/ben4mn/light-up-my-life/releases).

### Homebrew (coming soon)

```bash
brew install --cask light-up-my-life
```

## Build from Source

### Quick Build (recommended)

```bash
git clone https://github.com/ben4mn/light-up-my-life.git
cd light-up-my-life
./build.sh
open ".build/Light Up My Life.app"
```

### Xcode

```bash
open Package.swift
# Hit Cmd+R to build and run
```

### Swift CLI

```bash
swift build -c release
.build/release/LightUpMyLife
```

## How It Works

Light Up My Life uses a transparent [Metal](https://developer.apple.com/metal/) overlay window to activate your display's Extended Dynamic Range (EDR) mode:

1. A borderless, click-through window covers your screen
2. A `CAMetalLayer` renders in the `extendedLinearDisplayP3` color space
3. Color values above 1.0 tell the display to exceed standard brightness
4. A `multiply` compositing filter blends the boost with your screen content

This is the same mechanism your display uses for HDR video — we just apply it system-wide.

The overlay is invisible to screenshots (won't appear in screen recordings), doesn't intercept mouse events, and works across all Spaces and fullscreen apps.

## FAQ

**Will this damage my display?**
No. The XDR display is designed to output up to 1,600 nits. Apple uses this range for HDR content regularly. We're just letting you use what you already have.

**Does it affect battery life?**
Yes, higher brightness = more power. This is true whether you're using this app or watching an HDR video. The display is doing the same thing either way.

**Why not just use Night Shift or True Tone?**
Those adjust color temperature, not peak brightness. Light Up My Life boosts your actual light output.

**Does it work on external monitors?**
Only on displays that support EDR (like the Pro Display XDR). Standard external monitors will be skipped automatically.

## Tech Stack

- **Swift 5.9+** with **SwiftUI** for the popover UI
- **Metal** / **MetalKit** for EDR rendering
- **Swift Package Manager** for builds
- Zero external dependencies

## Contributing

PRs welcome! The codebase is intentionally small and simple:

```
Sources/LightUpMyLife/
├── LightUpMyLifeApp.swift   # App entry point (MenuBarExtra)
├── ContentView.swift        # Popover UI
├── BrightnessManager.swift  # State management & notifications
├── OverlayManager.swift     # Metal overlay windows
├── MetalRenderer.swift      # EDR clear-color renderer
└── CustomStyles.swift       # Amber toggle style
```

## Credits

Inspired by [Vivid](https://www.getvivid.app/), [BrightIntosh](https://github.com/niklasr22/BrightIntosh), and [BrightXDR](https://github.com/starkdmi/BrightXDR).

Built with [Claude Code](https://claude.ai/code).

## License

[MIT](LICENSE) — do whatever you want with it.
