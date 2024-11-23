// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-rohan",
    platforms: [
        .macOS(.v14),
        .iOS(.v12),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Rohan",
            targets: ["Rohan"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.2"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),

        .package(url: "https://github.com/satzlich/swift-ttf-parser", branch: "main"),
        .package(url: "https://github.com/satzlich/swift-unicode-math", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Rohan",

            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Numerics", package: "swift-numerics"),

                .product(name: "TTFParser", package: "swift-ttf-parser"),
                .product(name: "UnicodeMathClass", package: "swift-unicode-math"),
            ]
        ),
        .testTarget(
            name: "RohanTests",
            dependencies: ["Rohan"]
        ),
    ]
)
