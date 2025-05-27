// Copyright 2024-2025 Lie Yan

import Foundation

/// Command syntax that starts with backslash.
public struct ControlSeqToken: TokenProtocol, Equatable, Hashable, Sendable {
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

extension ControlSeqToken {
  public static let begin = ControlSeqToken("\\begin")!
  public static let end = ControlSeqToken("\\end")!
  public static let left = ControlSeqToken("\\left")!
  public static let right = ControlSeqToken("\\right")!
}

extension ControlSeqToken {
  public var endsWithIdentifier: Bool { true }
  public var startsWithIdentifierUnsafe: Bool { false }
}

extension ControlSeqToken {
  public func deparse() -> String {
    return "\(escapeChar)\(name.deparse())"
  }
}
