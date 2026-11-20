<div align="center">
  <img src="assets/icon.png" width="128" alt="PowerWall" /><br><br>

  <h1>PowerWall</h1>
  <p><strong>Your wallpaper knows when you're plugged in.</strong><br>
  PowerWall lives in your menu bar and switches your wallpaper the instant your power state changes — with a cinematic fade transition.</p>

  <a href="https://github.com/WeoxStudio/PowerWall/releases/latest"><img src="https://img.shields.io/github/v/release/WeoxStudio/PowerWall?style=flat-square&color=4CAF50&label=latest" alt="Release"></a>
  <a href="https://github.com/WeoxStudio/PowerWall/stargazers"><img src="https://img.shields.io/github/stars/WeoxStudio/PowerWall?style=flat-square&color=4CAF50" alt="Stars"></a>
  <a href="https://github.com/WeoxStudio/PowerWall/blob/main/LICENSE"><img src="https://img.shields.io/github/license/WeoxStudio/PowerWall?style=flat-square&color=4CAF50" alt="License"></a>
  <img src="https://img.shields.io/badge/macOS-14%2B-4CAF50?style=flat-square" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-5-4CAF50?style=flat-square&logo=swift&logoColor=white" alt="Swift 5">
  <img src="https://img.shields.io/badge/arch-Apple%20Silicon%20%7C%20Intel-4CAF50?style=flat-square" alt="Architecture">

</div>

---

## Screenshots

<div align="center">
  <img src="assets/settings.png" width="420" alt="Settings window" />
  &nbsp;&nbsp;
  <img src="assets/menu-on.png" width="240" alt="Menu — Plugged In" />
  &nbsp;&nbsp;
  <img src="assets/menu-off.png" width="240" alt="Menu — On Battery" />
</div>

---

## What it does

Set a wallpaper for **plugged in** and a separate one for **on battery**. The moment macOS sees a power state change, PowerWall fires — no delay, no manual switching. It supports video, GIF, and image wallpapers, and transitions between them with a smooth fade to black.

---

## By the numbers

| | |
|---|---|
| **Detection latency** | < 100 ms via IOKit + burst polling |
| **Supported formats** | MP4 · MOV · GIF · PNG · JPG · HEIC · WEBP |
| **Memory footprint** | ~12 MB at idle |
| **CPU usage** | ~0% at idle, < 1% on power change |
| **Startup time** | < 0.3 s to menu bar |
| **Swift source** | ~800 lines across 9 files |
| **macOS requirement** | 14 Sonoma or later |
| **Architecture** | Apple Silicon · Intel |

---

## How detection works

```
Power change
    │
    ├─ IOKit IOPSNotificationCreateRunLoopSource   ← instant hardware event
    │       └─ burst poll ×10 at 100 ms intervals  ← confirms the change fast
    │
    └─ Steady Timer every 1 s (fallback)           ← catches edge cases

Both run on .common RunLoop mode → fire even while the menu is open
```

---

## Features

- **Instant** — detects plug/unplug in under 100 ms, works while the menu is open
- **Any media** — video (MP4/MOV), animated GIF, static image (PNG/JPG/HEIC/WEBP)
- **Fade transition** — full-screen overlay fades to black and back in both directions
- **Three battery modes** — same as plugged-in, macOS default wallpaper, or a custom file
- **Launch at login** — single toggle, no extra setup
- **Zero footprint** — no Dock icon, no background services, pure menu bar agent
- **Bilingual** — English and Turkish

---

## Build from source

```bash
git clone https://github.com/WeoxStudio/PowerWall.git
cd PowerWall
./build.sh
open build/PowerWall.app
```

Requires Xcode command line tools:
```bash
xcode-select --install
```

---

## Support

If PowerWall saves you time every day, consider buying me a coffee ☕️

<a href="https://buymeacoffee.com/weoxstudio">
  <img src="https://img.shields.io/badge/Buy%20me%20a%20coffee-☕️-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee">
</a>

---

## License

MIT — see [LICENSE](LICENSE).

<div align="center">
  <br>
  Made with ♥ by <a href="https://github.com/WeoxStudio">WeoxStudio</a>
</div>
