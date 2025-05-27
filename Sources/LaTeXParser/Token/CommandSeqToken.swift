// Copyright 2024-2025 Lie Yan

import Foundation

/// Command syntax that starts with backslash.
public struct CommandSeqToken: TokenProtocol, Equatable, Hashable, Sendable {
  public var escapeChar: Character { "\\" }
  public let name: NameToken

  public init(name: NameToken) {
    self.name = name
  }

  public init?(_ string: String) {
    guard string.starts(with: "\\"),
      let name = NameToken(string.dropFirst())
    else { return nil }
    self.name = name
  }
}

extension CommandSeqToken {
  public static let begin = CommandSeqToken("\\begin")!
  public static let end = CommandSeqToken("\\end")!
}

extension CommandSeqToken {
  public var endsWithIdentifier: Bool { true }
  public var startsWithIdentifierUnsafe: Bool { false }
}

extension CommandSeqToken {
  public func deparse() -> String {
    return "\(escapeChar)\(name.deparse())"
  }
}
