// Copyright 2024-2025 Lie Yan

public struct EndClauseSyntax: SyntaxProtocol {
  public let name: NameToken

  public init(name: NameToken) {
    self.name = name
  }
}
