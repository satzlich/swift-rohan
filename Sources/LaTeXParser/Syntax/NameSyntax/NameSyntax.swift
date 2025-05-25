// Copyright 2024-2025 Lie Yan

import Foundation

/// Command name share the same syntax with environment name.
public struct _NameSyntax<T>: Syntax, Equatable, Hashable, Sendable {
  let string: String

  public init?(_ string: String) {
    guard _NameSyntax.validate(string: string) else { return nil }
    self.string = string
  }

  public init?(_ string: Substring) {
    guard _NameSyntax.validate(string: string) else { return nil }
    self.string = String(string)
  }

  public static func validate(string: String) -> Bool {
    let regex = #/^[a-zA-Z0-9_]+\*?$/#
    return string.wholeMatch(of: regex) != nil
  }

  public static func validate(string: Substring) -> Bool {
    let regex = #/^[a-zA-Z0-9_]+\*?$/#
    return string.wholeMatch(of: regex) != nil
  }
}
