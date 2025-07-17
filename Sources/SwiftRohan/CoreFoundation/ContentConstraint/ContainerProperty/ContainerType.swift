// Copyright 2024-2025 Lie Yan

import Foundation

enum ContainerType {
  case inline
  case block
  /// can contain inline or block elements
  case mixed
}

extension ContainerType {
  @inlinable @inline(__always)
  func isCompatible(with content: ContentType) -> Bool {
    switch (self, content) {
    case (.inline, .inline): true
    case (.block, .block): true
    case (.mixed, _): true
    case _: false
    }
  }
}

extension NodeType {
  @inline(__always)
  var containerType: ContainerType? {
    switch self {
    // Misc
    case .counter: nil
    case .linebreak: nil
    case .namedSymbol: nil
    case .text: nil
    case .unknown: nil

    // Elements
    case .content: nil
    case .expansion: nil
    case .heading: .inline
    case .itemList: .block
    case .paragraph: .mixed
    case .parList: .block
    case .root: .block
    case .textStyles: .inline

    // Math
    case .accent: .inline
    case .attach: .inline
    case .equation: .inline
    case .fraction: .inline
    case .leftRight: .inline
    case .mathAttributes: .inline
    case .mathExpression: .inline
    case .mathOperator: .inline
    case .mathStyles: .inline
    case .matrix: .inline
    case .multiline: .inline
    case .radical: .inline
    case .textMode: .inline
    case .underOver: .inline

    // Template
    case .apply: nil
    case .argument: nil
    case .cVariable: nil
    case .variable: nil
    }
  }
}
