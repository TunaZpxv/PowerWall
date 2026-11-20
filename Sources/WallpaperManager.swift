import AppKit

/// Gerçek sistem duvar kağıdını NSWorkspace ile yönetir.
final class WallpaperManager {

    static let shared = WallpaperManager()

    // Uygulama başlamadan önceki orijinal duvar kağıdını sakla
    private var originalWallpaperURL: URL?
    private var currentURL: URL?

    init() {
        // Başlangıçta mevcut duvar kağıdını kaydet
        if let screen = NSScreen.main {
            originalWallpaperURL = NSWorkspace.shared.desktopImageURL(for: screen)
        }
    }

    /// Verilen URL'yi sistem duvar kağıdı olarak ayarla
    @discardableResult
    func set(url: URL) -> Bool {
        guard let screen = NSScreen.main else { return false }

        // Ekranı doldur + en yüksek kalite ayarları
        let options: [NSWorkspace.DesktopImageOptionKey: Any] = [
            .imageScaling: NSImageScaling.scaleProportionallyUpOrDown.rawValue,
            .allowClipping: true
        ]

        do {
            try NSWorkspace.shared.setDesktopImageURL(url, for: screen, options: options)
            currentURL = url
            return true
        } catch {
            return false
        }
    }

    /// Orijinal duvar kağıdına geri dön
    func restoreOriginal() {
        guard let url = originalWallpaperURL else { return }
        set(url: url)
        currentURL = url
    }

    /// Varsayılan macOS duvar kağıdını ayarla
    func setDefault() {
        // macOS varsayılan duvar kağıdı yolları (sürüme göre değişir)
        let candidates = [
            "/Library/Desktop Pictures/Sonoma.heic",
            "/Library/Desktop Pictures/Sequoia.heic",
            "/Library/Desktop Pictures/Tahoe.heic",
            "/Library/Desktop Pictures/Big Sur.heic",
            "/Library/Desktop Pictures/Monterey.heic",
            "/Library/Desktop Pictures/Ventura.heic",
        ]
        for path in candidates {
            let url = URL(fileURLWithPath: path)
            if FileManager.default.fileExists(atPath: path) {
                set(url: url)
                return
            }
        }
        // Hiçbiri yoksa Desktop Pictures'taki ilk dosyayı dene
        if let first = try? FileManager.default.contentsOfDirectory(
            at: URL(fileURLWithPath: "/Library/Desktop Pictures"),
            includingPropertiesForKeys: nil
        ).first {
            set(url: first)
        }
    }

    var currentWallpaperURL: URL? {
        guard let screen = NSScreen.main else { return nil }
        return NSWorkspace.shared.desktopImageURL(for: screen)
    }
}
