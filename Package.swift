// swift-tools-version: 6.1
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
      name: "SwiftRohan",
      targets: ["SwiftRohan"]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.1"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.2.0"),
    .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    .package(url: "https://github.com/swiftlang/swift-syntax", from: "601.0.0"),
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
      name: "SwiftRohan",
      dependencies: [
        "RohanMacro",
        "LatexParser",
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Numerics", package: "swift-numerics"),
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SatzAlgorithms", package: "satz-algorithms"),
        .product(name: "TTFParser", package: "swift-ttf-parser"),
        .product(name: "UnicodeMathClass", package: "swift-unicode-math"),
      ],
      resources: [
        .process("Resources")
      ],
      swiftSettings: [
        // .define("DECORATE_LAYOUT_FRAGMENT"),
        // .define("COLLECT_STATS_FRAGMENT_VIEW_CACHE"),
        .define("LOG_TEXT_SELECTION"),
        .define("LOG_PICKING_POINT"),
      ],
    ),
    .target(
      name: "LatexParser",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Numerics", package: "swift-numerics"),
      ]
    ),
    .testTarget(
      name: "RohanTests",
      dependencies: ["SwiftRohan"],
      resources: [
        .process("Resources")
      ],
      swiftSettings: [
        // .define("DECORATE_LAYOUT_FRAGMENT")
      ],
    ),
    .testTarget(
      name: "LatexParserTests",
      dependencies: ["LatexParser"]
    ),
  ]
)
