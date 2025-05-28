// Copyright 2024-2025 Lie Yan

public typealias TextSyntax = TextToken

extension TextSyntax: SyntaxProtocol {
  public func deparse() -> Array<any TokenProtocol> {
    return [self]
  }
}
