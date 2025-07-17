// Copyright 2024-2025 Lie Yan

import Foundation

enum ContainerMode: CaseIterable {
  case text
  case math
}

extension ContainerMode {
  @inlinable @inline(__always)
  func isCompatible(with content: ContentMode) -> Bool {
    switch (self, content) {
    case (.text, .text): true
    case (.math, .math): true
    case (_, .universal): true
    case _: false
    }
  }
}

extension NodeType {
  @inline(__always)
  var containerMode: ContainerMode? {
    switch self {
    // Misc
    case .counter: nil  // non-container
    case .linebreak: nil  // non-container
    case .namedSymbol: nil  // non-container
    case .text: nil  // non-container
    case .unknown: nil  // non-container

    // Elements
    case .content: nil  // inherited
    case .expansion: nil  // inherited
    case .heading: .text
    case .itemList: .text
    case .paragraph: .text
    case .parList: .text
    case .root: .text
    case .textStyles: .text

    // Math
    case .accent: .math
    case .attach: .math
    case .equation: .math
    case .fraction: .math
    case .leftRight: .math
    case .mathAttributes: .math
    case .mathExpression: .math
    case .mathOperator: .math
    case .mathStyles: .math
    case .matrix: .math
    case .multiline: .math
    case .radical: .math
    case .textMode: .math
    case .underOver: .math

    // Template
    case .apply: nil  // unused
    case .argument: nil  // unused
    case .cVariable: nil  // assigned or inherited
    case .variable: nil  // assigned or inherited
    }
  }
}
