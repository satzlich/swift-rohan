// Copyright 2024-2025 Lie Yan

import Foundation
import UnicodeMathClass

enum MathKind: String, CaseIterable, MathDeclarationProtocol {
  case mathbin
  case mathclose
  case mathinner
  case mathop
  case mathopen
  case mathord
  case mathpunct
  case mathrel

  var command: String { rawValue }

  static var predefinedCases: [MathKind] { allCases }
}

extension MathKind {
  private static let _dictionary: [String: MathKind] =
    allCases.reduce(into: [:]) { result, kind in result[kind.command] = kind }

  static func lookup(_ command: String) -> MathKind? {
    _dictionary[command]
  }
}

extension MathKind {
  var mathClass: MathClass {
    switch self {
    case .mathbin: .Binary
    case .mathclose: .Closing
    case .mathinner:
      // override Special for Inner. See also `resolveSpacing(_:_:_:)`.
      .Special
    case .mathop: .Large
    case .mathopen: .Opening
    case .mathord: .Normal
    case .mathpunct: .Punctuation
    case .mathrel: .Relation
    }
  }
}
