// swift-tools-version: 6.3

import PackageDescription

let swiftSettings: [SwiftSetting] = [.enableUpcomingFeature("ApproachableConcurrency")]

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v17)],
    products: [.library(name: "DesignSystem", targets: ["DesignSystem"])],
    targets: [
        .target(name: "DesignSystem", swiftSettings: swiftSettings),
        .testTarget(name: "DesignSystemTests", dependencies: ["DesignSystem"], swiftSettings: swiftSettings),
    ]
)
