import Foundation
import IOKit.ps

final class PowerMonitor {
    var onChange: ((Bool) -> Void)?
    private var source: CFRunLoopSource?
    private var burstTimer: Timer?
    private var steadyTimer: Timer?
    private(set) var isPluggedIn: Bool = true

    func start() {
        isPluggedIn = readPowerState()

        // IOKit callback — common modlara ekle (menü açıkken de çalışsın)
        let ctx = Unmanaged.passRetained(self).toOpaque()
        let src = IOPSNotificationCreateRunLoopSource({ ptr in
            guard let ptr else { return }
            let m = Unmanaged<PowerMonitor>.fromOpaque(ptr).takeUnretainedValue()
            m.startBurstPolling()
        }, ctx)?.takeRetainedValue()

        if let src {
            self.source = src
            CFRunLoopAddSource(CFRunLoopGetMain(), src, .commonModes)
        }

        // Yedek sabit polling: 1 saniyede bir — common modlarda (menü açıkken de çalışsın)
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkAndNotify()
        }
        RunLoop.main.add(timer, forMode: .common)
        steadyTimer = timer
    }

    /// Güç değişimi anında 100ms aralıklarla 10 kez kontrol — gecikmeyi sıfırlar
    private func startBurstPolling() {
        burstTimer?.invalidate()
        var count = 0
        let timer = Timer(timeInterval: 0.1, repeats: true) { [weak self] t in
            self?.checkAndNotify()
            count += 1
            if count >= 10 { t.invalidate() }
        }
        RunLoop.main.add(timer, forMode: .common)
        burstTimer = timer
    }

    private func checkAndNotify() {
        let new = readPowerState()
        if new != isPluggedIn {
            isPluggedIn = new
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.onChange?(self.isPluggedIn)
            }
        }
    }

    private func readPowerState() -> Bool {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else { return true }
        guard let list = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
              !list.isEmpty else { return true }
        for src in list {
            if let desc = IOPSGetPowerSourceDescription(snapshot, src)?.takeUnretainedValue() as? [String: Any] {
                let state = desc[kIOPSPowerSourceStateKey] as? String ?? kIOPSACPowerValue
                return state == kIOPSACPowerValue
            }
        }
        return true
    }

    deinit {
        burstTimer?.invalidate()
        steadyTimer?.invalidate()
        if let src = source { CFRunLoopRemoveSource(CFRunLoopGetMain(), src, .defaultMode) }
    }
}
