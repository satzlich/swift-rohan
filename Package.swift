// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
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
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.2"),
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-syntax", from: "510.0.0"),
    .package(url: "https://github.com/satzlich/satz-algorithms", branch: "main"),
    .package(url: "https://github.com/satzlich/swift-ttf-parser", branch: "main"),
    .package(url: "https://github.com/satzlich/swift-unicode-math", from: "1.0.0"),
  ],
  targets: [
    .macro(
      name: "RohanMacro",
      dependencies: [
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
      ]
    ),
    .target(
      name: "RohanCommon",
      dependencies: [
        .product(name: "Numerics", package: "swift-numerics")
      ]
    ),
    .target(
      name: "Rohan",
      dependencies: [
        "RohanCommon",
        "RohanMacro",
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Numerics", package: "swift-numerics"),
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SatzAlgorithms", package: "satz-algorithms"),
        .product(name: "TTFParser", package: "swift-ttf-parser"),
        .product(name: "UnicodeMathClass", package: "swift-unicode-math"),
      ],
      swiftSettings: [
        // .define("DECORATE_LAYOUT_FRAGMENT"),
        // .define("DECORATE_CONTENT_VIEW"),
        /* collect stats for fragment view cache */
        // .define("COLLECT_STATS_FRAGMENT_VIEW_CACHE"),
        // .define("LOG_MARKED_TEXT"),
        .define("LOG_TEXT_SELECTION")
        // .define("LOG_PICKING_POINT"),
      ]
    ),
    .target(
      name: "StringDatabase",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Numerics", package: "swift-numerics"),
      ]
    ),
    .target(
      name: "RhTextView",
      dependencies: [
        "Rohan",
        "RohanCommon",
        .product(name: "Numerics", package: "swift-numerics"),
      ]
    ),
    .testTarget(
      name: "RohanCommonTests",
      dependencies: ["RohanCommon"]
    ),
    .testTarget(
      name: "RohanTests",
      dependencies: ["Rohan"],
      swiftSettings: [
        // .define("DECORATE_LAYOUT_FRAGMENT")
      ]
    ),
    .testTarget(
      name: "StringDatabaseTests",
      dependencies: ["StringDatabase"]
    ),
  ]
)
