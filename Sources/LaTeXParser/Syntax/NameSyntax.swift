// Copyright 2024-2025 Lie Yan

import Foundation

public struct NameSyntax: Syntax, Equatable, Hashable, Sendable {
  let string: String

  public init?(_ string: String) {
    guard NameSyntax.validate(string: string) else { return nil }
    self.string = string
  }

  public init?(_ string: Substring) {
    guard NameSyntax.validate(string: string) else { return nil }
    self.string = String(string)
  }

  public static func validate(string: String) -> Bool {
    string.wholeMatch(of: _regex) != nil
  }

  public static func validate(string: Substring) -> Bool {
    string.wholeMatch(of: _regex) != nil
  }

  private static let _regex: Regex = #/^[a-zA-Z0-9_]+\*?$/#
}
