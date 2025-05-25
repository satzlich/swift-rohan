// Copyright 2024-2025 Lie Yan

import Foundation

public struct CharSyntax: Syntax {
  public let char: Character

  public init(char: Character) {
    self.char = char
  }

  public init?<S: StringProtocol>(string: S) {
    guard string.count == 1 else { return nil }
    self.char = string.first!
  }
}
