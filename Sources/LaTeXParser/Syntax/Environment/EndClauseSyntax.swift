// Copyright 2024-2025 Lie Yan

public struct EndClauseSyntax: SyntaxProtocol {
  /// environment name
  public let name: NameToken

  public init(name: NameToken) {
    self.name = name
  }

  public func isPaired(with lhs: BeginClauseSyntax) -> Bool {
    lhs.isPaired(with: self)
  }
}
