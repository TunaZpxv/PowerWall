import Foundation

final class Prefs {
    static let shared = Prefs()
    private let d = UserDefaults.standard

    // Prize bağlıyken kullanılacak dosya
    var pluggedURL: URL? {
        get { d.url(forKey: "pluggedURL") }
        set { d.set(newValue, forKey: "pluggedURL") }
    }

    // Pildeyken davranış modu
    // "same"    → prizdekilyle aynı
    // "default" → varsayılan macOS duvar kağıdı
    // "custom"  → batteryURL'deki dosya
    var batteryMode: String {
        get { d.string(forKey: "batteryMode") ?? "same" }
        set { d.set(newValue, forKey: "batteryMode") }
    }

    // Pildeyken özel dosya (batteryMode == "custom" ise)
    var batteryURL: URL? {
        get { d.url(forKey: "batteryURL") }
        set { d.set(newValue, forKey: "batteryURL") }
    }

    // Aktif/pasif
    var enabled: Bool {
        get { d.object(forKey: "enabled") == nil ? true : d.bool(forKey: "enabled") }
        set { d.set(newValue, forKey: "enabled") }
    }

    /// Güç durumuna göre ne yapılacağına karar ver
    enum WallpaperAction {
        case setURL(URL)       // bu URL'yi ayarla
        case setDefault        // varsayılan macOS duvar kağıdı
        case doNothing         // değiştirme
    }

    func resolveAction(pluggedIn: Bool) -> WallpaperAction {
        guard enabled else { return .doNothing }

        if pluggedIn {
            if let url = pluggedURL { return .setURL(url) }
            return .doNothing
        } else {
            switch batteryMode {
            case "same":
                if let url = pluggedURL { return .setURL(url) }
                return .doNothing
            case "default":
                return .setDefault
            case "custom":
                if let url = batteryURL { return .setURL(url) }
                return .doNothing
            default:
                return .doNothing
            }
        }
    }
}
