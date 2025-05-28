// Copyright 2024-2025 Lie Yan

public struct SubscriptToken: TokenProtocol {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdentifierUnsafe: Bool { false }
}

extension SubscriptToken {
  public func deparse() -> String {
    "_"
  }
}
