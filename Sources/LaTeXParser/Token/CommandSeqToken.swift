// Copyright 2024-2025 Lie Yan

import Foundation

/// Command syntax that starts with backslash.
public struct CommandSeqToken: Token, Equatable, Hashable, Sendable {
  public var prefix: String { "\\" }
  public let name: NameToken

  public init(name: NameToken) {
    self.name = name
  }

  public init?(string: String) {
    guard string.starts(with: "\\"),
      let name = NameToken(string.dropFirst())
    else { return nil }
    self.name = name
  }
}

extension CommandSeqToken {
  public static let begin = CommandSeqToken(string: "\\begin")!
  public static let end = CommandSeqToken(string: "\\end")!
}
