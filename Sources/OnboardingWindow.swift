import AppKit

final class OnboardingWindow: NSWindowController {
    convenience init() {
        let win = NSWindow(contentRect: NSRect(x:0,y:0,width:480,height:320), styleMask:[.titled,.closable], backing:.buffered, defer:false)
        win.title = "PowerWall Kurulum"
        win.center()
        self.init(window: win)
        let v = NSView(frame: win.contentRect(forFrameRect: win.frame))
        win.contentView = v
        let t = NSTextField(labelWithString: "PowerWall'a hoş geldin")
        t.font = .systemFont(ofSize: 20, weight: .bold)
        t.frame = NSRect(x: 40, y: 250, width: 400, height: 30)
        v.addSubview(t)
        let b = NSButton(title: "Açılışta başlat (Sistem Ayarları)", target: self, action: #selector(openLogin))
        b.frame = NSRect(x: 40, y: 180, width: 400, height: 32)
        v.addSubview(b)
        let ok = NSButton(title: "Başla", target: self, action: #selector(closeWin))
        ok.frame = NSRect(x: 360, y: 40, width: 80, height: 32)
        ok.keyEquivalent = "\r"
        v.addSubview(ok)
    }
    @objc func openLogin() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") { NSWorkspace.shared.open(url) }
    }
    @objc func closeWin() { window?.close(); UserDefaults.standard.set(true, forKey: "onboarded") }
}
