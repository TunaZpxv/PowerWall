import Foundation

// MARK: - Language

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case turkish = "tr"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        }
    }
}

// MARK: - Strings

final class L {
    static var lang: AppLanguage {
        get {
            let raw = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
            return AppLanguage(rawValue: raw) ?? .english
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "appLanguage")
        }
    }

    static func s(_ key: LocalKey) -> String {
        switch lang {
        case .english: return key.en
        case .turkish: return key.tr
        }
    }
}

enum LocalKey {
    // App
    case appTagline
    case version

    // Onboarding
    case onboardingTitle
    case onboardingSubtitle
    case step1
    case step2
    case step3
    case start
    case skip
    case language

    // Settings
    case settingsTitle
    case pluggedSection
    case batterySection
    case batteryModeSame
    case batteryModeDefault
    case batteryModeCustom
    case noFileSelected
    case fileFormats
    case pick
    case clear
    case save
    case cancel

    // Login / permission
    case loginTitle
    case loginSub
    case loginPermissionTitle
    case loginPermissionSub
    case loginPermissionButton
    case loginPermissionWarning

    // Status
    case statusDefault
    case statusInactive
    case statusEnable
    case statusDisable
    case menuSettings
    case menuLoginItems
    case menuQuit
    case pluggedStatus
    case batteryStatus
    case pluggedIn
    case unplugged
    case onBattery
    case welcomeTitle
    case welcomeBody
    case welcomeStart
    case welcomeLater

    var en: String {
        switch self {
        case .appTagline:           return "Power-aware\nwallpaper"
        case .version:              return "v1.0"
        case .onboardingTitle:      return "Welcome 👋"
        case .onboardingSubtitle:   return "Ready in three steps:"
        case .step1:                return "Pick a wallpaper for when you're plugged in"
        case .step2:                return "Choose a different image or default macOS on battery"
        case .step3:                return "Change anytime from the menu bar"
        case .start:                return "Get Started"
        case .skip:                 return "Skip"
        case .language:             return "Language"
        case .settingsTitle:        return "Settings"
        case .pluggedSection:       return "When Plugged In"
        case .batterySection:       return "Battery"
        case .batteryModeSame:      return "Same as plugged"
        case .batteryModeDefault:   return "macOS default"
        case .batteryModeCustom:    return "Custom file"
        case .noFileSelected:       return "No file selected"
        case .fileFormats:          return "MP4, GIF, JPG, PNG supported"
        case .pick:                 return "Choose…"
        case .clear:                return "Remove"
        case .save:                 return "Save"
        case .cancel:               return "Cancel"
        case .loginTitle:           return "Launch at Login"
        case .loginSub:             return "PowerWall starts automatically on login"
        case .loginPermissionTitle: return "Allow Launch at Login"
        case .loginPermissionSub:   return "macOS requires your permission for automatic startup"
        case .loginPermissionButton:return "Allow in Settings"
        case .loginPermissionWarning: return "⚠️ Launch at Login not permitted — tap to allow"
        case .statusDefault:        return "Default"
        case .statusInactive:       return "Inactive"
        case .statusEnable:         return "Enable"
        case .statusDisable:        return "Disable"
        case .menuSettings:         return "Settings…"
        case .menuLoginItems:       return "Launch at Login…"
        case .menuQuit:             return "Quit"
        case .pluggedStatus:        return "🔌"
        case .batteryStatus:        return "🔋"
        case .pluggedIn:            return "Plugged In"
        case .unplugged:            return "On Battery"
        case .onBattery:            return "On Battery"
        case .welcomeTitle:         return "PowerWall Installed"
        case .welcomeBody:          return "PowerWall is running in your menu bar.\nWould you like to set up your wallpapers now?"
        case .welcomeStart:         return "Open Settings"
        case .welcomeLater:         return "Later"
        }
    }

    var tr: String {
        switch self {
        case .appTagline:           return "Güç odaklı\nduvar kağıdı"
        case .version:              return "v1.0"
        case .onboardingTitle:      return "Hoş geldin 👋"
        case .onboardingSubtitle:   return "Üç adımda hazır:"
        case .step1:                return "Prize bağlıyken kullanılacak duvar kağıdını seç"
        case .step2:                return "Pilde farklı bir görsel veya varsayılan macOS seç"
        case .step3:                return "Menü çubuğundan dilediğin zaman değiştir"
        case .start:                return "Başla"
        case .skip:                 return "Atla"
        case .language:             return "Dil"
        case .settingsTitle:        return "Ayarlar"
        case .pluggedSection:       return "Prize bağlıyken"
        case .batterySection:       return "Pil Ayarı"
        case .batteryModeSame:      return "Prizdekilyle aynı"
        case .batteryModeDefault:   return "Varsayılan macOS"
        case .batteryModeCustom:    return "Farklı dosya"
        case .noFileSelected:       return "Dosya seçilmedi"
        case .fileFormats:          return "MP4, GIF, JPG, PNG desteklenir"
        case .pick:                 return "Seç…"
        case .clear:                return "Kaldır"
        case .save:                 return "Kaydet"
        case .cancel:               return "İptal"
        case .loginTitle:           return "Açılışta otomatik başlat"
        case .loginSub:             return "Mac açıldığında PowerWall otomatik çalışır"
        case .loginPermissionTitle: return "Otomatik Başlatmaya İzin Ver"
        case .loginPermissionSub:   return "macOS, otomatik başlatma için izin gerektiriyor"
        case .loginPermissionButton:return "Ayarlarda İzin Ver"
        case .loginPermissionWarning: return "⚠️ Otomatik başlatma izni yok — izin vermek için dokun"
        case .statusDefault:        return "Varsayılan"
        case .statusInactive:       return "Pasif"
        case .statusEnable:         return "Etkinleştir"
        case .statusDisable:        return "Devre Dışı Bırak"
        case .menuSettings:         return "Ayarlar…"
        case .menuLoginItems:       return "Açılışta Başlat…"
        case .menuQuit:             return "Çıkış"
        case .pluggedStatus:        return "🔌"
        case .batteryStatus:        return "🔋"
        case .pluggedIn:            return "Prize Bağlı"
        case .unplugged:            return "Pilde"
        case .onBattery:            return "Pilde"
        case .welcomeTitle:         return "PowerWall Kuruldu"
        case .welcomeBody:          return "PowerWall menü çubuğunda çalışıyor.\nŞimdi duvar kağıtlarını ayarlamak ister misiniz?"
        case .welcomeStart:         return "Ayarları Aç"
        case .welcomeLater:         return "Sonra"
        }
    }
}
