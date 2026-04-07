import AppKit
import MetalKit

final class OverlayManager {
    private var overlayWindows: [NSScreen: NSWindow] = [:]
    private var renderers: [NSWindow: MetalRenderer] = [:]
    private let device: MTLDevice?

    init() {
        self.device = MTLCreateSystemDefaultDevice()
    }

    func showOverlays(brightness: Double) {
        hideOverlays()

        guard let device = device else { return }

        for screen in NSScreen.screens {
            // Only create overlays for EDR-capable screens
            guard screen.maximumPotentialExtendedDynamicRangeColorComponentValue > 1.0 else {
                continue
            }

            let window = createOverlayWindow(for: screen)
            let mtkView = createMetalView(device: device, in: window)
            let renderer = MetalRenderer(device: device, mtkView: mtkView, brightness: brightness)
            mtkView.delegate = renderer

            overlayWindows[screen] = window
            renderers[window] = renderer

            window.orderFrontRegardless()
        }
    }

    func hideOverlays() {
        for (_, window) in overlayWindows {
            window.orderOut(nil)
        }
        overlayWindows.removeAll()
        renderers.removeAll()
    }

    func updateBrightness(_ brightness: Double) {
        for (_, renderer) in renderers {
            renderer.brightness = brightness
        }
    }

    func rebuildOverlays(brightness: Double) {
        hideOverlays()
        showOverlays(brightness: brightness)
    }

    /// Check if all overlay windows are still visible (macOS can kill them after sleep)
    func checkOverlaysAlive() -> Bool {
        guard !overlayWindows.isEmpty else { return false }
        return overlayWindows.values.allSatisfy { $0.isVisible }
    }

    private func createOverlayWindow(for screen: NSScreen) -> NSWindow {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false,
            screen: screen
        )

        window.level = .screenSaver
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.hidesOnDeactivate = false
        window.sharingType = .none  // Don't appear in screenshots/recordings
        window.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary
        ]
        window.setFrame(screen.frame, display: true)

        // CRITICAL: multiply compositing filter blends the overlay with screen content.
        // Without this, the overlay would be an opaque white rectangle.
        // With multiply, a clearColor of (2.0, 2.0, 2.0) doubles the brightness
        // of everything underneath while preserving colors.
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.compositingFilter = "multiplyBlendMode"

        return window
    }

    private func createMetalView(device: MTLDevice, in window: NSWindow) -> MTKView {
        let mtkView = MTKView(frame: window.contentView!.bounds, device: device)
        mtkView.autoresizingMask = [.width, .height]
        mtkView.layer?.isOpaque = false
        mtkView.colorPixelFormat = .rgba16Float

        if let metalLayer = mtkView.layer as? CAMetalLayer {
            metalLayer.wantsExtendedDynamicRangeContent = true
            metalLayer.colorspace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)
            metalLayer.pixelFormat = .rgba16Float
            metalLayer.isOpaque = false
        }

        // Low FPS — we're just filling a solid color, no animation needed
        mtkView.isPaused = false
        mtkView.preferredFramesPerSecond = 10

        window.contentView?.addSubview(mtkView)

        return mtkView
    }
}
