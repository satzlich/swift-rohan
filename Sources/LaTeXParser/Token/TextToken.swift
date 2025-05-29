// Copyright 2024-2025 Lie Yan

import Foundation

public struct TextToken: TokenProtocol {
  public let text: String
  public let mode: LayoutMode

  public init(_ text: String, mode: LayoutMode) {
    precondition(TextToken.validate(text: text, mode: mode))
    self.text = text
    self.mode = mode
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
  public func untokenize() -> String {
    text
  }
}
