// swift-tools-version: 6.3

import PackageDescription

let swiftSettings: [SwiftSetting] = [.enableUpcomingFeature("ApproachableConcurrency")]

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "Networking", targets: ["Networking"])],
    targets: [
        .target(name: "Networking", swiftSettings: swiftSettings),
        .testTarget(name: "NetworkingTests", dependencies: ["Networking"], swiftSettings: swiftSettings),
    ]
)
