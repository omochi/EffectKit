// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EffectKit",
    platforms: [.macOS(.v10_12)],
    products: [
        .library(
            name: "EffectKit",
            targets: ["EffectKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/omochi/FiberKit", .branch("master")),
    ],
    targets: [
        .target(name: "EffectLHKT"),
        .target(
            name: "EffectKit",
            dependencies: ["FiberKit", "EffectLHKT"]),
        .testTarget(
            name: "EffectKitTests",
            dependencies: ["EffectKit"]),
    ]
)
