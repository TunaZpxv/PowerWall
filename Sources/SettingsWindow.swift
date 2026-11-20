import AppKit
import UniformTypeIdentifiers
import ServiceManagement

protocol SettingsDelegate: AnyObject {
    func settingsDidChange()
}

final class SettingsWindow: NSWindowController, NSWindowDelegate {
    weak var settingsDelegate: SettingsDelegate?
    private let prefs = Prefs.shared

    private var pluggedURL: URL?
    private var batteryMode: String = "same"
    private var batteryURL: URL?

    private let pluggedCard      = MediaCard(label: "", icon: "bolt.fill",    accent: .systemBlue)
    private let batterySegment   = NSSegmentedControl()
    private let batteryCard      = MediaCard(label: "", icon: "battery.50",   accent: .systemGreen)
    private let batteryHeader    = NSTextField(labelWithString: "")
    // loginToggle removed — launch at login is in menu bar only
    private let saveBtn   = NSButton(title: "", target: nil, action: nil)
    private let cancelBtn = NSButton(title: "", target: nil, action: nil)

    // Login permission warning row (shown when permission was denied)
    private var loginWarningRow: NSView?

    convenience init() {
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 540),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        win.title = "PowerWall"
        win.titlebarAppearsTransparent = true
        win.center()
        self.init(window: win)
        win.delegate = self
        buildUI()
        loadPrefs()
    }

    private func buildUI() {
        guard let cv = window?.contentView else { return }
        cv.wantsLayer = true

        // Header bar
        let headerBar = NSView()
        headerBar.wantsLayer = true
        headerBar.layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.5).cgColor
        headerBar.translatesAutoresizingMaskIntoConstraints = false
        cv.addSubview(headerBar)

        let headerTitle = NSTextField(labelWithString: L.s(.settingsTitle))
        headerTitle.font = .systemFont(ofSize: 15, weight: .semibold)
        headerTitle.translatesAutoresizingMaskIntoConstraints = false
        headerBar.addSubview(headerTitle)

        let sep = NSBox(); sep.boxType = .separator
        sep.translatesAutoresizingMaskIntoConstraints = false
        cv.addSubview(sep)

        // Plugged card
        pluggedCard.headerLabel.stringValue = L.s(.pluggedSection)
        pluggedCard.onPick  = { [weak self] url in self?.pluggedURL = url; self?.pluggedCard.setURL(url) }
        pluggedCard.onClear = { [weak self] in self?.pluggedURL = nil; self?.pluggedCard.setURL(nil) }

        // Battery segment
        batterySegment.segmentCount = 3
        batterySegment.setLabel(L.s(.batteryModeSame),    forSegment: 0)
        batterySegment.setLabel(L.s(.batteryModeDefault), forSegment: 1)
        batterySegment.setLabel(L.s(.batteryModeCustom),  forSegment: 2)
        batterySegment.trackingMode = .selectOne
        batterySegment.selectedSegment = 0
        batterySegment.target = self
        batterySegment.action = #selector(batterySegmentChanged)

        batteryHeader.font = .systemFont(ofSize: 13, weight: .medium)
        batteryHeader.textColor = .secondaryLabelColor

        batteryCard.headerLabel.stringValue = L.s(.batterySection)
        batteryCard.onPick  = { [weak self] url in self?.batteryURL = url; self?.batteryCard.setURL(url) }
        batteryCard.onClear = { [weak self] in self?.batteryURL = nil; self?.batteryCard.setURL(nil) }
        batteryCard.isHidden = true

        // Login row removed from settings — it lives in the menu bar

        // Warning row (shown if permission required)
        let warnRow = makeLoginWarningRow()
        loginWarningRow = warnRow
        refreshWarningVisibility()

        // Language row
        let langRow = makeLangRow()

        // Buy Me a Coffee row
        let coffeeRow = makeCoffeeRow()

        // Buttons
        saveBtn.title   = L.s(.save)
        cancelBtn.title = L.s(.cancel)
        saveBtn.bezelStyle   = .rounded
        cancelBtn.bezelStyle = .rounded
        saveBtn.translatesAutoresizingMaskIntoConstraints   = false
        cancelBtn.translatesAutoresizingMaskIntoConstraints = false
        saveBtn.keyEquivalent = "\r"
        saveBtn.target = self;   saveBtn.action = #selector(save)
        cancelBtn.target = self; cancelBtn.action = #selector(cancel)

        // Stack — no login row, that's in menu bar
        let stack = NSStackView(views: [
            pluggedCard,
            sectionLabel(L.s(.batterySection)),
            batterySegment,
            batteryCard,
            warnRow,
            langRow,
            coffeeRow,
        ])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        cv.addSubview(stack)

        let btnRow = NSStackView(views: [cancelBtn, saveBtn])
        btnRow.orientation = .horizontal
        btnRow.spacing = 8
        btnRow.translatesAutoresizingMaskIntoConstraints = false
        cv.addSubview(btnRow)

        NSLayoutConstraint.activate([
            headerBar.topAnchor.constraint(equalTo: cv.topAnchor),
            headerBar.leadingAnchor.constraint(equalTo: cv.leadingAnchor),
            headerBar.trailingAnchor.constraint(equalTo: cv.trailingAnchor),
            headerBar.heightAnchor.constraint(equalToConstant: 52),

            headerTitle.centerXAnchor.constraint(equalTo: headerBar.centerXAnchor),
            headerTitle.centerYAnchor.constraint(equalTo: headerBar.centerYAnchor, constant: 8),

            sep.topAnchor.constraint(equalTo: headerBar.bottomAnchor),
            sep.leadingAnchor.constraint(equalTo: cv.leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: cv.trailingAnchor),

            stack.topAnchor.constraint(equalTo: sep.bottomAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: cv.trailingAnchor, constant: -24),

            pluggedCard.widthAnchor.constraint(equalTo: stack.widthAnchor),
            batterySegment.widthAnchor.constraint(equalTo: stack.widthAnchor),
            batteryCard.widthAnchor.constraint(equalTo: stack.widthAnchor),
            warnRow.widthAnchor.constraint(equalTo: stack.widthAnchor),
            langRow.widthAnchor.constraint(equalTo: stack.widthAnchor),
            coffeeRow.widthAnchor.constraint(equalTo: stack.widthAnchor),

            btnRow.trailingAnchor.constraint(equalTo: cv.trailingAnchor, constant: -24),
            btnRow.bottomAnchor.constraint(equalTo: cv.bottomAnchor, constant: -20),

            saveBtn.widthAnchor.constraint(equalToConstant: 100),
            saveBtn.heightAnchor.constraint(equalToConstant: 36),
            cancelBtn.widthAnchor.constraint(equalToConstant: 80),
            cancelBtn.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    private func sectionLabel(_ text: String) -> NSTextField {
        let lbl = NSTextField(labelWithString: text.uppercased())
        lbl.font = .systemFont(ofSize: 10, weight: .semibold)
        lbl.textColor = .tertiaryLabelColor
        return lbl
    }

    // MARK: - Login Permission Warning Row

    private func makeLoginWarningRow() -> NSView {
        let row = NSView()
        row.wantsLayer = true
        row.layer?.cornerRadius = 10
        row.layer?.backgroundColor = NSColor.systemOrange.withAlphaComponent(0.12).cgColor
        row.layer?.borderColor = NSColor.systemOrange.withAlphaComponent(0.4).cgColor
        row.layer?.borderWidth = 0.5
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 52).isActive = true

        let iv = NSImageView()
        iv.image = NSImage(systemSymbolName: "exclamationmark.triangle.fill", accessibilityDescription: nil)
        iv.contentTintColor = .systemOrange
        iv.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(iv)

        let lbl = NSTextField(labelWithString: L.s(.loginPermissionTitle))
        lbl.font = .systemFont(ofSize: 13, weight: .medium)
        lbl.textColor = .labelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(lbl)

        let sub = NSTextField(labelWithString: L.s(.loginPermissionSub))
        sub.font = .systemFont(ofSize: 11)
        sub.textColor = .secondaryLabelColor
        sub.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(sub)

        let btn = NSButton(title: L.s(.loginPermissionButton), target: self, action: #selector(openLoginItems))
        btn.bezelStyle = .rounded
        btn.font = .systemFont(ofSize: 11, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(btn)

        NSLayoutConstraint.activate([
            iv.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 14),
            iv.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 20),
            iv.heightAnchor.constraint(equalToConstant: 20),

            lbl.leadingAnchor.constraint(equalTo: iv.trailingAnchor, constant: 10),
            lbl.topAnchor.constraint(equalTo: row.topAnchor, constant: 10),

            sub.leadingAnchor.constraint(equalTo: lbl.leadingAnchor),
            sub.topAnchor.constraint(equalTo: lbl.bottomAnchor, constant: 2),

            btn.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -14),
            btn.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        return row
    }

    private func refreshWarningVisibility() {
        guard #available(macOS 13.0, *) else {
            loginWarningRow?.isHidden = true
            return
        }
        let requested = UserDefaults.standard.bool(forKey: "loginRequested")
        let status = SMAppService.mainApp.status
        let needsWarning = requested && status != .enabled
        loginWarningRow?.isHidden = !needsWarning
    }

    // MARK: - Buy Me a Coffee Row

    private func makeCoffeeRow() -> NSView {
        let row = NSView()
        row.wantsLayer = true
        row.layer?.cornerRadius = 10
        row.layer?.backgroundColor = NSColor(red: 1.0, green: 0.82, blue: 0.1, alpha: 0.08).cgColor
        row.layer?.borderColor = NSColor(red: 1.0, green: 0.82, blue: 0.1, alpha: 0.35).cgColor
        row.layer?.borderWidth = 0.5
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let emoji = NSTextField(labelWithString: "☕️")
        emoji.font = .systemFont(ofSize: 20)
        emoji.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(emoji)

        let lbl = NSTextField(labelWithString: "Support PowerWall")
        lbl.font = .systemFont(ofSize: 13, weight: .semibold)
        lbl.textColor = .labelColor
        lbl.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(lbl)

        let sub = NSTextField(labelWithString: "buymeacoffee.com/weoxstudio")
        sub.font = .systemFont(ofSize: 11)
        sub.textColor = .secondaryLabelColor
        sub.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(sub)

        let btn = NSButton(title: "Buy me a coffee", target: self, action: #selector(openCoffee))
        btn.bezelStyle = .rounded
        btn.font = .systemFont(ofSize: 12, weight: .medium)
        btn.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(btn)

        NSLayoutConstraint.activate([
            emoji.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 14),
            emoji.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            lbl.leadingAnchor.constraint(equalTo: emoji.trailingAnchor, constant: 10),
            lbl.topAnchor.constraint(equalTo: row.topAnchor, constant: 9),

            sub.leadingAnchor.constraint(equalTo: lbl.leadingAnchor),
            sub.topAnchor.constraint(equalTo: lbl.bottomAnchor, constant: 2),

            btn.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -14),
            btn.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        return row
    }

    @objc private func openCoffee() {
        NSWorkspace.shared.open(URL(string: "https://buymeacoffee.com/weoxstudio")!)
    }

    // MARK: - Language Row

    private func makeLangRow() -> NSView {
        let row = NSView()
        row.wantsLayer = true
        row.layer?.cornerRadius = 10
        row.layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        row.layer?.borderColor = NSColor.separatorColor.cgColor
        row.layer?.borderWidth = 0.5
        row.translatesAutoresizingMaskIntoConstraints = false
        row.heightAnchor.constraint(equalToConstant: 44).isActive = true

        let iv = NSImageView()
        iv.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
        iv.contentTintColor = .controlAccentColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(iv)

        let lbl = NSTextField(labelWithString: L.s(.language))
        lbl.font = .systemFont(ofSize: 13)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(lbl)

        let popup = NSPopUpButton()
        popup.isBordered = true
        popup.bezelStyle = .rounded
        popup.font = .systemFont(ofSize: 12)
        popup.translatesAutoresizingMaskIntoConstraints = false

        for lang in AppLanguage.allCases {
            popup.addItem(withTitle: lang.displayName)
            popup.lastItem?.representedObject = lang
        }
        for item in popup.itemArray {
            if let l = item.representedObject as? AppLanguage, l == L.lang {
                popup.select(item)
            }
        }
        popup.target = self
        popup.action = #selector(languageChanged(_:))
        row.addSubview(popup)

        NSLayoutConstraint.activate([
            iv.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 14),
            iv.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 20),
            iv.heightAnchor.constraint(equalToConstant: 20),

            lbl.leadingAnchor.constraint(equalTo: iv.trailingAnchor, constant: 10),
            lbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            popup.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -14),
            popup.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            popup.widthAnchor.constraint(equalToConstant: 110),
        ])
        return row
    }

    // MARK: - Actions

    @objc private func openLoginItems() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func languageChanged(_ sender: NSPopUpButton) {
        guard let lang = sender.selectedItem?.representedObject as? AppLanguage else { return }
        L.lang = lang
        // Rebuild to apply new language
        window?.contentView?.subviews.forEach { $0.removeFromSuperview() }
        buildUI()
        loadPrefs()
    }

    @objc private func batterySegmentChanged() {
        switch batterySegment.selectedSegment {
        case 0: batteryMode = "same";    batteryCard.isHidden = true
        case 1: batteryMode = "default"; batteryCard.isHidden = true
        case 2: batteryMode = "custom";  batteryCard.isHidden = false
        default: break
        }
    }

    private func loadPrefs() {
        pluggedURL  = prefs.pluggedURL
        batteryMode = prefs.batteryMode
        batteryURL  = prefs.batteryURL
        pluggedCard.setURL(pluggedURL)
        batteryCard.setURL(batteryURL)
        switch batteryMode {
        case "same":    batterySegment.selectedSegment = 0; batteryCard.isHidden = true
        case "default": batterySegment.selectedSegment = 1; batteryCard.isHidden = true
        case "custom":  batterySegment.selectedSegment = 2; batteryCard.isHidden = false
        default:        batterySegment.selectedSegment = 0; batteryCard.isHidden = true
        }
    }

    @objc private func save() {
        prefs.pluggedURL  = pluggedURL
        prefs.batteryMode = batteryMode
        prefs.batteryURL  = batteryURL
        settingsDelegate?.settingsDidChange()
        window?.close()
    }

    @objc private func cancel() { window?.close() }
    func windowWillClose(_ notification: Notification) {}
}

// MARK: - MediaCard

final class MediaCard: NSView {
    var onPick: ((URL) -> Void)?
    var onClear: (() -> Void)?

    private let iconView   = NSImageView()
    private let nameLabel  = NSTextField(labelWithString: "")
    private let subLabel   = NSTextField(labelWithString: "")
    private let pickBtn    : NSButton
    private let clearBtn   : NSButton
    let headerLabel        : NSTextField
    private let accent: NSColor

    init(label: String, icon: String, accent: NSColor) {
        self.accent = accent
        self.headerLabel = NSTextField(labelWithString: label)
        self.pickBtn  = NSButton(title: L.s(.pick),  target: nil, action: nil)
        self.clearBtn = NSButton(title: L.s(.clear), target: nil, action: nil)
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 12
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.5).cgColor
        layer?.borderWidth = 0.5

        // Icon badge
        let iconBg = NSView()
        iconBg.wantsLayer = true
        iconBg.layer?.cornerRadius = 8
        iconBg.layer?.backgroundColor = accent.withAlphaComponent(0.12).cgColor
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        iconView.translatesAutoresizingMaskIntoConstraints = false
        if let img = NSImage(systemSymbolName: icon, accessibilityDescription: nil) {
            iconView.image = img
        }
        iconView.contentTintColor = accent
        iconBg.addSubview(iconView)

        headerLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.stringValue = L.s(.noFileSelected)
        nameLabel.font = .systemFont(ofSize: 12)
        nameLabel.textColor = .secondaryLabelColor
        nameLabel.lineBreakMode = .byTruncatingMiddle
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        subLabel.stringValue = L.s(.fileFormats)
        subLabel.font = .systemFont(ofSize: 11)
        subLabel.textColor = .tertiaryLabelColor
        subLabel.translatesAutoresizingMaskIntoConstraints = false

        pickBtn.bezelStyle = .rounded
        pickBtn.font = .systemFont(ofSize: 12, weight: .medium)
        pickBtn.translatesAutoresizingMaskIntoConstraints = false
        pickBtn.target = self; pickBtn.action = #selector(doPick)

        clearBtn.bezelStyle = .rounded
        clearBtn.font = .systemFont(ofSize: 12)
        clearBtn.translatesAutoresizingMaskIntoConstraints = false
        clearBtn.target = self; clearBtn.action = #selector(doClear)
        clearBtn.isEnabled = false

        [iconBg, headerLabel, nameLabel, subLabel, pickBtn, clearBtn].forEach { addSubview($0) }

        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconBg.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            iconBg.widthAnchor.constraint(equalToConstant: 36),
            iconBg.heightAnchor.constraint(equalToConstant: 36),

            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 18),
            iconView.heightAnchor.constraint(equalToConstant: 18),

            headerLabel.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 10),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),

            nameLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 2),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),

            subLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            subLabel.topAnchor.constraint(equalTo: iconBg.bottomAnchor, constant: 8),

            pickBtn.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            pickBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            clearBtn.trailingAnchor.constraint(equalTo: pickBtn.leadingAnchor, constant: -8),
            clearBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            bottomAnchor.constraint(equalTo: subLabel.bottomAnchor, constant: 44),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func setURL(_ url: URL?) {
        nameLabel.stringValue = url?.lastPathComponent ?? L.s(.noFileSelected)
        nameLabel.textColor = url == nil ? .secondaryLabelColor : .labelColor
        subLabel.isHidden = url != nil
        clearBtn.isEnabled = url != nil
        layer?.borderColor = url != nil
            ? accent.withAlphaComponent(0.4).cgColor
            : NSColor.separatorColor.withAlphaComponent(0.5).cgColor
    }

    @objc private func doPick() {
        guard let w = window else { return }
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            .mpeg4Movie, .gif, .jpeg, .png, .heic,
            UTType(filenameExtension: "jpg") ?? .jpeg,
            UTType(filenameExtension: "webp") ?? .png,
        ]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.beginSheetModal(for: w) { [weak self] resp in
            if resp == .OK, let url = panel.url { self?.onPick?(url) }
        }
    }

    @objc private func doClear() { setURL(nil); onClear?() }
}
