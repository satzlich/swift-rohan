// Copyright 2024-2025 Lie Yan

import Foundation

public enum ExprType: String, CaseIterable, Codable, Sendable {
  // Misc
  case counter
  case linebreak
  case namedSymbol
  case text
  case unknown

  // Elements
  case content
  case expansion
  case heading
  case itemList
  case paragraph
  case parList
  case root
  case textStyles

  // Math
  case accent
  case attach
  case equation
  case fraction
  case leftRight
  case mathAttributes
  case mathExpression  // Simple but Math only
  case mathOperator  // Simple but Math only
  case mathStyles
  case matrix
  case multiline  // align, gather, multiline, etc.
  case radical
  case textMode
  case underOver

  // Template
  case apply
  case argument
  case cVariable
  case variable
}

public typealias NodeType = ExprType

extension NodeType {
  @inline(__always)
  var contentMode: ContentMode? {
    switch self {
    // Misc
    case .counter: .text
    case .linebreak: .text
    case .namedSymbol: nil  // instance-specific
    case .text: .universal
    case .unknown: .universal

    // Elements
    case .content: nil  // computed from children.
    case .expansion: nil  // computed from children.
    case .heading: .text
    case .itemList: .text
    case .paragraph: .text
    case .parList: .text
    case .root: .text  // placeholder; root cannot be contained.
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
    case .apply: nil  // use the value of expansion.
    case .argument: nil  // unused.
    case .cVariable: nil  // unused. Computed from children.
    case .variable: nil  // unused. Computed from children.
    }
  }
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
    case .cVariable: nil  // inherited
    case .variable: nil  // inherited
    }
  }
}

extension NodeType {
  @inline(__always)
  var containerType: ContainerType? {
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
    case .apply: nil  // unused
    case .argument: nil  // unused
    case .cVariable: nil  // inherited
    case .variable: nil  // inherited
    }
  }
}
