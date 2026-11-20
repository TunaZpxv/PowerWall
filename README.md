<div align="center">
  <img src="assets/icon.png" width="120" alt="PowerWall Logo" />
  <h1>PowerWall</h1>
  <p>macOS menu bar app that automatically switches your wallpaper when you plug in or unplug your charger.</p>

  <a href="https://github.com/WeoxStudio/PowerWall/releases"><img src="https://img.shields.io/github/v/release/WeoxStudio/PowerWall?style=flat-square&color=4CAF50&label=release" alt="Release"></a>
  <a href="https://github.com/WeoxStudio/PowerWall/stargazers"><img src="https://img.shields.io/github/stars/WeoxStudio/PowerWall?style=flat-square&color=4CAF50" alt="Stars"></a>
  <a href="https://github.com/WeoxStudio/PowerWall/blob/main/LICENSE"><img src="https://img.shields.io/github/license/WeoxStudio/PowerWall?style=flat-square&color=4CAF50" alt="License"></a>
  <img src="https://img.shields.io/badge/macOS-14%2B-4CAF50?style=flat-square" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-5-4CAF50?style=flat-square&logo=swift&logoColor=white" alt="Swift 5">
  <br><br>

  <img src="assets/settings_window.png" width="560" alt="PowerWall Settings" />
</div>

---

## What it does

PowerWall lives in your menu bar and watches your power source. The moment you plug in or unplug your charger, it switches your wallpaper — with a smooth fade transition. Set a video, GIF, or image for each state and forget about it.

<div align="center">
  <img src="assets/menu_popup.png" width="300" alt="PowerWall Menu" />
</div>

## Features

- **Instant switching** — detects power changes in real time, even while the menu is open
- **Any media** — supports MP4, MOV, GIF, PNG, JPG, HEIC
- **Fade transition** — smooth black fade between wallpapers in both directions
- **Battery mode options** — same as plugged-in, default macOS wallpaper, or a different file
- **Launch at login** — single toggle, no manual setup
- **Multilingual** — English and Turkish built in
- **Zero background activity** — no dock icon, no app window, pure menu bar

## Screenshots

| Settings | Menu |
|----------|------|
| ![Settings](assets/settings_window.png) | ![Menu](assets/menu_popup.png) |

## Requirements

- macOS 14 Sonoma or later
- Apple Silicon or Intel Mac

## Build from source

```bash
git clone https://github.com/WeoxStudio/PowerWall.git
cd PowerWall
./build.sh
open build/PowerWall.app
```

Requires Xcode command line tools (`xcode-select --install`).

## How it works

PowerWall uses `IOPSNotificationCreateRunLoopSource` for instant power state detection and falls back to a 1-second polling timer — both running on `.common` RunLoop modes so they fire even when the menu is open. Wallpaper transitions use a full-screen overlay window that fades to black and back.

## License

MIT — see [LICENSE](LICENSE).

---

<div align="center">
  Made with ♥ by <a href="https://github.com/WeoxStudio">WeoxStudio</a>
</div>
