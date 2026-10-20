// swift-tools-version: 6.3

import PackageDescription

let swiftSettings: [SwiftSetting] = [.enableUpcomingFeature("ApproachableConcurrency")]

let package = Package(
    name: "ForecastDomain",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [.library(name: "ForecastDomain", targets: ["ForecastDomain"])],
    targets: [
        .target(name: "ForecastDomain", swiftSettings: swiftSettings),
        .testTarget(name: "ForecastDomainTests", dependencies: ["ForecastDomain"], swiftSettings: swiftSettings),
    ]
)
