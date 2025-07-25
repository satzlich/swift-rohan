/// Consecutive spaces.
public struct SpaceToken: TokenProtocol {
  public let count: Int

  public init(count: Int = 1) {
    precondition(count > 0)
    self.count = count
  }
}

extension SpaceToken {
  public var endsWithIdentifier: Bool { false }
  public var startsWithIdSpoiler: Bool { false }
}

extension SpaceToken {
  public func untokenize() -> String {
    String(repeating: " ", count: count)
  }
}
