// Copyright 2024-2025 Lie Yan

public typealias NewlineSyntax = NewlineToken

extension NewlineSyntax: SyntaxProtocol {
  public func deparse() -> Array<any TokenProtocol> {
    return [self]
  }
}
