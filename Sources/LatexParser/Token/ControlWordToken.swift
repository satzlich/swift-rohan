// Copyright 2024-2025 Lie Yan

import Foundation

/// Command syntax that starts with backslash.
public struct ControlWordToken: TokenProtocol, Equatable, Hashable, Sendable {
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

extension ControlWordToken {
  public static let begin = ControlWordToken("\\begin")!
  public static let end = ControlWordToken("\\end")!
  public static let left = ControlWordToken("\\left")!
  public static let right = ControlWordToken("\\right")!
  public static let prime = ControlWordToken("\\prime")!
  public static let dprime = ControlWordToken("\\dprime")!
  public static let trprime = ControlWordToken("\\trprime")!
  public static let qprime = ControlWordToken("\\qprime")!
  public static let limits = ControlWordToken("\\limits")!
  public static let nolimits = ControlWordToken("\\nolimits")!
  public static let backslash = ControlWordToken("\\backslash")!
  public static let textbackslash = ControlWordToken("\\textbackslash")!
}

extension ControlWordToken {
  public var endsWithIdentifier: Bool { true }
  public var startsWithIdSpoiler: Bool { false }
}

extension ControlWordToken {
  public func untokenize() -> String {
    return "\(escapeChar)\(name.untokenize())"
  }
}
