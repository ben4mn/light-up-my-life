// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LightUpMyLife",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "LightUpMyLife",
            path: "Sources/LightUpMyLife",
            linkerSettings: [
                .unsafeFlags(["-framework", "Metal"]),
                .unsafeFlags(["-framework", "MetalKit"]),
                .unsafeFlags(["-framework", "QuartzCore"]),
            ]
        )
    ]
)
