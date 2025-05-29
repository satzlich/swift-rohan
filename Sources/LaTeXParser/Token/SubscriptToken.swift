// Copyright 2024-2025 Lie Yan

public struct SubscriptToken: TokenProtocol {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool { false }
}

extension SubscriptToken {
  public func untokenize() -> String {
    "_"
  }
}
