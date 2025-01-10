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
            targets: ["Rohan", "RhTextView"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.2"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
        .package(url: "https://github.com/satzlich/satz-algorithms", branch: "main"),
        .package(url: "https://github.com/satzlich/swift-ttf-parser", branch: "main"),
        .package(url: "https://github.com/satzlich/swift-unicode-math", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "RohanCommon",
            dependencies: []
        ),
        .target(
            name: "Rohan",
            dependencies: [
                "RohanCommon",
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "SatzAlgorithms", package: "satz-algorithms"),
                .product(name: "TTFParser", package: "swift-ttf-parser"),
                .product(name: "UnicodeMathClass", package: "swift-unicode-math"),
            ],
            swiftSettings: [
                .define("TESTING"),
            ]
        ),
        .target(
            name: "RhTextView",
            dependencies: ["Rohan", "RohanCommon"]
        ),
        .testTarget(
            name: "RohanTests",
            dependencies: ["Rohan"]
        ),
    ]
)
