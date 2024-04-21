// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HttpX",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
        .macCatalyst(.v16),
        .tvOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "HttpX",
            targets: ["HttpX"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/rockmagma02/SyncStream.git", from: "1.1.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "HttpX",
            dependencies: ["SyncStream"]
        ),
        .testTarget(
            name: "HttpXTests",
            dependencies: ["HttpX"],
            resources: [
                .process("Resources/testImage.png"),
                .process("Resources/testImage.jpg"),
                .process("Resources/testImage.webp"),
                .process("Resources/testImage.svg"),
            ]
        ),
    ]
)
