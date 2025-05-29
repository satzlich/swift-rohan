// Copyright 2024-2025 Lie Yan

import Foundation

public struct TextToken: TokenProtocol {
  public let text: String
  public let mode: LayoutMode

  public init(_ text: String, mode: LayoutMode) {
    self.text = text
    self.mode = mode
  }

  public static func validate(text: String) -> Bool {
    // TODO: refine the validation logic
    true
  }
}

extension TextToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdentifierUnsafe: Bool {
    guard let first = text.first else { return false }
    return first.isLetter || first.isNumber
  }
}

extension TextToken {
  public func deparse() -> String {
    text
  }
}
