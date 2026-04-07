import MetalKit

/// Minimal Metal renderer that fills the drawable with an EDR clear color.
/// No custom shaders needed — the clearColor mechanism fills the entire
/// drawable, and the "multiply" compositing filter on the window's layer
/// blends it with the screen content to boost brightness.
final class MetalRenderer: NSObject, MTKViewDelegate {
    private let commandQueue: MTLCommandQueue

    var brightness: Double {
        didSet {
            mtkView?.clearColor = MTLClearColor(
                red: brightness, green: brightness, blue: brightness, alpha: 1.0
            )
        }
    }

    private weak var mtkView: MTKView?

    init(device: MTLDevice, mtkView: MTKView, brightness: Double) {
        guard let queue = device.makeCommandQueue() else {
            fatalError("Failed to create Metal command queue")
        }
        self.commandQueue = queue
        self.brightness = brightness
        self.mtkView = mtkView

        super.init()

        // Set the initial clear color to the brightness value
        // In extendedLinearDisplayP3 color space, values > 1.0 activate EDR
        mtkView.clearColor = MTLClearColor(
            red: brightness, green: brightness, blue: brightness, alpha: 1.0
        )
    }

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        // Nothing to do — clearColor handles everything
    }

    func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }

        // Just clear and present — the clearColor fills the drawable
        // with the EDR brightness value, no geometry needed
        encoder.endEncoding()

        if let drawable = view.currentDrawable {
            commandBuffer.present(drawable)
        }
        commandBuffer.commit()
    }
}
