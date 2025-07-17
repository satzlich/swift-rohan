// Copyright 2024-2025 Lie Yan

import Foundation

struct ContentTag: OptionSet, CaseIterable {
  var rawValue: UInt32

  init(rawValue: UInt32) {
    self.rawValue = rawValue
  }

  static let plaintext = ContentTag(rawValue: 1 << 0)
  static let formula = ContentTag(rawValue: 1 << 1)

  static let allCases: Array<ContentTag> = [
    .plaintext,
    .formula,
  ]
}

extension NodeType {
  @inline(__always)
  var contentTag: ContentTag? {
    switch self {
    // Misc
    case .counter: .plaintext
    case .linebreak: nil
    case .namedSymbol: .plaintext
    case .text: .plaintext
    case .unknown: nil

    // Elements
    case .content: nil
    case .expansion: nil
    case .heading: nil
    case .itemList: nil
    case .paragraph: nil
    case .parList: nil
    case .root: nil
    case .textStyles: nil

    // Math
    case .accent: nil
    case .attach: nil
    case .equation: .formula
    case .fraction: nil
    case .leftRight: nil
    case .mathAttributes: nil
    case .mathExpression: nil
    case .mathOperator: nil
    case .mathStyles: nil
    case .matrix: nil
    case .multiline: .formula
    case .radical: nil
    case .textMode: nil
    case .underOver: nil

    // Template
    case .apply: nil
    case .argument: nil
    case .cVariable: nil
    case .variable: nil
    }
  }
}
