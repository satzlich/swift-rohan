// Copyright 2024-2025 Lie Yan

public typealias EscapedCharSyntax = EscapedCharToken

extension EscapedCharSyntax: SyntaxProtocol {

  public func deparse() -> Array<any TokenProtocol> {
    [self]
  }
}
