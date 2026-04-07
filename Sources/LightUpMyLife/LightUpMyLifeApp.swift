import SwiftUI

@main
struct LightUpMyLifeApp: App {
    @StateObject private var brightnessManager = BrightnessManager()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(brightnessManager)
        } label: {
            Image(systemName: brightnessManager.isEnabled ? "sun.max.fill" : "sun.max")
                .symbolRenderingMode(.hierarchical)
        }
        .menuBarExtraStyle(.window)
    }
}
