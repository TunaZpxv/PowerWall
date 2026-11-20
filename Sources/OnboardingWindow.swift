import AppKit

// MARK: - OnboardingWindow

final class OnboardingWindow: NSWindowController, NSWindowDelegate {

    var onFinish: (() -> Void)?

    // Strong refs
    private var startBtn: ClickableButton!
    private var skipBtn:  ClickableButton!
    private var langPopup: NSPopUpButton!

    convenience init() {
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 580, height: 460),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        win.title = ""
        win.titlebarAppearsTransparent = true
        win.backgroundColor = .windowBackgroundColor
        win.center()
        self.init(window: win)
        win.delegate = self
        setupUI()
    }

    private func setupUI() {
        guard let cv = window?.contentView else { return }
        cv.subviews.forEach { $0.removeFromSuperview() }
        cv.wantsLayer = true

        // ── Left gradient panel ──────────────────────────────────
        let leftPanel = GradientPanel(frame: .zero)
        leftPanel.translatesAutoresizingMaskIntoConstraints = false
        cv.addSubview(leftPanel)

        let appIcon = NSImageView()
        appIcon.image = NSApp.applicationIconImage
        appIcon.imageScaling = .scaleProportionallyUpOrDown
        appIcon.translatesAutoresizingMaskIntoConstraints = false
        leftPanel.addSubview(appIcon)

        let appName = makeLabel("PowerWall", size: 22, weight: .bold, color: .white)
        let appSub  = makeLabel(L.s(.appTagline), size: 12, weight: .regular,
                                color: NSColor.white.withAlphaComponent(0.7))
        appName.translatesAutoresizingMaskIntoConstraints = false
        appSub.translatesAutoresizingMaskIntoConstraints = false
        appSub.maximumNumberOfLines = 2
        appSub.alignment = .center
        leftPanel.addSubview(appName)
        leftPanel.addSubview(appSub)

        let pill = PillView(text: L.s(.version))
        pill.translatesAutoresizingMaskIntoConstraints = false
        leftPanel.addSubview(pill)

        // Language picker at bottom of left panel
        let langRow = makeLangRow()
        langRow.translatesAutoresizingMaskIntoConstraints = false
        leftPanel.addSubview(langRow)

        // ── Right content ────────────────────────────────────────
        let welcome = makeLabel(L.s(.onboardingTitle), size: 20, weight: .semibold, color: .labelColor)
        let desc    = makeLabel(L.s(.onboardingSubtitle), size: 13, weight: .regular,
                                color: .secondaryLabelColor)
        welcome.translatesAutoresizingMaskIntoConstraints = false
        desc.translatesAutoresizingMaskIntoConstraints = false
        cv.addSubview(welcome)
        cv.addSubview(desc)

        // Step cards
        let stepData: [(String, LocalKey)] = [
            ("bolt.fill",             .step1),
            ("battery.50",            .step2),
            ("checkmark.circle.fill", .step3),
        ]
        var prevAnchor = desc.bottomAnchor
        var prevConst: CGFloat = 12
        for (icon, key) in stepData {
            let card = StepCard(icon: icon, text: L.s(key))
            card.translatesAutoresizingMaskIntoConstraints = false
            cv.addSubview(card)
            NSLayoutConstraint.activate([
                card.topAnchor.constraint(equalTo: prevAnchor, constant: prevConst),
                card.leadingAnchor.constraint(equalTo: welcome.leadingAnchor),
                card.trailingAnchor.constraint(equalTo: cv.trailingAnchor, constant: -24),
                card.heightAnchor.constraint(equalToConstant: 56),
            ])
            prevAnchor = card.bottomAnchor
            prevConst = 8
        }

        // Buttons
        startBtn = ClickableButton(title: L.s(.start), style: .primary)
        skipBtn  = ClickableButton(title: L.s(.skip),  style: .ghost)
        startBtn.translatesAutoresizingMaskIntoConstraints = false
        skipBtn.translatesAutoresizingMaskIntoConstraints  = false
        startBtn.onClick = { [weak self] in self?.finish() }
        skipBtn.onClick  = { [weak self] in self?.finish() }
        cv.addSubview(startBtn)
        cv.addSubview(skipBtn)

        // ── Constraints ──────────────────────────────────────────
        NSLayoutConstraint.activate([
            leftPanel.leadingAnchor.constraint(equalTo: cv.leadingAnchor),
            leftPanel.topAnchor.constraint(equalTo: cv.topAnchor),
            leftPanel.bottomAnchor.constraint(equalTo: cv.bottomAnchor),
            leftPanel.widthAnchor.constraint(equalToConstant: 200),

            appIcon.centerXAnchor.constraint(equalTo: leftPanel.centerXAnchor),
            appIcon.topAnchor.constraint(equalTo: leftPanel.topAnchor, constant: 52),
            appIcon.widthAnchor.constraint(equalToConstant: 72),
            appIcon.heightAnchor.constraint(equalToConstant: 72),

            appName.centerXAnchor.constraint(equalTo: leftPanel.centerXAnchor),
            appName.topAnchor.constraint(equalTo: appIcon.bottomAnchor, constant: 12),

            appSub.centerXAnchor.constraint(equalTo: leftPanel.centerXAnchor),
            appSub.topAnchor.constraint(equalTo: appName.bottomAnchor, constant: 6),
            appSub.leadingAnchor.constraint(equalTo: leftPanel.leadingAnchor, constant: 12),
            appSub.trailingAnchor.constraint(equalTo: leftPanel.trailingAnchor, constant: -12),

            pill.centerXAnchor.constraint(equalTo: leftPanel.centerXAnchor),
            pill.topAnchor.constraint(equalTo: appSub.bottomAnchor, constant: 12),
            pill.widthAnchor.constraint(equalToConstant: 48),
            pill.heightAnchor.constraint(equalToConstant: 22),

            langRow.centerXAnchor.constraint(equalTo: leftPanel.centerXAnchor),
            langRow.bottomAnchor.constraint(equalTo: leftPanel.bottomAnchor, constant: -20),
            langRow.leadingAnchor.constraint(equalTo: leftPanel.leadingAnchor, constant: 12),
            langRow.trailingAnchor.constraint(equalTo: leftPanel.trailingAnchor, constant: -12),
            langRow.heightAnchor.constraint(equalToConstant: 28),

            welcome.leadingAnchor.constraint(equalTo: leftPanel.trailingAnchor, constant: 24),
            welcome.topAnchor.constraint(equalTo: cv.topAnchor, constant: 36),

            desc.leadingAnchor.constraint(equalTo: welcome.leadingAnchor),
            desc.topAnchor.constraint(equalTo: welcome.bottomAnchor, constant: 4),

            startBtn.trailingAnchor.constraint(equalTo: cv.trailingAnchor, constant: -24),
            startBtn.bottomAnchor.constraint(equalTo: cv.bottomAnchor, constant: -20),
            startBtn.widthAnchor.constraint(equalToConstant: 120),
            startBtn.heightAnchor.constraint(equalToConstant: 38),

            skipBtn.trailingAnchor.constraint(equalTo: startBtn.leadingAnchor, constant: -8),
            skipBtn.centerYAnchor.constraint(equalTo: startBtn.centerYAnchor),
            skipBtn.widthAnchor.constraint(equalToConstant: 70),
            skipBtn.heightAnchor.constraint(equalToConstant: 38),
        ])
    }

    // MARK: - Language row (native NSPopUpButton, bordered so it's always hittable)

    private func makeLangRow() -> NSView {
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let lbl = NSTextField(labelWithString: L.s(.language) + ":")
        lbl.font = .systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = NSColor.white.withAlphaComponent(0.65)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(lbl)

        let popup = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 100, height: 24), pullsDown: false)
        popup.translatesAutoresizingMaskIntoConstraints = false
        popup.isBordered = true
        popup.bezelStyle = .rounded
        popup.font = .systemFont(ofSize: 11)
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
        self.langPopup = popup
        row.addSubview(popup)

        NSLayoutConstraint.activate([
            lbl.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            popup.leadingAnchor.constraint(equalTo: lbl.trailingAnchor, constant: 6),
            popup.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            popup.centerYAnchor.constraint(equalTo: row.centerYAnchor),
        ])
        return row
    }

    @objc private func languageChanged(_ sender: NSPopUpButton) {
        guard let lang = sender.selectedItem?.representedObject as? AppLanguage else { return }
        L.lang = lang
        setupUI()
    }

    // MARK: - Actions

    private func finish() {
        UserDefaults.standard.set(true, forKey: "onboarded")
        onFinish?()
        window?.close()
    }

    func windowWillClose(_ notification: Notification) {}

    private func makeLabel(_ text: String, size: CGFloat, weight: NSFont.Weight,
                            color: NSColor) -> NSTextField {
        let f = NSTextField(labelWithString: text)
        f.font = .systemFont(ofSize: size, weight: weight)
        f.textColor = color
        return f
    }
}

// MARK: - ClickableButton (NSView-based, layer never breaks hit-testing)

final class ClickableButton: NSView {
    enum Style { case primary, ghost }
    var onClick: (() -> Void)?

    private let label = NSTextField(labelWithString: "")
    private let style: Style
    private var trackingArea: NSTrackingArea?

    init(title: String, style: Style) {
        self.style = style
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 10
        label.stringValue = title
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.alignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isSelectable = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        applyStyle(pressed: false)
    }
    required init?(coder: NSCoder) { fatalError() }

    private func applyStyle(pressed: Bool) {
        switch style {
        case .primary:
            let alpha: CGFloat = pressed ? 0.65 : 1.0
            layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(alpha).cgColor
            label.textColor = .white
        case .ghost:
            layer?.backgroundColor = pressed
                ? NSColor.labelColor.withAlphaComponent(0.08).cgColor
                : NSColor.clear.cgColor
            label.textColor = .secondaryLabelColor
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let ta = trackingArea { removeTrackingArea(ta) }
        trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow],
            owner: self, userInfo: nil)
        addTrackingArea(trackingArea!)
    }

    override func mouseEntered(with event: NSEvent) {
        if style == .primary {
            layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.85).cgColor
        }
    }
    override func mouseExited(with event: NSEvent) { applyStyle(pressed: false) }
    override func mouseDown(with event: NSEvent)   { applyStyle(pressed: true) }
    override func mouseUp(with event: NSEvent) {
        applyStyle(pressed: false)
        let pt = convert(event.locationInWindow, from: nil)
        if bounds.contains(pt) { onClick?() }
    }
    override var acceptsFirstResponder: Bool { style == .primary }
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 { onClick?() } else { super.keyDown(with: event) }
    }
}

// MARK: - GradientPanel

final class GradientPanel: NSView {
    private let grad = CAGradientLayer()
    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        grad.colors = [
            NSColor(calibratedRed: 0.04, green: 0.14, blue: 0.08, alpha: 1).cgColor,
            NSColor(calibratedRed: 0.08, green: 0.30, blue: 0.20, alpha: 1).cgColor,
        ]
        grad.startPoint = CGPoint(x: 0, y: 1)
        grad.endPoint   = CGPoint(x: 1, y: 0)
        layer?.insertSublayer(grad, at: 0)
    }
    required init?(coder: NSCoder) { fatalError() }
    override func layout() { super.layout(); grad.frame = bounds }
}

// MARK: - PillView

final class PillView: NSView {
    init(text: String) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 11
        layer?.backgroundColor = NSColor.white.withAlphaComponent(0.2).cgColor
        let lbl = NSTextField(labelWithString: text)
        lbl.font = .systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = .white
        lbl.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - StepCard

final class StepCard: NSView {
    init(icon: String, text: String) {
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 10
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        layer?.borderColor = NSColor.separatorColor.withAlphaComponent(0.5).cgColor
        layer?.borderWidth = 0.5

        let iconBg = NSView()
        iconBg.wantsLayer = true
        iconBg.layer?.cornerRadius = 8
        iconBg.layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.12).cgColor
        iconBg.translatesAutoresizingMaskIntoConstraints = false

        let iv = NSImageView()
        iv.image = NSImage(systemSymbolName: icon, accessibilityDescription: nil)
        iv.contentTintColor = .controlAccentColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iv)

        let lbl = NSTextField(labelWithString: text)
        lbl.font = .systemFont(ofSize: 12)
        lbl.textColor = .labelColor
        lbl.lineBreakMode = .byWordWrapping
        lbl.maximumNumberOfLines = 2
        lbl.translatesAutoresizingMaskIntoConstraints = false

        addSubview(iconBg)
        addSubview(lbl)

        NSLayoutConstraint.activate([
            iconBg.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            iconBg.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconBg.widthAnchor.constraint(equalToConstant: 32),
            iconBg.heightAnchor.constraint(equalToConstant: 32),

            iv.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iv.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 16),
            iv.heightAnchor.constraint(equalToConstant: 16),

            lbl.leadingAnchor.constraint(equalTo: iconBg.trailingAnchor, constant: 10),
            lbl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            lbl.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}
