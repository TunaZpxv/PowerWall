<div align="center">
  <img src="logo.png" width="128" alt="PowerWall — macOS wallpaper switcher" /><br><br>

  <h1>PowerWall</h1>

  <p><strong>Your wallpaper knows when you're plugged in.</strong><br>
  A lightweight macOS menu bar app that automatically switches your wallpaper<br>
  the instant your power state changes — with a cinematic fade transition.</p>

  <a href="https://github.com/TunaZpxv/PowerWall/releases/latest">
    <img src="https://img.shields.io/github/v/release/TunaZpxv/PowerWall?style=flat-square&color=3fb950&label=latest+release" alt="Latest Release">
  </a>
  <a href="https://github.com/TunaZpxv/PowerWall/stargazers">
    <img src="https://img.shields.io/github/stars/TunaZpxv/PowerWall?style=flat-square&color=3fb950" alt="Stars">
  </a>
  <a href="https://github.com/TunaZpxv/PowerWall/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/TunaZpxv/PowerWall?style=flat-square&color=3fb950" alt="MIT License">
  </a>
  <img src="https://img.shields.io/badge/macOS-14%2B-3fb950?style=flat-square" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-5-3fb950?style=flat-square&logo=swift&logoColor=white" alt="Swift 5">
  <img src="https://img.shields.io/badge/arch-Apple%20Silicon%20%7C%20Intel-3fb950?style=flat-square" alt="Architecture">
  <img src="https://img.shields.io/badge/size-%3C%201%20MB-3fb950?style=flat-square" alt="App Size">

  <br><br>

  > **macOS menu bar app** · **automatic wallpaper switching** · **power state detection** · **fade transition** · **Swift** · **open source**
</div>

> 🗺️ **2.0 is coming:** CPU-aware pausing and a built-in wallpaper library. See the [Roadmap](ROADMAP.md).

---

## Demo

<div align="center">

[

![PowerWall Video](https://img.youtube.com/vi/EIQHC2-jHkY/hqdefault.jpg)

](https://www.youtube.com/watch?v=EIQHC2-jHkY)

<a href="https://www.youtube.com/@Tuna-zpxv">
  <img src="https://img.shields.io/badge/YouTube-Subscribe-FF0000?style=for-the-badge&logo=youtube&logoColor=white" alt="YouTube Channel">
</a>

</div>

---

## Screenshots

<div align="center">
  <img src="assets/settings.png" width="380" alt="Settings — configure wallpapers for each power state" />
  &nbsp;
  <img src="assets/menu-on.png"  width="220" alt="Menu — Plugged In state" />
  &nbsp;
  <img src="assets/menu-off.png" width="220" alt="Menu — On Battery state" />
  <br>
  <sub>Settings window · Menu when plugged in · Menu on battery</sub>
</div>

---

## What it does

Set a wallpaper for **plugged in** and a separate one for **on battery**. The moment macOS sees a power state change, PowerWall fires in under 100 ms — no manual action needed. Plug in your charger and your desk wallpaper appears. Unplug and it switches back. Transitions use a smooth fade to black so the swap never feels abrupt.

Supports video loops (MP4/MOV), animated GIFs, and static images (PNG/JPG/HEIC/WEBP).

---

## Performance

| Metric | Value | Notes |
|---|---|---|
| ⚡ Detection latency | **< 100 ms** | IOKit callback fires instantly on hardware event |
| 🧠 Memory footprint | **~12 MB** | Idle, no video playing |
| ⚙️ CPU usage | **~0%** idle · **< 1%** on event | Measured on M-series chip |
| 🚀 Startup time | **< 0.3 s** | From launch to menu bar ready |
| 📦 App bundle size | **< 1 MB** | Compiled binary only |
| 🎬 Supported formats | **7** | MP4 · MOV · GIF · PNG · JPG · HEIC · WEBP |
| 📝 Swift source | **~800 lines** | 9 files, zero dependencies |
| 🖥️ macOS requirement | **14 Sonoma+** | arm64 + x86_64 |

---

## How detection works
