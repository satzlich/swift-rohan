// Copyright 2024-2025 Lie Yan

public struct SuperscriptToken: TokenProtocol {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool { false }
}

extension SuperscriptToken {
  public func untokenize() -> String {
    "^"
  }
}
