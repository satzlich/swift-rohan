// Copyright 2024-2025 Lie Yan

import Foundation

enum ContentMode: String, Comparable, Codable, CaseIterable {
  case text
  case math
  /// can be either text or math
  case universal

  /// The order is arbitrary, but it is used for sorting.
  static func < (lhs: ContentMode, rhs: ContentMode) -> Bool {
    lhs.rawValue < rhs.rawValue
  }
}

extension ContentMode {
  @inlinable @inline(__always)
  func isCompatible(with container: ContainerMode) -> Bool {
    container.isCompatible(with: self)
  }
}

extension NodeType {
  @inline(__always)
  var contentMode: ContentMode? {
    switch self {
    // Misc
    case .counter: .text
    case .linebreak: .text
    case .namedSymbol: nil  // instance-specific
    case .text: .universal
    case .unknown: nil

    // Elements
    case .content: nil
    case .expansion: nil
    case .heading: .text
    case .itemList: .text
    case .paragraph: .text
    case .parList: .text
    case .root: nil
    case .textStyles: .text

    // Math
    case .accent: .math
    case .attach: .math
    case .equation: .text
    case .fraction: .math
    case .leftRight: .math
    case .mathAttributes: .math
    case .mathExpression: .math
    case .mathOperator: .math
    case .mathStyles: .math
    case .matrix: .math
    case .multiline: .text
    case .radical: .math
    case .textMode: .math
    case .underOver: .math

    // Template
    case .apply: nil
    case .argument: nil
    case .cVariable: nil
    case .variable: nil
    }
  }
}
