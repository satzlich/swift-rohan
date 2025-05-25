// Copyright 2024-2025 Lie Yan

import Foundation

/// Command syntax that starts with backslash.
public struct CommandSeqSyntax: Syntax, Equatable, Hashable, Sendable {
  public var prefix: String { "\\" }
  public let name: CommandNameSyntax

  public init(name: CommandNameSyntax) {
    self.name = name
  }

  public init?(string: String) {
    guard string.starts(with: "\\"),
      let name = CommandNameSyntax(string.dropFirst())
    else { return nil }
    self.name = name
  }
}

extension CommandSeqSyntax {
  public static let begin = CommandSeqSyntax(string: "\\begin")!
  public static let end = CommandSeqSyntax(string: "\\end")!
}
