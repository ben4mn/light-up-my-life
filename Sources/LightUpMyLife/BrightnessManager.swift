import AppKit
import Combine

final class BrightnessManager: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "isEnabled")
            if isEnabled {
                overlayManager.showOverlays(brightness: brightnessMultiplier)
                startWatchdog()
            } else {
                overlayManager.hideOverlays()
                stopWatchdog()
            }
        }
    }

    @Published var brightnessMultiplier: Double {
        didSet {
            let clamped = min(max(brightnessMultiplier, 1.0), maxMultiplier)
            if clamped != brightnessMultiplier {
                brightnessMultiplier = clamped
                return
            }
            UserDefaults.standard.set(brightnessMultiplier, forKey: "brightnessMultiplier")
            if isEnabled {
                overlayManager.updateBrightness(brightnessMultiplier)
            }
        }
    }

    var currentNits: Int {
        Int(500.0 * brightnessMultiplier)
    }

    var maxNits: Int {
        Int(500.0 * maxMultiplier)
    }

    var boostPercentage: Int {
        Int((brightnessMultiplier - 1.0) * 100.0)
    }

    @Published var isEDRSupported: Bool = false
    @Published var maxMultiplier: Double = 1.0

    private let overlayManager = OverlayManager()
    private var cancellables = Set<AnyCancellable>()
    private var watchdogTimer: Timer?

    init() {
        let savedEnabled = UserDefaults.standard.bool(forKey: "isEnabled")
        let savedMultiplier = UserDefaults.standard.double(forKey: "brightnessMultiplier")

        self.isEnabled = false
        self.brightnessMultiplier = savedMultiplier > 1.0 ? savedMultiplier : 1.6

        checkEDRSupport()
        setupNotifications()

        // Defer enabling to after init completes
        if savedEnabled && isEDRSupported {
            DispatchQueue.main.async { [weak self] in
                self?.isEnabled = true
            }
        }
    }

    private func checkEDRSupport() {
        guard let screen = NSScreen.main else {
            isEDRSupported = false
            maxMultiplier = 1.0
            return
        }

        let maxEDR = screen.maximumPotentialExtendedDynamicRangeColorComponentValue
        isEDRSupported = maxEDR > 1.0
        maxMultiplier = max(maxEDR, 1.0)

        if brightnessMultiplier > maxMultiplier {
            brightnessMultiplier = maxMultiplier
        }
    }

    private func setupNotifications() {
        // Re-check EDR support when displays change
        NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification)
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.checkEDRSupport()
                if let self = self, self.isEnabled {
                    self.overlayManager.rebuildOverlays(brightness: self.brightnessMultiplier)
                }
            }
            .store(in: &cancellables)

        // Re-apply overlays after wake from sleep
        NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification)
            .debounce(for: .seconds(2), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self, self.isEnabled else { return }
                self.overlayManager.rebuildOverlays(brightness: self.brightnessMultiplier)
            }
            .store(in: &cancellables)
    }

    // MARK: - Watchdog

    /// Periodically checks if overlay windows are still alive.
    /// macOS can kill them after sleep/wake or space transitions.
    private func startWatchdog() {
        stopWatchdog()
        watchdogTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self, self.isEnabled else { return }
            if !self.overlayManager.checkOverlaysAlive() {
                self.overlayManager.rebuildOverlays(brightness: self.brightnessMultiplier)
            }
        }
    }

    private func stopWatchdog() {
        watchdogTimer?.invalidate()
        watchdogTimer = nil
    }
}
