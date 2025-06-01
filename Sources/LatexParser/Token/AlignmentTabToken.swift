// Copyright 2024-2025 Lie Yan

public struct AlignmentTabToken: TokenProtocol {
  public init() {}
}

extension AlignmentTabToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool { false }
}

extension AlignmentTabToken {
  public func untokenize() -> String { "&" }
}
