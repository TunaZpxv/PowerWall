import AppKit
import UniformTypeIdentifiers

protocol SettingsDelegate: AnyObject {
    func settingsDidChange()
}

final class SettingsWindow: NSWindowController, NSWindowDelegate {
    weak var settingsDelegate: SettingsDelegate?
    private let prefs = Prefs.shared

    private var pluggedURL: URL?
    private var batteryMode: String = "same"
    private var batteryURL: URL?

    // UI
    private let pluggedCard = MediaCard(label: "Prize bağlıyken", icon: "bolt.fill")
    private let batterySegment = NSSegmentedControl()
    private let batteryCard = MediaCard(label: "Pildeyken özel dosya", icon: "battery.50")
    private let saveBtn = NSButton(title: "Kaydet", target: nil, action: nil)
    private let cancelBtn = NSButton(title: "İptal", target: nil, action: nil)
    private let batteryHeader = NSTextField(labelWithString: "Pildeyken")

    convenience init() {
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 420),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        win.title = "PowerWall — Ayarlar"
        win.center()
        self.init(window: win)
        win.delegate = self
        buildUI()
        loadPrefs()
    }

    private func buildUI() {
        guard let cv = window?.contentView else { return }

        let titleLabel = NSTextField(labelWithString: "Duvar Kağıdı Ayarları")
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)

        // Priz kartı
        pluggedCard.onPick = { [weak self] url in
            self?.pluggedURL = url
            self?.pluggedCard.setURL(url)
        }
        pluggedCard.onClear = { [weak self] in
            self?.pluggedURL = nil
            self?.pluggedCard.setURL(nil)
        }

        // Pil segmented control
        batterySegment.segmentCount = 3
        batterySegment.setLabel("Prizdekilyle aynı", forSegment: 0)
        batterySegment.setLabel("Varsayılan macOS", forSegment: 1)
        batterySegment.setLabel("Farklı dosya seç", forSegment: 2)
        batterySegment.trackingMode = .selectOne
        batterySegment.selectedSegment = 0
        batterySegment.target = self
        batterySegment.action = #selector(batterySegmentChanged)

        batteryHeader.font = .systemFont(ofSize: 13, weight: .medium)

        // Pil özel dosya kartı
        batteryCard.onPick = { [weak self] url in
            self?.batteryURL = url
            self?.batteryCard.setURL(url)
        }
        batteryCard.onClear = { [weak self] in
            self?.batteryURL = nil
            self?.batteryCard.setURL(nil)
        }
        batteryCard.isHidden = true

        // Kaydet / İptal
        saveBtn.bezelStyle = .rounded
        saveBtn.keyEquivalent = "\r"
        saveBtn.target = self
        saveBtn.action = #selector(save)

        cancelBtn.bezelStyle = .rounded
        cancelBtn.target = self
        cancelBtn.action = #selector(cancel)

        let sep = NSBox(); sep.boxType = .separator

        let stack = NSStackView(views: [
            titleLabel,
            pluggedCard,
            batteryHeader,
            batterySegment,
            batteryCard,
            sep
        ])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        let btnRow = NSStackView(views: [cancelBtn, saveBtn])
        btnRow.orientation = .horizontal
        btnRow.spacing = 8
        btnRow.translatesAutoresizingMaskIntoConstraints = false

        cv.addSubview(stack)
        cv.addSubview(btnRow)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: cv.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: cv.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: cv.topAnchor, constant: 24),

            pluggedCard.widthAnchor.constraint(equalTo: stack.widthAnchor),
            batterySegment.widthAnchor.constraint(equalTo: stack.widthAnchor),
            batteryCard.widthAnchor.constraint(equalTo: stack.widthAnchor),

            btnRow.trailingAnchor.constraint(equalTo: cv.trailingAnchor, constant: -24),
            btnRow.bottomAnchor.constraint(equalTo: cv.bottomAnchor, constant: -20),
        ])
    }

    private func loadPrefs() {
        pluggedURL = prefs.pluggedURL
        batteryMode = prefs.batteryMode
        batteryURL = prefs.batteryURL

        pluggedCard.setURL(pluggedURL)
        batteryCard.setURL(batteryURL)

        switch batteryMode {
        case "same":    batterySegment.selectedSegment = 0; batteryCard.isHidden = true
        case "default": batterySegment.selectedSegment = 1; batteryCard.isHidden = true
        case "custom":  batterySegment.selectedSegment = 2; batteryCard.isHidden = false
        default:        batterySegment.selectedSegment = 0; batteryCard.isHidden = true
        }
    }

    @objc private func batterySegmentChanged() {
        switch batterySegment.selectedSegment {
        case 0: batteryMode = "same";    batteryCard.isHidden = true
        case 1: batteryMode = "default"; batteryCard.isHidden = true
        case 2: batteryMode = "custom";  batteryCard.isHidden = false
        default: break
        }
        window?.layoutIfNeeded()
    }

    @objc private func save() {
        prefs.pluggedURL = pluggedURL
        prefs.batteryMode = batteryMode
        prefs.batteryURL = batteryURL
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

    private let iconView  = NSImageView()
    private let nameLabel = NSTextField(labelWithString: "Dosya seçilmedi")
    private let pickBtn   = NSButton(title: "Seç…", target: nil, action: nil)
    private let clearBtn  = NSButton(title: "Kaldır", target: nil, action: nil)
    private let headerLabel: NSTextField

    init(label: String, icon: String) {
        headerLabel = NSTextField(labelWithString: label)
        super.init(frame: .zero)
        wantsLayer = true
        layer?.cornerRadius = 10
        layer?.backgroundColor = NSColor.controlBackgroundColor.cgColor
        layer?.borderColor = NSColor.separatorColor.cgColor
        layer?.borderWidth = 1

        headerLabel.font = .systemFont(ofSize: 13, weight: .medium)

        if let img = NSImage(systemSymbolName: icon, accessibilityDescription: nil) {
            iconView.image = img
            iconView.contentTintColor = .secondaryLabelColor
        }
        iconView.frame = NSRect(x: 0, y: 0, width: 18, height: 18)

        let headerStack = NSStackView(views: [iconView, headerLabel])
        headerStack.orientation = .horizontal
        headerStack.spacing = 6

        nameLabel.lineBreakMode = .byTruncatingMiddle
        nameLabel.textColor = .secondaryLabelColor
        nameLabel.font = .systemFont(ofSize: 12)

        pickBtn.bezelStyle = .rounded
        pickBtn.target = self
        pickBtn.action = #selector(doPick)

        clearBtn.bezelStyle = .rounded
        clearBtn.target = self
        clearBtn.action = #selector(doClear)
        clearBtn.isEnabled = false

        let btnRow = NSStackView(views: [clearBtn, pickBtn])
        btnRow.orientation = .horizontal
        btnRow.spacing = 8

        let stack = NSStackView(views: [headerStack, nameLabel, btnRow])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func setURL(_ url: URL?) {
        nameLabel.stringValue = url?.lastPathComponent ?? "Dosya seçilmedi"
        nameLabel.textColor = url == nil ? .secondaryLabelColor : .labelColor
        clearBtn.isEnabled = url != nil
    }

    func pick(in window: NSWindow) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [
            .mpeg4Movie, .gif, .jpeg, .png, .heic,
            UTType(filenameExtension: "jpg") ?? .jpeg,
            UTType(filenameExtension: "webp") ?? .png,
        ]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.beginSheetModal(for: window) { [weak self] resp in
            if resp == .OK, let url = panel.url { self?.onPick?(url) }
        }
    }

    @objc private func doPick() { guard let w = window else { return }; pick(in: w) }
    @objc private func doClear() { setURL(nil); onClear?() }
}
