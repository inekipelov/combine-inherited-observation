// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "combine-observation-broadcast",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CombineObservationBroadcast",
            targets: ["CombineObservationBroadcast"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CombineObservationBroadcast",
            dependencies: [],
            path: "Sources",
            linkerSettings: [
                .linkedFramework("Combine")
            ]),
        .testTarget(
            name: "CombineObservationBroadcastTests",
            dependencies: ["CombineObservationBroadcast"],
            path: "Tests",
            linkerSettings: [
                .linkedFramework("Combine")
            ]),
    ]
)
