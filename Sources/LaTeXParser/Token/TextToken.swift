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
