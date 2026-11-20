import AppKit

final class OnboardingWindow: NSWindowController {
    convenience init() {
        let win = NSWindow(contentRect: NSRect(x:0,y:0,width:520,height:360), styleMask:[.titled,.closable,.fullSizeContentView], backing:.buffered, defer:false)
        win.title = ""
        win.titlebarAppearsTransparent = true
        win.isMovableByWindowBackground = true
        win.center()
        self.init(window: win)
        let v = NSView(frame: win.contentRect(forFrameRect: win.frame))
        v.wantsLayer = true
        let grad = CAGradientLayer()
        grad.colors = [NSColor(calibratedRed:0.15,green:0.25,blue:0.6,alpha:1).cgColor, NSColor(calibratedRed:0.35,green:0.55,blue:0.85,alpha:1).cgColor]
        grad.frame = v.bounds
        v.layer?.insertSublayer(grad, at: 0)
        win.contentView = v

        let title = NSTextField(labelWithString: "PowerWall")
        title.font = .systemFont(ofSize: 30, weight: .bold)
        title.textColor = .white
        title.frame = NSRect(x: 40, y: 270, width: 440, height: 40)
        v.addSubview(title)

        let sub = NSTextField(labelWithString: "Duvar kağıdını güç durumuna göre otomatik değiştirir.")
        sub.font = .systemFont(ofSize: 14)
        sub.textColor = .white.withAlphaComponent(0.85)
        sub.frame = NSRect(x: 40, y: 240, width: 440, height: 24)
        v.addSubview(sub)

        let card = NSView(frame: NSRect(x: 40, y: 90, width: 440, height: 130))
        card.wantsLayer = true
        card.layer?.cornerRadius = 16
        card.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.15).cgColor
        v.addSubview(card)

        let t1 = NSTextField(labelWithString: "1. Prizde ve pilde farklı duvar kağıdı seç")
        t1.textColor = .white; t1.font = .systemFont(ofSize: 13)
        t1.frame = NSRect(x: 20, y: 80, width: 400, height: 20)
        card.addSubview(t1)
        let t2 = NSTextField(labelWithString: "2. Açılışta başlatmayı etkinleştir")
        t2.textColor = .white; t2.font = .systemFont(ofSize: 13)
        t2.frame = NSRect(x: 20, y: 50, width: 400, height: 20)
        card.addSubview(t2)
        let t3 = NSTextField(labelWithString: "3. Menü çubuğundan kontrol et")
        t3.textColor = .white; t3.font = .systemFont(ofSize: 13)
        t3.frame = NSRect(x: 20, y: 20, width: 400, height: 20)
        card.addSubview(t3)

        let loginBtn = NSButton(title: "Açılışta başlat", target: self, action: #selector(openLogin))
        loginBtn.bezelStyle = .rounded
        loginBtn.frame = NSRect(x: 40, y: 40, width: 160, height: 34)
        v.addSubview(loginBtn)

        let startBtn = NSButton(title: "Başla", target: self, action: #selector(closeWin))
        startBtn.bezelStyle = .rounded
        startBtn.keyEquivalent = "\r"
        startBtn.frame = NSRect(x: 360, y: 40, width: 120, height: 34)
        v.addSubview(startBtn)
    }
    @objc func openLogin() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") { NSWorkspace.shared.open(url) }
    }
    @objc func closeWin() { UserDefaults.standard.set(true, forKey: "onboarded"); window?.close() }
}
