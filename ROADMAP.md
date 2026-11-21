# 🗺️ PowerWall 2.0 Roadmap

> 🚀 Goal: A smarter, lighter, more user-friendly live wallpaper experience.

**Target release window:** within the first 3 months (2027).

## 📊 Metrics (aligned with README)

| Metric | v1.0 | v2.0 Target | Notes |
|---|---|---|---|
| ⚡ Detection latency | < 100 ms | < 100 ms | IOKit hardware event |
| 🧠 Memory footprint | ~12 MB | ~12 MB | Idle, no video playing |
| ⚙️ CPU usage | ~0% idle / <1% event | lower under load | M-series chip |
| 🚀 Startup time | < 0.3 s | < 0.3 s | Launch to menu bar ready |
| 📦 App bundle size | < 1 MB | < 1 MB | Compiled binary only |
| 🎬 Supported formats | 7 | 7 | MP4 · MOV · GIF · PNG · JPG · HEIC · WEBP |
| 📝 Swift source | ~800 lines | ~1200 lines | 9 → 12 files, zero deps |

## 🧠 Part 1: CPU-load-aware protection ⚡

Automatically pauses animations under high CPU/thermal load and restores them when normal, with a single notification in battery mode.

**What it will do:**
- If CPU load rises and battery-mode content is static (image or macOS default), animation turns off and the system returns to battery-mode content. When load normalizes, animation returns.
- If CPU load rises but the user uses animated content (video or GIF) in battery mode, the system changes nothing. It only plays a single voice notification: "CPU load is high, closing the wallpaper is recommended."

**How to do it well:**
- Decision logic must be single and pure. Inputs: load state, battery-mode content type, user setting. Output: one of three options — continue, switch to static, notify only. System-independent, so every combination is unit-testable. This is where the project's engineering value lies.
- The signal should reflect real system strain. Thermal state and Low Power Mode should be primary signals; total CPU is a secondary signal. Notification-based, not continuous polling, to keep the app lightweight.
- The app must not include its own load in measurement. Otherwise video playback raises load, app stops itself, load drops, restarts — an infinite loop.
- Transitions must be stable. Use short-term averages instead of instant spikes; different thresholds for off and on. Prevents animation flickering.
- Notification should not be annoying. Once per load rise, no repeat until load normalizes, sound can be disabled separately.
- User stays in control. Feature toggleable, sensitivity selectable, current pause reason visible in menu.
- Visual consistency. Reuse the existing fade effect so transitions aren't abrupt.
- Proven impact. Measure CPU and energy with feature on/off under load, add to README.

## 📚 Part 2: Built-in Library 🎨

A curated, on-demand downloadable collection of live wallpapers. Users browse categories, preview, and install with one click; content is stored in a known folder and can be removed at any time.

**What it will do:**
Users without their own live wallpaper pick an option from the in-app list and click "Install"; content is downloaded and becomes usable.

**How to do it well:**
- Keep the app lightweight. Wallpapers must not be embedded; downloaded on demand. Preserves the "under 1 MB app" property.
- List updatable separately from the app. Content manifest (name, category, preview, size, license, author) in a separate file so new wallpapers don't require an app update.
- Clear licensing. Only your own or redistributable content; author and license shown per item. No unauthorized use of others' work.
- Optimized content. Short, seamless, low-bitrate loops. Heavy content drains battery and constantly triggers Part 1 protection.
- Privacy transparency. App currently uses no network. Network access only when library is used; no data collected; stated clearly in README.
- Reliable downloads. Verify file integrity, handle connection drops and errors, allow cancel.
- User control over files. Downloads live in a known folder; user can delete from the app.
- Simple UI. Separate "Library" tab in settings, categories, preview images, download progress.
- Seamless integration. Downloaded content assignable to "plugged in" or "on battery" easily. If animated content chosen for battery mode, Part 1 "notify only" rule applies automatically.

## ☕ Support & Contact

- ▶️ [YouTube Channel](https://www.youtube.com/@Tuna-zpxv)
- 💛 [Buy Me a Coffee](https://buymeacoffee.com/tunazpxv)
- 📧 Contact: tunazpxv@gmail.com

---

Made with ♥ by [TunaZpxv](https://github.com/TunaZpxv)
