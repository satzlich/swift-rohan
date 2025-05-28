// Copyright 2024-2025 Lie Yan

public typealias SpaceSyntax = SpaceToken

extension SpaceSyntax: SyntaxProtocol {
  public func deparse() -> Array<any TokenProtocol> {
    return [self]
  }
}
