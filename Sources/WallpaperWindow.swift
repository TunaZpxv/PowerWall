import AppKit
import AVFoundation
import AVKit

final class WallpaperWindow: NSWindow {
    private var playerLayer: AVPlayerLayer?
    private var staticLayer: CALayer?
    private var gifView: NSImageView?
    private var player: AVPlayer?
    private var loopObserver: NSObjectProtocol?
    private(set) var currentURL: URL?

    // Geçiş animasyonu için overlay pencere
    private var transitionWindow: NSWindow?

    init() {
        let screen = NSScreen.main ?? NSScreen.screens[0]
        super.init(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
        // desktopWindow + 1: masaüstü ikonlarının üstünde ama kilit ekranının altında
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        isOpaque = true
        hasShadow = false
        ignoresMouseEvents = true
        backgroundColor = .black
        contentView?.wantsLayer = true

        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(pause),
            name: NSWorkspace.screensDidSleepNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(resume),
            name: NSWorkspace.screensDidWakeNotification, object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(pause),
            name: NSNotification.Name("com.apple.screenIsLocked"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(resume),
            name: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil)
    }

    // MARK: - Yükleme (geçiş efektiyle)

    func load(url: URL, animated: Bool = true) {
        if animated {
            fadeTransition {
                self.loadMedia(url: url)
            }
        } else {
            loadMedia(url: url)
        }
    }

    private func loadMedia(url: URL) {
        currentURL = url
        clear()
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "gif":                                    loadGIF(url: url)
        case "jpg", "jpeg", "png", "heic", "webp":    loadStatic(url: url)
        default:                                       loadVideo(url: url)
        }
        orderFront(nil)
    }

    // MARK: - Fade geçiş efekti

    private func fadeTransition(completion: @escaping () -> Void) {
        guard let screen = NSScreen.main else { completion(); return }

        // Mevcut ekranı yakala
        let overlayWin = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        overlayWin.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)) + 1)
        overlayWin.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        overlayWin.isOpaque = false
        overlayWin.hasShadow = false
        overlayWin.ignoresMouseEvents = true
        overlayWin.backgroundColor = .black
        overlayWin.alphaValue = 0
        overlayWin.orderFront(nil)
        self.transitionWindow = overlayWin

        // Fade to black
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.4
            ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            overlayWin.animator().alphaValue = 1.0
        }, completionHandler: {
            // Yeni medyayı yükle
            completion()
            // Fade from black
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.5
                ctx.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                overlayWin.animator().alphaValue = 0
            }, completionHandler: {
                overlayWin.orderOut(nil)
                self.transitionWindow = nil
            })
        })
    }

    func clear() {
        player?.pause()
        if let obs = loopObserver { NotificationCenter.default.removeObserver(obs); loopObserver = nil }
        player = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        staticLayer?.removeFromSuperlayer()
        staticLayer = nil
        gifView?.removeFromSuperview()
        gifView = nil
    }

    func hide(animated: Bool = true) {
        if animated && currentURL != nil {
            fadeTransition {
                self.currentURL = nil
                self.clear()
                self.orderOut(nil)
            }
        } else {
            currentURL = nil
            clear()
            orderOut(nil)
        }
    }

    @objc func pause()  { player?.pause() }
    @objc func resume() { player?.play() }

    // MARK: - Video
    private func loadVideo(url: URL) {
        let item = AVPlayerItem(url: url)
        let p = AVPlayer(playerItem: item)
        p.isMuted = true
        p.actionAtItemEnd = .none
        p.preventsDisplaySleepDuringVideoPlayback = false
        self.player = p

        loopObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak p] _ in p?.seek(to: .zero); p?.play() }

        let layer = AVPlayerLayer(player: p)
        layer.frame = contentView!.bounds
        layer.videoGravity = .resizeAspectFill
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        contentView!.layer?.addSublayer(layer)
        self.playerLayer = layer
        p.play()
    }

    // MARK: - GIF
    private func loadGIF(url: URL) {
        guard let image = NSImage(contentsOf: url) else { return }
        let iv = NSImageView(frame: contentView!.bounds)
        iv.autoresizingMask = [.width, .height]
        iv.image = image
        iv.imageScaling = .scaleAxesIndependently
        iv.animates = true
        contentView?.addSubview(iv)
        self.gifView = iv
    }

    // MARK: - Statik
    private func loadStatic(url: URL) {
        guard let image = NSImage(contentsOf: url),
              let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        let layer = CALayer()
        layer.frame = contentView!.bounds
        layer.contentsGravity = .resizeAspectFill
        layer.contents = cgImage
        layer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        contentView!.layer?.addSublayer(layer)
        self.staticLayer = layer
    }
}
