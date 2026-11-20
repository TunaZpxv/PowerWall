import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate, SettingsDelegate {
    private var statusItem: NSStatusItem?
    private let wallWindow = WallpaperWindow()
    private let power = PowerMonitor()
    private let prefs = Prefs.shared
    private var settingsWC: SettingsWindow?
    private var toggleItem: NSMenuItem?
    private var statusTextItem: NSMenuItem?

    func applicationDidFinishLaunching(_ note: Notification) {
        setupMenuBar()
        if !UserDefaults.standard.bool(forKey: "onboarded") {
            let ow = OnboardingWindow(); ow.showWindow(nil); NSApp.activate(ignoringOtherApps: true)
        }
        power.onChange = { [weak self] pluggedIn in
            self?.applyWallpaper(pluggedIn: pluggedIn)
        }
        power.start()
        applyWallpaper(pluggedIn: power.isPluggedIn)
    }

    // MARK: - Duvar Kağıdı

    func applyWallpaper(pluggedIn: Bool) {
        let action = prefs.resolveAction(pluggedIn: pluggedIn)
        switch action {
        case .setURL(let url):
            if wallWindow.currentURL != url {
                wallWindow.load(url: url, animated: true)
            }
        case .setDefault:
            wallWindow.hide(animated: true)
        case .doNothing:
            wallWindow.hide(animated: true)
        }
        updateStatusLabel()
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let btn = statusItem?.button {
            let img = NSImage(systemSymbolName: "photo.on.rectangle", accessibilityDescription: "Duvar Kağıdı")
            img?.isTemplate = true
            btn.image = img
        }
        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let st = NSMenuItem(title: "—", action: nil, keyEquivalent: "")
        st.isEnabled = false
        statusTextItem = st
        menu.addItem(st)
        menu.addItem(.separator())

        let toggle = NSMenuItem(
            title: prefs.enabled ? "Devre Dışı Bırak" : "Etkinleştir",
            action: #selector(toggleEnabled), keyEquivalent: "t"
        )
        toggle.target = self
        toggleItem = toggle
        menu.addItem(toggle)

        menu.addItem(.separator())

        let settings = NSMenuItem(title: "Ayarlar…", action: #selector(openSettings), keyEquivalent: ",")
        settings.target = self
        menu.addItem(settings)

        let login = NSMenuItem(title: "Açılışta Başlat…", action: #selector(openLoginItems), keyEquivalent: "")
        login.target = self
        menu.addItem(login)

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Çıkış", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem?.menu = menu
        updateStatusLabel()
    }

    private func updateStatusLabel() {
        let plugged = power.isPluggedIn
        let icon = plugged ? "🔌" : "🔋"
        let action = prefs.resolveAction(pluggedIn: plugged)
        let desc: String
        switch action {
        case .setURL(let url): desc = url.lastPathComponent
        case .setDefault:      desc = "Varsayılan"
        case .doNothing:       desc = "Pasif"
        }
        statusTextItem?.title = "\(icon) \(desc)"
        toggleItem?.title = prefs.enabled ? "Devre Dışı Bırak" : "Etkinleştir"
    }

    @objc private func toggleEnabled() {
        prefs.enabled = !prefs.enabled
        applyWallpaper(pluggedIn: power.isPluggedIn)
        rebuildMenu()
    }

    @objc private func openSettings() {
        if settingsWC == nil {
            settingsWC = SettingsWindow()
            settingsWC?.settingsDelegate = self
        }
        settingsWC?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
        settingsWC?.window?.makeKeyAndOrderFront(nil)
    }

    @objc private func openLoginItems() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func quit() {
        wallWindow.hide()
        NSApp.terminate(nil)
    }

    func settingsDidChange() {
        applyWallpaper(pluggedIn: power.isPluggedIn)
        rebuildMenu()
    }
}
