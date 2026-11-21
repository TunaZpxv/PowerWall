# 🗺️ PowerWall 2.0 Roadmap

> 🚀 Goal: A smarter, lighter, more user-friendly live wallpaper experience.

**Target release window:** Q1 2027 (a goal, not a promise — dates may change).

## 📊 Metrics (aligned with README)

| Metric | v1.0 | v2.0 Target | Notes |
|---|---|---|---|
| ⚡ Detection latency | < 100 ms | < 100 ms | IOKit hardware event |
| 🧠 Memory footprint | ~12 MB | ~12 MB | Idle, no video playing |
| ⚙️ CPU usage | ~0% idle / <1% event | To be measured | Under load, M-series chip |
| 🚀 Startup time | < 0.3 s | < 0.3 s | Launch to menu bar ready |
| 📦 App bundle size | < 1 MB | < 1 MB | Compiled binary only |
| 🎬 Supported formats | 7 | 7 | MP4 · MOV · GIF · PNG · JPG · HEIC · WEBP |
| 📝 Swift source | ~800 lines | ~1200 lines (estimated) | 9 → ~12 files, zero deps |

## 🧠 Part 1: CPU-load-aware protection ⚡

Automatically pauses animations under high CPU/thermal load and restores them when load returns to normal.

**What it will do:**
- If load rises and the battery-mode content is static (image or macOS default), the animation turns off and the system switches to the battery-mode content. When load normalizes, the animation returns.
- If load rises but the user has animated content (video or GIF) set for battery mode, PowerWall changes nothing. It only plays a single sound notification: "CPU load is high. Consider turning off the wallpaper."

**Design principles:**
- **One pure decision function.** Inputs: load state, battery-mode content type, user setting. Output: continue, switch to static, or notify only. It has no system dependencies, so every combination can be unit-tested.
- **Real strain signals.** Thermal state and Low Power Mode are the primary signals; total CPU is secondary. Updates are notification-based rather than continuous polling, to stay lightweight.
- **No self-measurement loop.** PowerWall's own load is excluded from the measurement, so video playback can't trigger its own shutdown.
- **Stable transitions.** Short-term averaging and separate thresholds for turning off and back on prevent flickering.
- **Quiet notifications.** One notification per load spike, no repeats until load normalizes. The sound can be disabled separately.
- **User stays in control.** The feature can be turned off, sensitivity is adjustable, and the menu shows why the animation is paused.
- **Visual consistency.** Transitions reuse the existing fade effect.
- **Proven impact.** CPU and energy use will be measured with the feature on and off under load, and the results added to the README.

**Progress:**
- [ ] Decision function + unit tests
- [ ] Thermal state / Low Power Mode signals
- [ ] CPU secondary signal with self-load excluded
- [ ] Averaging and threshold logic
- [ ] Sound notification (once per spike)
- [ ] Settings: toggle, sensitivity, sound
- [ ] Menu status indicator
- [ ] On/off measurements published in README

## 📚 Part 2: Built-in Library 🎨

A curated, on-demand collection of live wallpapers. Browse categories, preview, and install with one click. Content is stored in a known folder and can be removed at any time.

**What it will do:**
Users without their own live wallpaper pick an option from the in-app list and click "Install". The content is downloaded and becomes ready to use.

**Design principles:**
- **App stays lightweight.** Wallpapers are not embedded; they're downloaded on demand, preserving the "under 1 MB app" property.
- **Updatable list.** A separate content manifest (name, category, preview, size, license, author) means new wallpapers don't require an app update.
- **Clear licensing.** Only original or redistributable content, with author and license shown for every item.
- **Optimized content.** Short, seamless, low-bitrate loops, so wallpapers don't drain the battery or constantly trigger Part 1.
- **Privacy transparency.** PowerWall currently makes no network connections. In 2.0, the network is used only when the library is opened, no data is collected, and this will be stated clearly in the README.
- **Reliable downloads.** Integrity is verified, connection errors are handled, and downloads can be cancelled.
- **User control over files.** Downloads live in a known folder and can be deleted from within the app.
- **Simple UI.** A separate "Library" tab in settings with categories, previews, and download progress.
- **Seamless integration.** Downloaded content can be assigned to "plugged in" or "on battery". If animated content is chosen for battery mode, the Part 1 "notify only" rule applies automatically.

**Progress:**
- [ ] Manifest format and hosting
- [ ] Download manager (integrity check, cancel, errors)
- [ ] Library tab UI
- [ ] Assign to plugged in / on battery
- [ ] First set of licensed, optimized wallpapers
- [ ] README privacy note

## ☕ Support & Contact

- ▶️ [YouTube Channel](https://www.youtube.com/@Tuna-zpxv)
- 💛 [Buy Me a Coffee](https://buymeacoffee.com/tunazpxv)
- 📧 Contact: tunazpxv@gmail.com

---

Made with ♥ by [TunaZpxv](https://github.com/TunaZpxv)
