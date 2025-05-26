// Copyright 2024-2025 Lie Yan

public struct BeginClauseSyntax: SyntaxProtocol {
  /// environment name
  public let name: NameToken

  public init(name: NameToken) {
    self.name = name
  }

  public func isPaired(with rhs: EndClauseSyntax) -> Bool {
    self.name == rhs.name
  }
}
