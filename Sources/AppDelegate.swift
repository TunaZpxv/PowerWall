import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, SettingsDelegate {
    private var statusItem: NSStatusItem?
    private let wallWindow = WallpaperWindow()
    private let power      = PowerMonitor()
    private let prefs      = Prefs.shared
    private var settingsWC: SettingsWindow?
    private var toggleItem:    NSMenuItem?
    private var statusView:    PowerStatusView?   // live-update target
    private var menuIsOpen:    Bool = false

    func applicationDidFinishLaunching(_ note: Notification) {
        setupMenuBar()
        power.onChange = { [weak self] pluggedIn in
            DispatchQueue.main.async { self?.onPowerChanged(pluggedIn: pluggedIn) }
        }
        power.start()
        applyWallpaper(pluggedIn: power.isPluggedIn)
    }

    // MARK: - Power change

    private func onPowerChanged(pluggedIn: Bool) {
        // Duvar kağıdını güncelle
        let action = prefs.resolveAction(pluggedIn: pluggedIn)
        switch action {
        case .setURL(let url):
            if wallWindow.currentURL != url { wallWindow.load(url: url, animated: true) }
        case .setDefault, .doNothing:
            wallWindow.hide(animated: true)
        }
        // Menü açık değilse yeniden kur (statusView'u tazele); açıksa sadece view'ı güncelle
        if menuIsOpen {
            statusView?.update(pluggedIn: pluggedIn, prefs: prefs)
            toggleItem?.title = prefs.enabled ? L.s(.statusDisable) : L.s(.statusEnable)
        } else {
            rebuildMenu()
        }
    }

    // MARK: - Wallpaper

    func applyWallpaper(pluggedIn: Bool) {
        let action = prefs.resolveAction(pluggedIn: pluggedIn)
        switch action {
        case .setURL(let url):
            if wallWindow.currentURL != url { wallWindow.load(url: url, animated: true) }
        case .setDefault:
            wallWindow.hide(animated: true)
        case .doNothing:
            wallWindow.hide(animated: true)
        }
        rebuildMenu()
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = leafImage()
        rebuildMenu()
    }

    private func leafImage() -> NSImage {
        let img = NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
            NSImage(systemSymbolName: "leaf.fill", accessibilityDescription: nil)?.draw(in: rect)
            return true
        }
        img.isTemplate = true
        return img
    }

    // NSMenuDelegate — menü açılmadan hemen önce güncelle
    func menuWillOpen(_ menu: NSMenu) {
        menuIsOpen = true
        statusView?.update(pluggedIn: power.isPluggedIn, prefs: prefs)
        toggleItem?.title = prefs.enabled ? L.s(.statusDisable) : L.s(.statusEnable)
        toggleItem?.image = sfIcon(prefs.enabled ? "pause.circle" : "play.circle")
    }

    func menuDidClose(_ menu: NSMenu) {
        menuIsOpen = false
    }

    func rebuildMenu() {
        let menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self

        // ── Canlı durum başlığı ───────────────────────────────────
        let sv = PowerStatusView(pluggedIn: power.isPluggedIn, prefs: prefs)
        self.statusView = sv
        let svItem = NSMenuItem()
        svItem.view = sv
        svItem.isEnabled = false
        menu.addItem(svItem)

        menu.addItem(.separator())

        // ── Etkinleştir / Devre dışı ─────────────────────────────
        let toggle = NSMenuItem(
            title: prefs.enabled ? L.s(.statusDisable) : L.s(.statusEnable),
            action: #selector(toggleEnabled), keyEquivalent: "t")
        toggle.target = self
        toggle.image  = sfIcon(prefs.enabled ? "pause.circle" : "play.circle")
        menu.addItem(toggle)
        self.toggleItem = toggle

        menu.addItem(.separator())

        // ── Ayarlar ───────────────────────────────────────────────
        let settings = NSMenuItem(title: L.s(.menuSettings),
                                  action: #selector(openSettings), keyEquivalent: ",")
        settings.target = self
        settings.image  = sfIcon("gearshape")
        menu.addItem(settings)

        // ── Açılışta başlat ───────────────────────────────────────
        let loginItem = NSMenuItem(title: L.s(.loginTitle),
                                   action: #selector(toggleLoginAtLaunch), keyEquivalent: "")
        loginItem.target = self
        loginItem.image  = sfIcon("power")
        if #available(macOS 13.0, *) {
            loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        }
        menu.addItem(loginItem)

        // İzin uyarısı
        if #available(macOS 13.0, *) {
            if UserDefaults.standard.bool(forKey: "loginRequested"),
               SMAppService.mainApp.status == .requiresApproval {
                let warn = NSMenuItem(title: L.s(.loginPermissionWarning),
                                     action: #selector(openLoginItems), keyEquivalent: "")
                warn.target = self
                warn.image  = sfIcon("exclamationmark.triangle.fill", color: .systemOrange)
                menu.addItem(warn)
            }
        }

        menu.addItem(.separator())

        // ── Çıkış ────────────────────────────────────────────────
        let quit = NSMenuItem(title: L.s(.menuQuit), action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        quit.image  = sfIcon("xmark.circle")
        menu.addItem(quit)

        statusItem?.menu = menu
    }

    private func sfIcon(_ name: String, color: NSColor? = nil) -> NSImage? {
        guard let img = NSImage(systemSymbolName: name, accessibilityDescription: nil) else { return nil }
        let out = NSImage(size: NSSize(width: 16, height: 16), flipped: false) { rect in
            if let c = color {
                img.withSymbolConfiguration(
                    NSImage.SymbolConfiguration(paletteColors: [c]))?.draw(in: rect)
            } else {
                img.draw(in: rect)
            }
            return true
        }
        out.isTemplate = (color == nil)
        return out
    }

    // MARK: - Actions

    @objc private func toggleEnabled() {
        prefs.enabled = !prefs.enabled
        applyWallpaper(pluggedIn: power.isPluggedIn)
    }

    @objc private func toggleLoginAtLaunch() {
        guard #available(macOS 13.0, *) else { openLoginItems(); return }
        UserDefaults.standard.set(true, forKey: "loginRequested")
        if SMAppService.mainApp.status == .enabled {
            try? SMAppService.mainApp.unregister()
        } else {
            try? SMAppService.mainApp.register()
        }
        rebuildMenu()
    }

    @objc func openSettings() {
        if settingsWC == nil {
            settingsWC = SettingsWindow()
            settingsWC?.settingsDelegate = self
        }
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        settingsWC?.showWindow(nil)
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
        NSApp.setActivationPolicy(.accessory)
        applyWallpaper(pluggedIn: power.isPluggedIn)
    }
}

// MARK: - PowerStatusView

final class PowerStatusView: NSView {

    // Subview refs for live update (no full rebuild needed)
    private var plugDot:      NSView!
    private var plugIcon:     NSImageView!
    private var plugTitle:    NSTextField!
    private var plugSub:      NSTextField!
    private var batDot:       NSView!
    private var batIcon:      NSImageView!
    private var batTitle:     NSTextField!
    private var batSub:       NSTextField!

    init(pluggedIn: Bool, prefs: Prefs) {
        super.init(frame: NSRect(x: 0, y: 0, width: 240, height: 64))
        wantsLayer = true
        buildLayout()
        update(pluggedIn: pluggedIn, prefs: prefs)
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildLayout() {
        func makeRow() -> (dot: NSView, icon: NSImageView, title: NSTextField, sub: NSTextField, row: NSView) {
            let row   = NSView()
            let dot   = NSView()
            let icon  = NSImageView()
            let title = NSTextField(labelWithString: "")
            let sub   = NSTextField(labelWithString: "")

            dot.wantsLayer = true
            dot.layer?.cornerRadius = 3
            [dot, icon, title, sub].forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                row.addSubview($0)
            }
            NSLayoutConstraint.activate([
                dot.leadingAnchor.constraint(equalTo: row.leadingAnchor),
                dot.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                dot.widthAnchor.constraint(equalToConstant: 6),
                dot.heightAnchor.constraint(equalToConstant: 6),

                icon.leadingAnchor.constraint(equalTo: dot.trailingAnchor, constant: 6),
                icon.centerYAnchor.constraint(equalTo: row.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 16),
                icon.heightAnchor.constraint(equalToConstant: 16),

                title.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 6),
                title.centerYAnchor.constraint(equalTo: row.centerYAnchor),

                sub.leadingAnchor.constraint(equalTo: title.trailingAnchor, constant: 5),
                sub.trailingAnchor.constraint(lessThanOrEqualTo: row.trailingAnchor),
                sub.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            ])
            return (dot, icon, title, sub, row)
        }

        let (pd, pi, pt, ps, plugRow) = makeRow()
        let (bd, bi, bt, bs, batRow)  = makeRow()
        plugDot = pd; plugIcon = pi; plugTitle = pt; plugSub = ps
        batDot  = bd; batIcon  = bi; batTitle  = bt; batSub  = bs

        plugRow.translatesAutoresizingMaskIntoConstraints = false
        batRow.translatesAutoresizingMaskIntoConstraints  = false
        addSubview(plugRow)
        addSubview(batRow)

        NSLayoutConstraint.activate([
            plugRow.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            plugRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            plugRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            plugRow.heightAnchor.constraint(equalToConstant: 24),

            batRow.topAnchor.constraint(equalTo: plugRow.bottomAnchor, constant: 4),
            batRow.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            batRow.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            batRow.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    /// Called both on init and whenever power state changes — no view rebuild.
    func update(pluggedIn: Bool, prefs: Prefs) {
        // ── Plug row ──────────────────────────────────────────────
        let plugActive = pluggedIn
        plugDot.layer?.backgroundColor = (plugActive ? NSColor.systemGreen : .clear).cgColor

        let plugSymName = plugActive ? "bolt.fill" : "bolt.slash.fill"
        let plugColor: NSColor = plugActive ? .systemGreen : .secondaryLabelColor
        plugIcon.image = symbol(plugSymName, color: plugColor, size: 13)

        plugTitle.stringValue = L.s(.pluggedIn)
        plugTitle.font        = .systemFont(ofSize: 12, weight: plugActive ? .semibold : .regular)
        plugTitle.textColor   = plugActive ? .labelColor : .secondaryLabelColor

        plugSub.stringValue = shortName(prefs: prefs, pluggedIn: true)
        plugSub.font        = .systemFont(ofSize: 11)
        plugSub.textColor   = .tertiaryLabelColor

        // ── Battery row ───────────────────────────────────────────
        let batActive = !pluggedIn
        batDot.layer?.backgroundColor = (batActive ? NSColor.systemGreen : .clear).cgColor

        let batSymName = pluggedIn ? "battery.75percent" : "battery.75percent.bolt"
        let batColor: NSColor = batActive ? .systemGreen : .secondaryLabelColor
        batIcon.image = symbol(batSymName, color: batColor, size: 13)

        batTitle.stringValue = L.s(.onBattery)
        batTitle.font        = .systemFont(ofSize: 12, weight: batActive ? .semibold : .regular)
        batTitle.textColor   = batActive ? .labelColor : .secondaryLabelColor

        batSub.stringValue = shortName(prefs: prefs, pluggedIn: false)
        batSub.font        = .systemFont(ofSize: 11)
        batSub.textColor   = .tertiaryLabelColor
    }

    // İlk 10 karakter + "..." + uzantı
    private func shortName(prefs: Prefs, pluggedIn: Bool) -> String {
        let action = prefs.resolveAction(pluggedIn: pluggedIn)
        switch action {
        case .setURL(let url):
            let name = url.deletingPathExtension().lastPathComponent
            let ext  = url.pathExtension
            let short = name.count > 10
                ? String(name.prefix(10)) + "…" + (ext.isEmpty ? "" : ".\(ext)")
                : url.lastPathComponent
            return "· \(short)"
        case .setDefault:
            return "· \(L.s(.statusDefault))"
        case .doNothing:
            return ""
        }
    }

    private func symbol(_ name: String, color: NSColor, size: CGFloat) -> NSImage? {
        guard let sym = NSImage(systemSymbolName: name, accessibilityDescription: nil) else { return nil }
        let cfg = NSImage.SymbolConfiguration(pointSize: size, weight: .medium)
            .applying(NSImage.SymbolConfiguration(paletteColors: [color]))
        return sym.withSymbolConfiguration(cfg)
    }
}
