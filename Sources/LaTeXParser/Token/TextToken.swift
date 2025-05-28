// Copyright 2024-2025 Lie Yan

import Foundation

public struct TextToken: TokenProtocol {
  public let text: String

  public init(_ text: String) {
    self.text = text
  }

  public static func validate(text: String) -> Bool {
    // TODO: refine the validation logic
    true
  }
}

extension TextToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdentifierUnsafe: Bool {
    text.first.map { $0.isLetter } ?? false
  }
}

extension TextToken {
  public func deparse() -> String {
    text
  }
}
